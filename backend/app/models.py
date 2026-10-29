from datetime import datetime
from typing import Optional
from uuid import UUID

from sqlalchemy import Boolean, Column, DateTime, Double, ForeignKey, Integer, String, Time, Text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import relationship

from app.database import Base


class User(Base):
    __tablename__ = 'users'
    id = Column(PGUUID(as_uuid=True), primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False)
    company = Column(String(255), nullable=True)
    department = Column(String(255), nullable=True)
    employee_number = Column(String(255), nullable=True)
    phone = Column(String(50), nullable=True)
    shift = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = Column(Boolean, default=True)


class Route(Base):
    __tablename__ = 'routes'
    id = Column(PGUUID(as_uuid=True), primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    origin = Column(String(255), nullable=False)
    destination = Column(String(255), nullable=False)
    departure_time = Column(Time, nullable=False)
    driver_id = Column(PGUUID(as_uuid=True), ForeignKey('users.id'), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    stops = relationship('RouteStop', back_populates='route', cascade='all, delete-orphan')


class RouteStop(Base):
    __tablename__ = 'route_stops'
    id = Column(PGUUID(as_uuid=True), primary_key=True, index=True)
    route_id = Column(PGUUID(as_uuid=True), ForeignKey('routes.id'), nullable=False)
    stop_name = Column(String(255), nullable=False)
    latitude = Column(Double, nullable=False)
    longitude = Column(Double, nullable=False)
    stop_order = Column(Integer, nullable=False)
    route = relationship('Route', back_populates='stops')


class Trip(Base):
    __tablename__ = 'trips'
    id = Column(PGUUID(as_uuid=True), primary_key=True, index=True)
    passenger_id = Column(PGUUID(as_uuid=True), ForeignKey('users.id'), nullable=True)
    driver_id = Column(PGUUID(as_uuid=True), ForeignKey('users.id'), nullable=True)
    route_id = Column(PGUUID(as_uuid=True), ForeignKey('routes.id'), nullable=True)
    transport_type = Column(String(50), nullable=False)
    status = Column(String(30), nullable=False, default='requested')
    origin = Column(String(255), nullable=True)
    destination = Column(String(255), nullable=True)
    credit_cost = Column(Integer, default=0)
    qr_token = Column(PGUUID(as_uuid=True), nullable=True)
    qr_expires_at = Column(DateTime, nullable=True)
    used_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)


class QRToken(Base):
    __tablename__ = 'qr_tokens'
    id = Column(PGUUID(as_uuid=True), primary_key=True, index=True)
    trip_id = Column(PGUUID(as_uuid=True), ForeignKey('trips.id'), nullable=False)
    token = Column(PGUUID(as_uuid=True), unique=True, nullable=False)
    issued_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)
    used = Column(Boolean, default=False)
    used_by_driver_id = Column(PGUUID(as_uuid=True), ForeignKey('users.id'), nullable=True)
