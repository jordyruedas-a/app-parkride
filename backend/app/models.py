from datetime import datetime

from sqlalchemy import Boolean, CheckConstraint, Column, DateTime, Double, ForeignKey, Integer, String, Text, Time, UniqueConstraint, Uuid
from sqlalchemy.orm import relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False)
    company = Column(String(255))
    department = Column(String(255))
    employee_number = Column(String(255))
    phone = Column(String(50))
    shift = Column(String(50))
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)


class Route(Base):
    __tablename__ = "routes"
    __table_args__ = (
        CheckConstraint("transport_type IN ('bus', 'van')", name="ck_routes_transport_type"),
        UniqueConstraint("driver_id", name="uq_routes_driver_id"),
        UniqueConstraint("vehicle_id", name="uq_routes_vehicle_id"),
    )

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    origin = Column(String(255), nullable=False)
    destination = Column(String(255), nullable=False)
    departure_time = Column(Time, nullable=False)
    transport_type = Column(String(20), nullable=False, default="bus")
    color = Column(String(7), nullable=False, default="#1D4ED8")
    driver_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"))
    vehicle_id = Column(Uuid(as_uuid=True), ForeignKey("vehicles.id"))
    is_active = Column(Boolean, default=True, nullable=False)
    is_available = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    driver = relationship("User", foreign_keys=[driver_id])
    vehicle = relationship("Vehicle", back_populates="route", foreign_keys=[vehicle_id])
    stops = relationship(
        "RouteStop",
        back_populates="route",
        cascade="all, delete-orphan",
        order_by="RouteStop.stop_order",
    )


class Vehicle(Base):
    __tablename__ = "vehicles"
    __table_args__ = (
        CheckConstraint("transport_type IN ('bus', 'van')", name="ck_vehicles_transport_type"),
    )

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    model = Column(String(255), nullable=False)
    plate = Column(String(50), unique=True, nullable=False, index=True)
    color = Column(String(50), nullable=False)
    transport_type = Column(String(20), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    route = relationship("Route", back_populates="vehicle", uselist=False)


class RouteStop(Base):
    __tablename__ = "route_stops"

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    route_id = Column(Uuid(as_uuid=True), ForeignKey("routes.id"), nullable=False)
    stop_name = Column(String(255), nullable=False)
    latitude = Column(Double, nullable=False)
    longitude = Column(Double, nullable=False)
    stop_order = Column(Integer, nullable=False)

    route = relationship("Route", back_populates="stops")


class Trip(Base):
    __tablename__ = "trips"

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    passenger_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False)
    driver_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"))
    route_id = Column(Uuid(as_uuid=True), ForeignKey("routes.id"), nullable=False)
    transport_type = Column(String(50), nullable=False)
    status = Column(String(30), nullable=False, default="requested")
    origin = Column(String(255))
    destination = Column(String(255))
    credit_cost = Column(Integer, default=0, nullable=False)
    qr_token = Column(Uuid(as_uuid=True))
    qr_expires_at = Column(DateTime)
    used_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    completed_at = Column(DateTime)

    route = relationship("Route", foreign_keys=[route_id])
    passenger = relationship("User", foreign_keys=[passenger_id])
    driver = relationship("User", foreign_keys=[driver_id])


class QRToken(Base):
    __tablename__ = "qr_tokens"

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    trip_id = Column(Uuid(as_uuid=True), ForeignKey("trips.id"), nullable=False, index=True)
    token = Column(Uuid(as_uuid=True), unique=True, nullable=False, index=True)
    issued_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    used = Column(Boolean, default=False, nullable=False)
    used_by_driver_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"))


class Report(Base):
    __tablename__ = "reports"

    id = Column(Uuid(as_uuid=True), primary_key=True, index=True)
    reporter_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    reporter_role = Column(String(50), nullable=False)
    category = Column(String(100), nullable=False)
    comment = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    status = Column(String(30), default="open", nullable=False, index=True)
    resolved_by_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"))
    resolved_at = Column(DateTime)
