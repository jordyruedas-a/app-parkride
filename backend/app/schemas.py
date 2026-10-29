from datetime import datetime, time
from uuid import UUID
from typing import Optional, Literal

from pydantic import BaseModel, Field, EmailStr


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    name: str
    role: Literal['passenger', 'driver', 'admin']
    company: Optional[str] = None
    department: Optional[str] = None
    employee_number: Optional[str] = None
    phone: Optional[str] = None
    shift: Optional[str] = None


class UserResponse(BaseModel):
    id: UUID
    email: EmailStr
    name: str
    role: str
    company: Optional[str] = None
    department: Optional[str] = None
    employee_number: Optional[str] = None
    phone: Optional[str] = None
    shift: Optional[str] = None

    class Config:
        from_attributes = True


class AuthLogin(BaseModel):
    email: EmailStr
    password: str


class RouteStopCreate(BaseModel):
    stop_name: str
    latitude: float
    longitude: float
    stop_order: int


class RouteCreate(BaseModel):
    name: str
    origin: str
    destination: str
    departure_time: time
    driver_id: Optional[UUID] = None
    stops: list[RouteStopCreate] = []


class RouteResponse(RouteCreate):
    id: UUID


class TripCreate(BaseModel):
    passenger_id: UUID
    driver_id: Optional[UUID] = None
    route_id: Optional[UUID] = None
    transport_type: Literal['shuttle', 'van', 'carpool']
    origin: Optional[str] = None
    destination: Optional[str] = None
    credit_cost: int = 0


class TripResponse(BaseModel):
    id: UUID
    passenger_id: Optional[UUID]
    driver_id: Optional[UUID]
    route_id: Optional[UUID]
    transport_type: str
    status: str
    origin: Optional[str]
    destination: Optional[str]
    credit_cost: int
    qr_token: Optional[UUID]
    qr_expires_at: Optional[datetime]
    created_at: datetime
    completed_at: Optional[datetime]

    class Config:
        from_attributes = True


class QRValidationRequest(BaseModel):
    token: UUID
    driver_id: UUID
