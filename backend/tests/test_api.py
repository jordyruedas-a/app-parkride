import os
from datetime import datetime
from uuid import UUID

os.environ["DATABASE_URL"] = "sqlite://"
os.environ["JWT_SECRET"] = "test-secret"

import pytest
from fastapi.testclient import TestClient

from app.database import Base, SessionLocal, engine
from app.main import app
from app.models import QRToken, Route
from seed_demo import ROUTES, seed_demo


@pytest.fixture(autouse=True)
def reset_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client


def register(client: TestClient, email: str, role: str) -> dict:
    response = client.post(
        "/auth/register",
        json={
            "email": email,
            "password": "SecurePass123",
            "name": email.split("@")[0],
            "role": role,
        },
    )
    assert response.status_code == 201, response.text
    return response.json()


def login_headers(client: TestClient, email: str) -> dict:
    response = client.post("/auth/login", json={"email": email, "password": "SecurePass123"})
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def create_accounts(client: TestClient) -> dict:
    accounts = {
        "supervisor": register(client, "supervisor@example.com", "supervisor"),
        "driver_one": register(client, "driver-one@example.com", "route_driver"),
        "driver_two": register(client, "driver-two@example.com", "route_driver"),
        "driver_three": register(client, "driver-three@example.com", "route_driver"),
        "passenger": register(client, "passenger@example.com", "passenger"),
    }
    accounts["headers"] = {
        name: login_headers(client, f"{name.replace('_', '-')}@example.com")
        for name in ("driver_one", "driver_two", "driver_three", "passenger")
    }
    accounts["headers"]["supervisor"] = login_headers(client, "supervisor@example.com")
    return accounts


def create_route(
    client: TestClient,
    supervisor_headers: dict,
    driver_id: str | None = None,
    name: str = "North",
    transport_type: str = "bus",
) -> dict:
    response = client.post(
        "/routes",
        headers=supervisor_headers,
        json={
            "name": name,
            "origin": "Campus",
            "destination": "Plant",
            "departure_time": "08:00:00",
            "transport_type": transport_type,
            "driver_id": driver_id,
            "vehicle": {
                "model": f"Test {transport_type}",
                "plate": f"{name[:8].upper()}-{transport_type.upper()}",
                "color": "White",
                "transport_type": transport_type,
            },
            "stops": [
                {"stop_name": "Gate A", "latitude": 25.67, "longitude": -100.31, "stop_order": 0},
                {"stop_name": "Gate B", "latitude": 25.68, "longitude": -100.30, "stop_order": 1},
            ],
        },
    )
    assert response.status_code == 201, response.text
    return response.json()


def test_auth_and_role_protected_route_creation(client: TestClient):
    passenger = register(client, "passenger@example.com", "passenger")
    headers = login_headers(client, "passenger@example.com")
    assert client.get("/me", headers=headers).json()["id"] == passenger["id"]
    response = client.post(
        "/routes",
        headers=headers,
        json={"name": "Nope", "origin": "A", "destination": "B", "departure_time": "08:00:00"},
    )
    assert response.status_code == 403


def test_route_assignment_and_driver_scope(client: TestClient):
    accounts = create_accounts(client)
    route = create_route(client, accounts["headers"]["supervisor"], name="Unassigned")
    assignment = client.post(
        f"/routes/{route['id']}/assign",
        headers=accounts["headers"]["supervisor"],
        json={"driver_id": accounts["driver_one"]["id"]},
    )
    assert assignment.status_code == 200
    assert assignment.json()["driver"]["name"] == "driver-one"
    assert len(assignment.json()["stops"]) == 2
    driver_routes = client.get("/routes", headers=accounts["headers"]["driver_one"])
    assert [item["id"] for item in driver_routes.json()] == [route["id"]]
    assert client.get(f"/routes/{route['id']}", headers=accounts["headers"]["driver_two"]).status_code == 403


def test_route_full_details_update_and_vehicle_assignment(client: TestClient):
    accounts = create_accounts(client)
    created = client.post(
        "/routes",
        headers=accounts["headers"]["supervisor"],
        json={
            "name": "Cumbres Express",
            "origin": "Cumbres",
            "destination": "FIME",
            "departure_time": "07:15:00",
            "transport_type": "van",
            "color": "#112233",
            "driver_id": accounts["driver_one"]["id"],
            "vehicle": {
                "model": "Toyota Hiace",
                "plate": "TEST-001",
                "color": "Blanca",
                "transport_type": "van",
            },
            "stops": [{"stop_name": "Cumbres", "latitude": 25.73, "longitude": -100.37, "stop_order": 0}],
        },
    )
    assert created.status_code == 201, created.text
    route = created.json()
    assert route["transport_type"] == "van"
    assert route["color"] == "#112233"
    assert route["is_available"] is True
    assert route["vehicle"]["plate"] == "TEST-001"

    updated = client.put(
        f"/routes/{route['id']}",
        headers=accounts["headers"]["supervisor"],
        json={"color": "#334455", "is_available": False},
    )
    assert updated.status_code == 200, updated.text
    assert updated.json()["color"] == "#334455"
    assert updated.json()["is_available"] is False
    assert client.get("/routes", headers=accounts["headers"]["driver_one"]).json() == [updated.json()]


def test_demo_seed_creates_ten_idempotent_routes_and_demo_login(client: TestClient):
    with SessionLocal() as db:
        seed_demo(db)
        seed_demo(db)
        routes = db.query(Route).filter(Route.name.in_([item["name"] for item in ROUTES])).all()
        transport_types = [route.transport_type for route in routes]
        driver_ids = {route.driver_id for route in routes}
        vehicle_ids = {route.vehicle_id for route in routes}
        route_states = [(route.is_active, route.is_available, len(route.stops)) for route in routes]

    assert len(routes) == 10
    assert transport_types.count("bus") == 5
    assert transport_types.count("van") == 5
    assert len(driver_ids) == 10
    assert len(vehicle_ids) == 10
    assert all(is_active and is_available and stop_count == 3 for is_active, is_available, stop_count in route_states)
    login = client.post("/auth/login", json={"email": "pasajero@parkride.com", "password": "123"})
    assert login.status_code == 200


def test_qr_validation_is_single_use_and_vehicle_type_bound(client: TestClient):
    accounts = create_accounts(client)
    route_one = create_route(
        client, accounts["headers"]["supervisor"], accounts["driver_one"]["id"], "North"
    )
    route_two = create_route(
        client, accounts["headers"]["supervisor"], accounts["driver_two"]["id"], "South"
    )
    assert route_two["driver_id"] == accounts["driver_two"]["id"]
    created = client.post(
        "/trips",
        headers=accounts["headers"]["passenger"],
        json={"route_id": route_one["id"], "transport_type": "shuttle"},
    )
    assert created.status_code == 201, created.text
    token = created.json()["token"]
    expires_at = datetime.fromisoformat(created.json()["expires_at"])
    assert 14 * 60 <= (expires_at - datetime.utcnow()).total_seconds() <= 15 * 60
    accepted = client.post(
        "/qr/validate",
        headers=accounts["headers"]["driver_two"],
        json={"token": token},
    )
    assert accepted.status_code == 200
    assert accepted.json()["valid"] is True
    assert client.post(
        "/qr/validate",
        headers=accounts["headers"]["driver_one"],
        json={"token": token},
    ).status_code == 409
    van_route = create_route(
        client,
        accounts["headers"]["supervisor"],
        accounts["driver_three"]["id"],
        "Van North",
        "van",
    )
    van_ticket = client.post(
        "/trips",
        headers=accounts["headers"]["passenger"],
        json={"route_id": van_route["id"], "transport_type": "van"},
    ).json()["token"]
    rejected = client.post(
        "/qr/validate",
        headers=accounts["headers"]["driver_one"],
        json={"token": van_ticket},
    )
    assert rejected.status_code == 403
    assert "Van" in rejected.json()["detail"]
    expired = client.post(
        "/trips",
        headers=accounts["headers"]["passenger"],
        json={"route_id": route_one["id"]},
    )
    with SessionLocal() as db:
        db.query(QRToken).filter(QRToken.token == UUID(expired.json()["token"])).update(
            {QRToken.expires_at: datetime.utcnow()}
        )
        db.commit()
    assert client.post(
        "/qr/validate",
        headers=accounts["headers"]["driver_one"],
        json={"token": expired.json()["token"]},
    ).status_code == 410


def test_report_submission_and_supervisor_resolution(client: TestClient):
    accounts = create_accounts(client)
    submitted = client.post(
        "/reports",
        headers=accounts["headers"]["passenger"],
        json={"category": "safety", "comment": "Seat belt is damaged."},
    )
    assert submitted.status_code == 201, submitted.text
    report = submitted.json()
    assert report["status"] == "open"
    assert len(client.get("/reports", headers=accounts["headers"]["passenger"]).json()) == 1
    resolved = client.post(
        f"/reports/{report['id']}/resolve",
        headers=accounts["headers"]["supervisor"],
    )
    assert resolved.status_code == 200
    assert resolved.json()["status"] == "resolved"
    assert resolved.json()["resolved_by_id"] == accounts["supervisor"]["id"]
