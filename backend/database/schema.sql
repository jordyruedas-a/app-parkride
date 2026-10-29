CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('passenger', 'driver', 'admin')),
    company VARCHAR(255),
    department VARCHAR(255),
    employee_number VARCHAR(255),
    phone VARCHAR(50),
    shift VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    departure_time TIME NOT NULL,
    driver_id UUID REFERENCES users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS route_stops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID REFERENCES routes(id) ON DELETE CASCADE,
    stop_name VARCHAR(255) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    stop_order INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id UUID REFERENCES users(id),
    driver_id UUID REFERENCES users(id),
    route_id UUID REFERENCES routes(id),
    transport_type VARCHAR(50) NOT NULL CHECK (transport_type IN ('shuttle', 'van', 'carpool')),
    status VARCHAR(30) NOT NULL DEFAULT 'requested',
    origin VARCHAR(255),
    destination VARCHAR(255),
    credit_cost INTEGER NOT NULL DEFAULT 0,
    qr_token UUID,
    qr_expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS qr_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    token UUID NOT NULL UNIQUE,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_by_driver_id UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_qr_tokens_token ON qr_tokens(token);

INSERT INTO users (id, email, password_hash, name, role, company, department, employee_number, phone, shift)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'passenger@parkride.com', 'passenger123', 'Ana García', 'passenger', 'ParkRide', 'Operación', 'EMP-1001', '+52 81 1111 1111', 'Matutino'),
    ('00000000-0000-0000-0000-000000000002', 'driver@parkride.com', 'driver123', 'Luis Moreno', 'driver', 'ParkRide', 'Ruta Norte', 'EMP-2001', '+52 81 2222 2222', 'Vespertino'),
    ('00000000-0000-0000-0000-000000000003', 'admin@parkride.com', 'admin123', 'Valeria Torres', 'admin', 'ParkRide', 'Administración', 'EMP-3001', '+52 81 3333 3333', 'Nocturno')
ON CONFLICT (email) DO NOTHING;
