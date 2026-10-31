"""Seed the local ParkRide database with predictable Monterrey demo data."""

from datetime import time
from uuid import uuid4

from sqlalchemy.orm import Session

from app.auth import hash_password
from app.database import SessionLocal, initialize_database
from app.models import Route, RouteStop, User, Vehicle

DEMO_PASSWORD = "123"
DEMO_ACCOUNTS = (
    ("pasajero@parkride.com", "Pasajero Demo", "passenger"),
    ("chofer@parkride.com", "Chofer Demo", "route_driver"),
    ("supervisor@parkride.com", "Supervisor Demo", "supervisor"),
)

ROUTES = (
    {
        "name": "Cumbres - FIME",
        "transport_type": "bus",
        "color": "#2563EB",
        "departure_time": time(6, 40),
        "origin": "Plaza Cumbres",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer@parkride.com", "Chofer Demo"),
        "vehicle": ("Mercedes-Benz OF 1721", "PRB-001", "Azul"),
        "stops": (
            ("Plaza Cumbres", 25.7308, -100.3707),
            ("Av. Lincoln y Gonzalitos", 25.7236, -100.3487),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "San Nicolás - FIME",
        "transport_type": "bus",
        "color": "#0F766E",
        "departure_time": time(6, 45),
        "origin": "Plaza Fiesta Anáhuac",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.sannicolas@parkride.com", "María Garza"),
        "vehicle": ("International 4700", "PRB-002", "Verde"),
        "stops": (
            ("Plaza Fiesta Anáhuac", 25.7489, -100.2949),
            ("Estación Universidad", 25.7287, -100.3104),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Guadalupe - FIME",
        "transport_type": "bus",
        "color": "#DC2626",
        "departure_time": time(6, 25),
        "origin": "Expo Guadalupe",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.guadalupe@parkride.com", "Jorge Hernández"),
        "vehicle": ("DINA Linner", "PRB-003", "Rojo"),
        "stops": (
            ("Expo Guadalupe", 25.6793, -100.2524),
            ("Estación Y Griega", 25.6795, -100.2878),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Apodaca - FIME",
        "transport_type": "bus",
        "color": "#7C3AED",
        "departure_time": time(6, 15),
        "origin": "Centro de Apodaca",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.apodaca@parkride.com", "Lucía Martínez"),
        "vehicle": ("Mercedes-Benz Boxer", "PRB-004", "Morado"),
        "stops": (
            ("Centro de Apodaca", 25.7806, -100.1881),
            ("Huinalá", 25.7691, -100.2382),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Santa Catarina - FIME",
        "transport_type": "bus",
        "color": "#EA580C",
        "departure_time": time(6, 30),
        "origin": "La Fama, Santa Catarina",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.santacatarina@parkride.com", "Roberto Salinas"),
        "vehicle": ("Volvo 8300", "PRB-005", "Naranja"),
        "stops": (
            ("La Fama, Santa Catarina", 25.6823, -100.4589),
            ("San Pedro Pabellón M", 25.6653, -100.4050),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Centro - FIME",
        "transport_type": "van",
        "color": "#0891B2",
        "departure_time": time(7, 0),
        "origin": "Macroplaza",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.centro@parkride.com", "Ana Torres"),
        "vehicle": ("Toyota Hiace", "PRV-006", "Turquesa"),
        "stops": (
            ("Macroplaza", 25.6660, -100.3092),
            ("Alameda Mariano Escobedo", 25.6754, -100.3182),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Contry - FIME",
        "transport_type": "van",
        "color": "#DB2777",
        "departure_time": time(6, 50),
        "origin": "Plaza Nuevo Sur",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.contry@parkride.com", "Carlos Peña"),
        "vehicle": ("Nissan Urvan", "PRV-007", "Rosa"),
        "stops": (
            ("Plaza Nuevo Sur", 25.6507, -100.2862),
            ("Contry La Silla", 25.6428, -100.2764),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Escobedo - FIME",
        "transport_type": "van",
        "color": "#4F46E5",
        "departure_time": time(6, 35),
        "origin": "Plaza Sendero Escobedo",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.escobedo@parkride.com", "Fernanda Ríos"),
        "vehicle": ("Ford Transit", "PRV-008", "Índigo"),
        "stops": (
            ("Plaza Sendero Escobedo", 25.7940, -100.3296),
            ("Centro de Escobedo", 25.8057, -100.3264),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "Juárez - FIME",
        "transport_type": "van",
        "color": "#65A30D",
        "departure_time": time(6, 10),
        "origin": "Centro de Juárez",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.juarez@parkride.com", "Diego Flores"),
        "vehicle": ("Volkswagen Crafter", "PRV-009", "Verde lima"),
        "stops": (
            ("Centro de Juárez", 25.6474, -100.0966),
            ("Valle Soleado", 25.6697, -100.1596),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
    {
        "name": "García - FIME",
        "transport_type": "van",
        "color": "#92400E",
        "departure_time": time(6, 0),
        "origin": "Centro de García",
        "destination": "FIME, Ciudad Universitaria",
        "driver": ("chofer.garcia@parkride.com", "Sofía Villarreal"),
        "vehicle": ("Renault Master", "PRV-010", "Café"),
        "stops": (
            ("Centro de García", 25.8121, -100.5984),
            ("Dominio Cumbres", 25.7433, -100.3824),
            ("FIME, Ciudad Universitaria", 25.7250, -100.3130),
        ),
    },
)


def _upsert_user(db: Session, email: str, name: str, role: str) -> User:
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        user = User(id=uuid4(), email=email, password_hash="", name=name, role=role)
        db.add(user)
    user.password_hash = hash_password(DEMO_PASSWORD)
    user.name = name
    user.role = role
    user.company = "ParkRide"
    user.department = "Demostracion"
    user.is_active = True
    db.flush()
    return user


def seed_demo(db: Session) -> None:
    """Create or refresh the ten fixed demo routes without duplicating them."""
    for email, name, role in DEMO_ACCOUNTS:
        _upsert_user(db, email, name, role)

    for definition in ROUTES:
        driver_email, driver_name = definition["driver"]
        vehicle_model, vehicle_plate, vehicle_color = definition["vehicle"]
        driver = _upsert_user(db, driver_email, driver_name, "route_driver")
        vehicle = db.query(Vehicle).filter(Vehicle.plate == vehicle_plate).first()
        if vehicle is None:
            vehicle = Vehicle(id=uuid4(), plate=vehicle_plate)
            db.add(vehicle)
        vehicle.model = vehicle_model
        vehicle.color = vehicle_color
        vehicle.transport_type = definition["transport_type"]
        vehicle.is_active = True
        db.flush()

        route = db.query(Route).filter(Route.name == definition["name"]).first()
        if route is None:
            route = Route(id=uuid4(), name=definition["name"])
            db.add(route)
        db.query(Route).filter(Route.driver_id == driver.id, Route.id != route.id).update(
            {Route.driver_id: None}, synchronize_session=False
        )
        db.query(Route).filter(Route.vehicle_id == vehicle.id, Route.id != route.id).update(
            {Route.vehicle_id: None}, synchronize_session=False
        )
        route.origin = definition["origin"]
        route.destination = definition["destination"]
        route.departure_time = definition["departure_time"]
        route.transport_type = definition["transport_type"]
        route.color = definition["color"]
        route.driver_id = driver.id
        route.vehicle_id = vehicle.id
        route.is_active = True
        route.is_available = True
        route.stops.clear()
        db.flush()
        for order, (stop_name, latitude, longitude) in enumerate(definition["stops"]):
            route.stops.append(
                RouteStop(
                    id=uuid4(),
                    stop_name=stop_name,
                    latitude=latitude,
                    longitude=longitude,
                    stop_order=order,
                )
            )
    db.commit()


def main() -> None:
    initialize_database()
    with SessionLocal() as db:
        seed_demo(db)
    print("Cuentas demo y 10 rutas de Monterrey creadas o actualizadas.")


if __name__ == "__main__":
    main()
