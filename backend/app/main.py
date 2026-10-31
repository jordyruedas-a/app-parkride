from datetime import datetime, timedelta
from uuid import UUID, uuid4

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import exists, or_, update
from sqlalchemy.orm import Session, selectinload

from app.auth import create_access_token, get_current_user, hash_password, require_roles, verify_password
from app.config import CORS_ORIGINS, QR_VALIDITY_MINUTES
from app.database import get_db, initialize_database
from app.models import QRToken, Report, Route, RouteStop, Trip, User, Vehicle
from app.schemas import (
    AuthLogin,
    QRTokenResponse,
    QRValidationRequest,
    ReportCreate,
    ReportResponse,
    RouteAssignment,
    RouteCreate,
    RouteResponse,
    RouteUpdate,
    TripCreate,
    TripResponse,
    UserCreate,
    UserResponse,
    UserUpdate,
    VehicleCreate,
    VehicleResponse,
)

app = FastAPI(title="ParkRide API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

initialize_database()


def _utcnow() -> datetime:
    """Keep stored timestamps timezone-naive UTC for SQLite/PostgreSQL parity."""
    return datetime.utcnow()


def _get_route_or_404(route_id: UUID, db: Session) -> Route:
    route = (
        db.query(Route)
        .options(selectinload(Route.stops), selectinload(Route.driver), selectinload(Route.vehicle))
        .filter(Route.id == route_id)
        .first()
    )
    if route is None:
        raise HTTPException(status_code=404, detail="Route not found")
    return route


def _validate_driver_assignment(driver_id: UUID, route: Route, db: Session) -> User:
    driver = db.query(User).filter(User.id == driver_id, User.is_active.is_(True)).first()
    if driver is None or driver.role != "route_driver":
        raise HTTPException(status_code=400, detail="Assigned driver must be an active route_driver")
    other_route = db.query(Route).filter(Route.driver_id == driver.id, Route.id != route.id).first()
    if other_route is not None:
        raise HTTPException(status_code=409, detail="Driver is already assigned to another route")
    return driver


def _create_vehicle(payload: VehicleCreate, db: Session) -> Vehicle:
    existing = db.query(Vehicle).filter(Vehicle.plate == payload.plate.upper()).first()
    if existing is not None:
        raise HTTPException(status_code=409, detail="Vehicle plate is already registered")
    vehicle = Vehicle(
        id=uuid4(),
        model=payload.model,
        plate=payload.plate.upper(),
        color=payload.color,
        transport_type=payload.transport_type,
        is_active=True,
    )
    db.add(vehicle)
    db.flush()
    return vehicle


def _validate_vehicle_assignment(vehicle: Vehicle, route: Route, db: Session) -> Vehicle:
    if not vehicle.is_active:
        raise HTTPException(status_code=400, detail="Assigned vehicle must be active")
    if vehicle.transport_type != route.transport_type:
        raise HTTPException(status_code=422, detail="Vehicle transport type must match the route")
    other_route = db.query(Route).filter(Route.vehicle_id == vehicle.id, Route.id != route.id).first()
    if other_route is not None:
        raise HTTPException(status_code=409, detail="Vehicle is already assigned to another route")
    return vehicle


def _assign_route_resources(
    route: Route,
    db: Session,
    *,
    driver_id: UUID | None = None,
    set_driver: bool = False,
    vehicle_id: UUID | None = None,
    vehicle: VehicleCreate | None = None,
    set_vehicle: bool = False,
) -> None:
    if set_driver:
        route.driver_id = (
            _validate_driver_assignment(driver_id, route, db).id if driver_id is not None else None
        )
    if vehicle is not None:
        vehicle_id = _create_vehicle(vehicle, db).id
        set_vehicle = True
    if set_vehicle:
        if vehicle_id is None:
            route.vehicle_id = None
        else:
            assigned_vehicle = db.query(Vehicle).filter(Vehicle.id == vehicle_id).first()
            if assigned_vehicle is None:
                raise HTTPException(status_code=404, detail="Vehicle not found")
            route.vehicle_id = _validate_vehicle_assignment(assigned_vehicle, route, db).id


def _validate_stops(stops: list) -> None:
    if len({stop.stop_order for stop in stops}) != len(stops):
        raise HTTPException(status_code=422, detail="Route stop orders must be unique")


def _ensure_route_access(route: Route, current_user: User) -> None:
    if current_user.role == "supervisor":
        return
    if current_user.role == "route_driver":
        if not route.is_active or route.driver_id != current_user.id:
            raise HTTPException(status_code=403, detail="You may only access your assigned active route")
        return
    if not route.is_active:
        raise HTTPException(status_code=404, detail="Route not found")


def _issue_qr(trip: Trip, db: Session) -> QRTokenResponse:
    now = _utcnow()
    expires_at = now + timedelta(seconds=900)
    db.execute(
        update(QRToken)
        .where(QRToken.trip_id == trip.id, QRToken.used.is_(False))
        .values(expires_at=now)
    )
    token = QRToken(id=uuid4(), trip_id=trip.id, token=uuid4(), expires_at=expires_at, used=False)
    db.add(token)
    trip.qr_token = token.token
    trip.qr_expires_at = expires_at
    db.commit()
    return QRTokenResponse(trip_id=trip.id, token=token.token, expires_at=expires_at)


def _create_trip_with_qr(payload: TripCreate, db: Session, passenger: User) -> QRTokenResponse:
    if payload.passenger_id is not None and payload.passenger_id != passenger.id:
        raise HTTPException(status_code=403, detail="A passenger may only create their own trip")

    route = _get_route_or_404(payload.route_id, db)
    if not route.is_active or not route.is_available:
        raise HTTPException(status_code=409, detail="Route is not available")
    if route.driver_id is None:
        raise HTTPException(status_code=409, detail="Route has no assigned driver")

    trip = Trip(
        id=uuid4(),
        passenger_id=passenger.id,
        driver_id=route.driver_id,
        route_id=route.id,
        transport_type=route.transport_type,
        status="requested",
        origin=payload.origin,
        destination=payload.destination,
        credit_cost=payload.credit_cost,
    )
    db.add(trip)
    db.flush()
    return _issue_qr(trip, db)


@app.get("/")
def health_check():
    return {"status": "ok", "service": "ParkRide API"}


@app.get("/health")
def ping():
    return {"status": "healthy"}


@app.post("/auth/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(payload: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email.lower()).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    if payload.role == "supervisor" and db.query(User).filter(User.role == "supervisor").first():
        raise HTTPException(status_code=403, detail="Only the initial supervisor can self-register")

    user = User(
        id=uuid4(),
        email=payload.email.lower(),
        password_hash=hash_password(payload.password),
        name=payload.name,
        role=payload.role,
        company=payload.company,
        department=payload.department,
        employee_number=payload.employee_number,
        phone=payload.phone,
        shift=payload.shift,
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@app.post("/auth/login")
def login(payload: AuthLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email.lower()).first()
    if not user or not user.is_active or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {
        "access_token": create_access_token(user.id),
        "token_type": "bearer",
        "user": UserResponse.model_validate(user).model_dump(mode="json"),
    }


@app.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@app.get("/users", response_model=list[UserResponse])
def list_users(
    db: Session = Depends(get_db),
    _: User = Depends(require_roles("supervisor")),
):
    return db.query(User).order_by(User.created_at).all()


@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.id != user_id and current_user.role != "supervisor":
        raise HTTPException(status_code=403, detail="You may only access your own profile")
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@app.put("/users/{user_id}", response_model=UserResponse)
def update_user(
    user_id: UUID,
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.id != user_id and current_user.role != "supervisor":
        raise HTTPException(status_code=403, detail="You may only update your own profile")
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    changes = payload.model_dump(exclude_unset=True)
    if "email" in changes:
        email = changes["email"].lower()
        duplicate = db.query(User).filter(User.email == email, User.id != user_id).first()
        if duplicate:
            raise HTTPException(status_code=400, detail="Email already registered")
        user.email = email
    if "password" in changes:
        user.password_hash = hash_password(changes.pop("password"))
    for field, value in changes.items():
        if field != "email":
            setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user


@app.post("/routes", response_model=RouteResponse, status_code=status.HTTP_201_CREATED)
def create_route(
    payload: RouteCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_roles("supervisor")),
):
    route = Route(
        id=uuid4(),
        name=payload.name,
        origin=payload.origin,
        destination=payload.destination,
        departure_time=payload.departure_time,
        transport_type=payload.transport_type,
        color=payload.color,
        is_active=payload.is_active,
        is_available=payload.is_available,
    )
    db.add(route)
    db.flush()
    _assign_route_resources(
        route,
        db,
        driver_id=payload.driver_id,
        set_driver=payload.driver_id is not None,
        vehicle_id=payload.vehicle_id,
        vehicle=payload.vehicle,
        set_vehicle=payload.vehicle_id is not None or payload.vehicle is not None,
    )
    _validate_stops(payload.stops)
    for stop in payload.stops:
        db.add(
            RouteStop(
                id=uuid4(),
                route_id=route.id,
                stop_name=stop.stop_name,
                latitude=stop.latitude,
                longitude=stop.longitude,
                stop_order=stop.stop_order,
            )
        )
    db.commit()
    return _get_route_or_404(route.id, db)


@app.put("/routes/{route_id}", response_model=RouteResponse)
def update_route(
    route_id: UUID,
    payload: RouteUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_roles("supervisor")),
):
    route = _get_route_or_404(route_id, db)
    changes = payload.model_dump(exclude_unset=True, exclude={"stops", "driver_id", "vehicle_id", "vehicle"})
    for field, value in changes.items():
        setattr(route, field, value)

    fields_set = payload.model_fields_set
    _assign_route_resources(
        route,
        db,
        driver_id=payload.driver_id,
        set_driver="driver_id" in fields_set,
        vehicle_id=payload.vehicle_id,
        vehicle=payload.vehicle,
        set_vehicle="vehicle_id" in fields_set or payload.vehicle is not None,
    )
    if payload.stops is not None:
        _validate_stops(payload.stops)
        route.stops.clear()
        db.flush()
        for stop in payload.stops:
            route.stops.append(
                RouteStop(
                    id=uuid4(),
                    stop_name=stop.stop_name,
                    latitude=stop.latitude,
                    longitude=stop.longitude,
                    stop_order=stop.stop_order,
                )
            )
    if route.vehicle_id is not None:
        db.flush()
        assigned_vehicle = db.query(Vehicle).filter(Vehicle.id == route.vehicle_id).one()
        _validate_vehicle_assignment(assigned_vehicle, route, db)
    db.commit()
    return _get_route_or_404(route.id, db)


@app.post("/routes/{route_id}/assign", response_model=RouteResponse)
def assign_route_driver(
    route_id: UUID,
    payload: RouteAssignment,
    db: Session = Depends(get_db),
    _: User = Depends(require_roles("supervisor")),
):
    route = _get_route_or_404(route_id, db)
    _assign_route_resources(
        route,
        db,
        driver_id=payload.driver_id,
        set_driver=payload.driver_id is not None,
        vehicle_id=payload.vehicle_id,
        vehicle=payload.vehicle,
        set_vehicle=payload.vehicle_id is not None or payload.vehicle is not None,
    )
    db.commit()
    return _get_route_or_404(route.id, db)


@app.get("/routes", response_model=list[RouteResponse])
def list_routes(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    query = db.query(Route).options(
        selectinload(Route.stops), selectinload(Route.driver), selectinload(Route.vehicle)
    )
    if current_user.role == "route_driver":
        query = query.filter(Route.driver_id == current_user.id, Route.is_active.is_(True))
    elif current_user.role == "passenger":
        query = query.filter(Route.is_active.is_(True))
    return query.order_by(Route.departure_time, Route.name).all()


@app.get("/vehicles", response_model=list[VehicleResponse])
def list_vehicles(
    db: Session = Depends(get_db),
    _: User = Depends(require_roles("supervisor")),
):
    return db.query(Vehicle).order_by(Vehicle.plate).all()


@app.get("/routes/{route_id}", response_model=RouteResponse)
def get_route(route_id: UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    route = _get_route_or_404(route_id, db)
    _ensure_route_access(route, current_user)
    return route


@app.post("/trips", response_model=QRTokenResponse, status_code=status.HTTP_201_CREATED)
def create_trip(
    payload: TripCreate,
    db: Session = Depends(get_db),
    passenger: User = Depends(require_roles("passenger")),
):
    return _create_trip_with_qr(payload, db, passenger)


@app.post("/qr/generate", status_code=status.HTTP_201_CREATED)
def generate_qr_for_trip(
    payload: TripCreate,
    db: Session = Depends(get_db),
    passenger: User = Depends(require_roles("passenger")),
):
    qr = _create_trip_with_qr(payload, db, passenger)
    return {
        **qr.model_dump(mode="json"),
        "qr_token": str(qr.token),
        "status": "generated",
    }


@app.post("/trips/{trip_id}/qr", response_model=QRTokenResponse)
def regenerate_qr(
    trip_id: UUID,
    db: Session = Depends(get_db),
    passenger: User = Depends(require_roles("passenger")),
):
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.passenger_id == passenger.id).first()
    if trip is None:
        raise HTTPException(status_code=404, detail="Trip not found")
    route = _get_route_or_404(trip.route_id, db)
    if not route.is_active or not route.is_available or route.driver_id is None:
        raise HTTPException(status_code=409, detail="Trip route is not available")
    return _issue_qr(trip, db)


@app.get("/trips", response_model=list[TripResponse])
def list_trips(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    query = db.query(Trip)
    if current_user.role == "passenger":
        query = query.filter(Trip.passenger_id == current_user.id)
    elif current_user.role == "route_driver":
        query = query.join(Route, Trip.route_id == Route.id).filter(
            Route.driver_id == current_user.id,
            Route.is_active.is_(True),
        )
    return query.order_by(Trip.created_at.desc()).all()


@app.post("/qr/validate")
def validate_qr(
    payload: QRValidationRequest,
    db: Session = Depends(get_db),
    driver: User = Depends(require_roles("route_driver")),
):
    if payload.driver_id is not None and payload.driver_id != driver.id:
        raise HTTPException(status_code=403, detail="Driver identity does not match the access token")

    token = db.query(QRToken).filter(QRToken.token == payload.token).first()
    if token is None:
        raise HTTPException(status_code=404, detail="QR token not found")
    now = _utcnow()
    if token.used:
        raise HTTPException(status_code=409, detail="QR already used")
    if token.expires_at <= now:
        raise HTTPException(status_code=410, detail="QR expired")

    trip = db.query(Trip).filter(Trip.id == token.trip_id).first()
    if trip is None or trip.passenger_id is None or trip.route_id is None:
        raise HTTPException(status_code=404, detail="Trip not found")
    passenger = db.query(User).filter(User.id == trip.passenger_id, User.role == "passenger").first()
    route = db.query(Route).filter(Route.id == trip.route_id).first()
    if (
        passenger is None
        or route is None
        or not route.is_active
        or not route.is_available
        or route.driver_id != driver.id
    ):
        raise HTTPException(status_code=403, detail="QR is not valid for this driver's route")
    if trip.driver_id is not None and trip.driver_id != driver.id:
        raise HTTPException(status_code=403, detail="Trip is not assigned to this driver")

    valid_route_trip = exists().where(
        Trip.id == QRToken.trip_id,
        Trip.passenger_id == User.id,
        User.role == "passenger",
        Route.id == Trip.route_id,
        Route.is_active.is_(True),
        Route.is_available.is_(True),
        Route.driver_id == driver.id,
        or_(Trip.driver_id.is_(None), Trip.driver_id == driver.id),
    )
    consumed = db.execute(
        update(QRToken)
        .where(
            QRToken.id == token.id,
            QRToken.used.is_(False),
            QRToken.expires_at > now,
            valid_route_trip,
        )
        .values(used=True, used_by_driver_id=driver.id)
    )
    if consumed.rowcount != 1:
        db.rollback()
        raise HTTPException(status_code=409, detail="QR has already been consumed or expired")
    trip.status = "completed"
    trip.completed_at = now
    trip.used_at = now
    db.commit()
    return {"valid": True, "trip_id": str(trip.id), "status": "completed"}


@app.post("/reports", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
def submit_report(
    payload: ReportCreate,
    db: Session = Depends(get_db),
    reporter: User = Depends(get_current_user),
):
    report = Report(
        id=uuid4(),
        reporter_id=reporter.id,
        reporter_role=reporter.role,
        category=payload.category,
        comment=payload.comment,
        status="open",
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report


@app.get("/reports", response_model=list[ReportResponse])
def list_reports(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    query = db.query(Report)
    if current_user.role != "supervisor":
        query = query.filter(Report.reporter_id == current_user.id)
    return query.order_by(Report.created_at.desc()).all()


@app.post("/reports/{report_id}/resolve", response_model=ReportResponse)
def resolve_report(
    report_id: UUID,
    db: Session = Depends(get_db),
    supervisor: User = Depends(require_roles("supervisor")),
):
    report = db.query(Report).filter(Report.id == report_id).first()
    if report is None:
        raise HTTPException(status_code=404, detail="Report not found")
    if report.status == "resolved":
        raise HTTPException(status_code=409, detail="Report is already resolved")
    report.status = "resolved"
    report.resolved_by_id = supervisor.id
    report.resolved_at = _utcnow()
    db.commit()
    db.refresh(report)
    return report
