# ParkRide Backend

FastAPI service for managed ParkRide routes, passenger trips, single-use QR boarding, and operational reports. SQLite is the local default; the SQLAlchemy UUID mapping also supports PostgreSQL.

## Run on Windows

From this `backend` folder in PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env   # if present; otherwise create .env below
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Create `.env` when needed:

```env
DATABASE_URL=sqlite:///./parkride.db
JWT_SECRET=replace-with-a-long-random-secret
JWT_ALGORITHM=HS256
QR_VALIDITY_MINUTES=15
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

Open `http://127.0.0.1:8000/docs` for the interactive API. For PostgreSQL, set `DATABASE_URL` to a SQLAlchemy PostgreSQL URL and bootstrap a new database with `database\schema.sql`. Startup creates fresh tables and safely adds route transport, color, availability, and vehicle-reference columns to existing SQLite/PostgreSQL databases; review and apply the SQL schema separately for production constraints.

## Local demo data

Populate local development data with:

```powershell
python seed_demo.py
```

The script is idempotent and creates or refreshes 10 named Monterrey routes (five buses and five vans), each with three ordered map stops, an assigned driver, and an assigned vehicle. The local demo accounts use password `123`: `pasajero@parkride.com`, `chofer@parkride.com`, and `supervisor@parkride.com`.

## Roles and workflow

Canonical roles are `passenger`, `route_driver`, and `supervisor`. Legacy registration values `driver` and `admin` are mapped to `route_driver` and `supervisor`. The first supervisor can register; later supervisor accounts should be provisioned administratively.

1. A supervisor creates or updates a route (`POST/PUT /routes`) with `transport_type` (`bus` or `van`), hex `color`, active/availability flags, ordered stops, and optional full vehicle data. `POST /routes/{route_id}/assign` assigns a driver and/or vehicle.
2. A passenger creates a route-bound trip (`POST /trips`) and receives a UUID token valid for 15 minutes. The trip uses its route's transport type. `POST /trips/{trip_id}/qr` replaces an unconsumed token.
3. The assigned route driver presents their bearer token to `POST /qr/validate`. Validation checks the active, available route, passenger trip, expiration, and one-time use before consuming the QR.

## Endpoint overview

- `POST /auth/register`, `POST /auth/login`, `GET /me`
- `GET/PUT /users/{user_id}` (self or supervisor), `GET /users` (supervisor)
- `POST/GET /routes`, `GET/PUT /routes/{route_id}`, `POST /routes/{route_id}/assign`, `GET /vehicles` (supervisor)
- `POST/GET /trips`, `POST /trips/{trip_id}/qr`, `POST /qr/generate` (legacy-compatible trip-and-QR creation), `POST /qr/validate`
- `POST/GET /reports`, `POST /reports/{report_id}/resolve`

All route, trip, report, and QR operations require a bearer access token. Route lists include ordered stops plus transport, color, availability, driver, and vehicle data needed for map rendering. Drivers can list or retrieve only their own active routes.

## Tests

```powershell
pytest -q
```

The test suite uses an isolated in-memory SQLite database and covers authentication/authorization, full route and vehicle data, driver scoping, idempotent ten-route seed data, QR expiration/reuse/cross-route rejection, and report resolution.
