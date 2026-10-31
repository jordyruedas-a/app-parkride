from datetime import datetime, time
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator, model_validator

Role = Literal["passenger", "route_driver", "supervisor"]
TransportType = Literal["bus", "van"]
COLOR_HEX_PATTERN = r"^#[0-9A-Fa-f]{6}$"


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=3, max_length=72)
    name: str = Field(..., min_length=1, max_length=255)
    role: Role | Literal["driver", "admin"]
    company: str | None = None
    department: str | None = None
    employee_number: str | None = None
    phone: str | None = None
    shift: str | None = None

    @field_validator("role")
    @classmethod
    def normalize_legacy_roles(cls, value: str) -> str:
        return {"driver": "route_driver", "admin": "supervisor"}.get(value, value)

    @field_validator("password")
    @classmethod
    def limit_bcrypt_password_bytes(cls, value: str) -> str:
        if len(value.encode("utf-8")) > 72:
            raise ValueError("Password must be at most 72 UTF-8 bytes")
        return value


class UserUpdate(BaseModel):
    email: EmailStr | None = None
    password: str | None = Field(default=None, min_length=3, max_length=72)
    name: str | None = Field(default=None, min_length=1, max_length=255)
    company: str | None = None
    department: str | None = None
    employee_number: str | None = None
    phone: str | None = None
    shift: str | None = None
    is_volunteer_driver: bool | None = None
    carpool_avenues: list[str] | None = None
    carpool_vehicles: list[dict] | None = None
    is_available_for_carpooling: bool | None = None
    carpool_destination: str | None = None
    carpool_route: list[dict] | None = None

    @field_validator("password")
    @classmethod
    def limit_bcrypt_password_bytes(cls, value: str | None) -> str | None:
        if value is not None and len(value.encode("utf-8")) > 72:
            raise ValueError("Password must be at most 72 UTF-8 bytes")
        return value


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: EmailStr
    name: str
    role: Role
    company: str | None = None
    department: str | None = None
    employee_number: str | None = None
    phone: str | None = None
    shift: str | None = None
    is_volunteer_driver: bool
    carpool_avenues: list[str] = Field(default_factory=list)
    carpool_vehicles: list[dict] = Field(default_factory=list)
    is_available_for_carpooling: bool
    carpool_destination: str | None = None
    carpool_route: list[dict] = Field(default_factory=list)


class AuthLogin(BaseModel):
    email: EmailStr
    password: str


class RouteStopCreate(BaseModel):
    stop_name: str = Field(..., min_length=1, max_length=255)
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    stop_order: int = Field(..., ge=0)


class RouteStopResponse(RouteStopCreate):
    model_config = ConfigDict(from_attributes=True)

    id: UUID


class VehicleCreate(BaseModel):
    model: str = Field(..., min_length=1, max_length=255)
    plate: str = Field(..., min_length=1, max_length=50)
    color: str = Field(..., min_length=1, max_length=50)
    transport_type: TransportType


class VehicleResponse(VehicleCreate):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    is_active: bool


class RouteCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    origin: str = Field(..., min_length=1, max_length=255)
    destination: str = Field(..., min_length=1, max_length=255)
    departure_time: time
    transport_type: TransportType = "bus"
    color: str = Field(default="#1D4ED8", pattern=COLOR_HEX_PATTERN)
    driver_id: UUID | None = None
    vehicle_id: UUID | None = None
    vehicle: VehicleCreate | None = None
    is_active: bool = True
    is_available: bool = True
    stops: list[RouteStopCreate] = Field(default_factory=list)

    @model_validator(mode="after")
    def avoid_multiple_vehicle_assignments(self):
        if self.vehicle_id is not None and self.vehicle is not None:
            raise ValueError("Provide either vehicle_id or vehicle details, not both")
        return self


class RouteAssignment(BaseModel):
    driver_id: UUID | None = None
    vehicle_id: UUID | None = None
    vehicle: VehicleCreate | None = None

    @model_validator(mode="after")
    def require_assignment(self):
        if self.driver_id is None and self.vehicle_id is None and self.vehicle is None:
            raise ValueError("Provide a driver_id, vehicle_id, or vehicle details")
        if self.vehicle_id is not None and self.vehicle is not None:
            raise ValueError("Provide either vehicle_id or vehicle details, not both")
        return self


class RouteUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    origin: str | None = Field(default=None, min_length=1, max_length=255)
    destination: str | None = Field(default=None, min_length=1, max_length=255)
    departure_time: time | None = None
    transport_type: TransportType | None = None
    color: str | None = Field(default=None, pattern=COLOR_HEX_PATTERN)
    driver_id: UUID | None = None
    vehicle_id: UUID | None = None
    vehicle: VehicleCreate | None = None
    is_active: bool | None = None
    is_available: bool | None = None
    stops: list[RouteStopCreate] | None = None

    @model_validator(mode="after")
    def avoid_multiple_vehicle_assignments(self):
        if self.vehicle_id is not None and self.vehicle is not None:
            raise ValueError("Provide either vehicle_id or vehicle details, not both")
        return self


class RouteDriverResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str


class RouteResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    origin: str
    destination: str
    departure_time: time
    transport_type: TransportType
    color: str
    driver_id: UUID | None
    vehicle_id: UUID | None
    is_active: bool
    is_available: bool
    return_stops: list[dict] = Field(default_factory=list)
    return_color: str
    created_at: datetime
    driver: RouteDriverResponse | None = None
    vehicle: VehicleResponse | None = None
    stops: list[RouteStopResponse] = Field(default_factory=list)


class TripCreate(BaseModel):
    # passenger_id and driver_id remain accepted for older clients, but are never trusted.
    passenger_id: UUID | None = None
    driver_id: UUID | None = None
    route_id: UUID
    transport_type: Literal["bus", "van", "shuttle", "carpool"] | None = None
    origin: str | None = None
    destination: str | None = None
    credit_cost: int = Field(default=0, ge=0)


class TripResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    passenger_id: UUID
    driver_id: UUID | None
    route_id: UUID
    transport_type: str
    status: str
    origin: str | None
    destination: str | None
    credit_cost: int
    qr_token: UUID | None
    qr_expires_at: datetime | None
    created_at: datetime
    completed_at: datetime | None


class QRTokenResponse(BaseModel):
    trip_id: UUID
    token: UUID
    expires_at: datetime


class QRValidationRequest(BaseModel):
    token: UUID
    driver_id: UUID | None = None


class ReportCreate(BaseModel):
    category: str = Field(..., min_length=1, max_length=100)
    comment: str = Field(..., min_length=1, max_length=5000)


class ReportResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    reporter_id: UUID
    reporter_role: Role
    category: str
    comment: str
    created_at: datetime
    status: Literal["open", "resolved"]
    resolved_by_id: UUID | None
    resolved_at: datetime | None
