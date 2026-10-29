from datetime import datetime, timedelta, timezone
from uuid import uuid4

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app.auth import create_access_token, get_current_user, hash_password, verify_password
from app.database import Base, engine, get_db
from app.models import QRToken, Route, RouteStop, Trip, User
from app.schemas import AuthLogin, QRValidationRequest, RouteCreate, TripCreate, UserCreate, UserResponse

app = FastAPI(title='ParkRide API', version='1.0.0')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

Base.metadata.create_all(bind=engine)


@app.get('/')
def health_check():
    return {'status': 'ok', 'service': 'ParkRide API'}


@app.post('/auth/register', response_model=UserResponse)
def register_user(payload: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email.lower()).first()
    if existing:
        raise HTTPException(status_code=400, detail='Email already registered')

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


@app.post('/auth/login')
def login(payload: AuthLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email.lower()).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail='Invalid credentials')

    return {
        'access_token': create_access_token(user.id),
        'token_type': 'bearer',
        'user': {
            'id': str(user.id),
            'email': user.email,
            'name': user.name,
            'role': user.role,
        },
    }


@app.get('/me', response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@app.get('/users')
def list_users(db: Session = Depends(get_db)):
    return db.query(User).all()


@app.get('/users/{user_id}', response_model=UserResponse)
def get_user(user_id, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail='User not found')
    return user


@app.put('/users/{user_id}', response_model=UserResponse)
def update_user(user_id, payload: UserCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail='User not found')

    user.email = payload.email.lower()
    user.name = payload.name
    user.role = payload.role
    user.company = payload.company
    user.department = payload.department
    user.employee_number = payload.employee_number
    user.phone = payload.phone
    user.shift = payload.shift
    if payload.password:
        user.password_hash = hash_password(payload.password)
    db.commit()
    db.refresh(user)
    return user


@app.delete('/users/{user_id}')
def delete_user(user_id, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail='User not found')
    db.delete(user)
    db.commit()
    return {'deleted': True, 'user_id': str(user_id)}


@app.post('/routes', response_model=dict)
def create_route(route: RouteCreate, db: Session = Depends(get_db)):
    route_row = Route(
        id=uuid4(),
        name=route.name,
        origin=route.origin,
        destination=route.destination,
        departure_time=route.departure_time,
        driver_id=str(route.driver_id) if route.driver_id else None,
        is_active=True,
    )
    db.add(route_row)
    db.flush()

    for stop in route.stops:
        db.add(RouteStop(
            id=uuid4(),
            route_id=route_row.id,
            stop_name=stop.stop_name,
            latitude=stop.latitude,
            longitude=stop.longitude,
            stop_order=stop.stop_order,
        ))

    db.commit()
    return {'id': str(route_row.id), 'status': 'created'}


@app.get('/routes')
def list_routes(db: Session = Depends(get_db)):
    return db.query(Route).all()


@app.post('/trips', response_model=dict)
def create_trip(payload: TripCreate, db: Session = Depends(get_db)):
    trip = Trip(
        id=uuid4(),
        passenger_id=payload.passenger_id,
        driver_id=payload.driver_id,
        route_id=payload.route_id,
        transport_type=payload.transport_type,
        status='requested',
        origin=payload.origin,
        destination=payload.destination,
        credit_cost=payload.credit_cost,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)

    expires_at = datetime.now(timezone.utc) + timedelta(minutes=15)
    qr_token = QRToken(
        id=uuid4(),
        trip_id=trip.id,
        token=uuid4(),
        expires_at=expires_at,
        used=False,
    )
    db.add(qr_token)
    db.commit()
    trip.qr_token = qr_token.token
    trip.qr_expires_at = expires_at
    db.commit()
    return {'trip_id': str(trip.id), 'token': str(qr_token.token), 'expires_at': expires_at.isoformat()}


@app.get('/trips')
def list_trips(db: Session = Depends(get_db)):
    return db.query(Trip).all()


@app.post('/qr/validate')
def validate_qr(payload: QRValidationRequest, db: Session = Depends(get_db)):
    token_row = db.query(QRToken).filter(QRToken.token == payload.token).first()
    if not token_row:
        raise HTTPException(status_code=404, detail='QR token not found')
    if token_row.used:
        raise HTTPException(status_code=409, detail='QR already used')
    if datetime.now(timezone.utc) > token_row.expires_at:
        raise HTTPException(status_code=410, detail='QR expired')

    trip = db.query(Trip).filter(Trip.id == token_row.trip_id).first()
    if not trip:
        raise HTTPException(status_code=404, detail='Trip not found')
    if trip.driver_id and trip.driver_id != payload.driver_id:
        raise HTTPException(status_code=403, detail='This QR does not belong to this driver')

    trip.status = 'completed'
    trip.completed_at = datetime.now(timezone.utc)
    token_row.used = True
    token_row.used_by_driver_id = payload.driver_id
    db.commit()
    return {'valid': True, 'trip_id': str(trip.id), 'status': 'completed'}


@app.post('/qr/generate')
def generate_qr_for_trip(payload: TripCreate, db: Session = Depends(get_db)):
    trip = Trip(
        id=uuid4(),
        passenger_id=payload.passenger_id,
        driver_id=payload.driver_id,
        route_id=payload.route_id,
        transport_type=payload.transport_type,
        status='requested',
        origin=payload.origin,
        destination=payload.destination,
        credit_cost=payload.credit_cost,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)

    expires_at = datetime.now(timezone.utc) + timedelta(minutes=15)
    token = QRToken(
        id=uuid4(),
        trip_id=trip.id,
        token=uuid4(),
        expires_at=expires_at,
        used=False,
    )
    db.add(token)
    db.commit()
    db.refresh(token)

    trip.qr_token = token.token
    trip.qr_expires_at = expires_at
    db.commit()
    return {
        'trip_id': str(trip.id),
        'qr_token': str(token.token),
        'expires_at': expires_at.isoformat(),
        'status': 'generated',
    }


@app.get('/health')
def ping():
    return {'status': 'healthy'}
