-- Fresh PostgreSQL bootstrap schema. Existing deployments should use a reviewed migration.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('passenger', 'route_driver', 'supervisor')),
    company VARCHAR(255),
    department VARCHAR(255),
    employee_number VARCHAR(255),
    phone VARCHAR(50),
    shift VARCHAR(50),
    is_volunteer_driver BOOLEAN NOT NULL DEFAULT FALSE,
    carpool_avenues JSON NOT NULL DEFAULT '[]',
    carpool_vehicles JSON NOT NULL DEFAULT '[]',
    is_available_for_carpooling BOOLEAN NOT NULL DEFAULT FALSE,
    carpool_destination VARCHAR(255),
    carpool_route JSON NOT NULL DEFAULT '[]',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model VARCHAR(255) NOT NULL,
    plate VARCHAR(50) UNIQUE NOT NULL,
    color VARCHAR(50) NOT NULL,
    transport_type VARCHAR(20) NOT NULL CHECK (transport_type IN ('bus', 'van')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    departure_time TIME NOT NULL,
    transport_type VARCHAR(20) NOT NULL CHECK (transport_type IN ('bus', 'van')),
    color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),
    driver_id UUID UNIQUE REFERENCES users(id),
    vehicle_id UUID UNIQUE REFERENCES vehicles(id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    return_stops JSON NOT NULL DEFAULT '[]',
    return_color VARCHAR(7) NOT NULL DEFAULT '#F97316',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS route_stops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    stop_name VARCHAR(255) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    stop_order INTEGER NOT NULL,
    UNIQUE (route_id, stop_order)
);

CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id UUID NOT NULL REFERENCES users(id),
    driver_id UUID REFERENCES users(id),
    route_id UUID NOT NULL REFERENCES routes(id),
    transport_type VARCHAR(50) NOT NULL CHECK (transport_type IN ('shuttle', 'van', 'carpool')),
    status VARCHAR(30) NOT NULL DEFAULT 'requested',
    origin VARCHAR(255),
    destination VARCHAR(255),
    credit_cost INTEGER NOT NULL DEFAULT 0 CHECK (credit_cost >= 0),
    qr_token UUID,
    qr_expires_at TIMESTAMP,
    used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS qr_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    token UUID NOT NULL UNIQUE,
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    used_by_driver_id UUID REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS carpool_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id UUID NOT NULL REFERENCES users(id),
    volunteer_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'accepted', 'rejected')),
    origin VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES users(id),
    reporter_role VARCHAR(50) NOT NULL CHECK (reporter_role IN ('passenger', 'route_driver', 'supervisor')),
    category VARCHAR(100) NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
    resolved_by_id UUID REFERENCES users(id),
    resolved_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_routes_driver_active ON routes(driver_id, is_active);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_passenger ON trips(passenger_id);
CREATE INDEX IF NOT EXISTS idx_qr_tokens_token ON qr_tokens(token);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
