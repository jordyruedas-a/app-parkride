# ParkRide Backend

## Stack

- Python 3.12+
- FastAPI + Uvicorn
- SQLAlchemy + SQLite local / PostgreSQL production
- WebSockets for driver availability
- UUID-based QR tokens with 15-minute expiration

## Quick start

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Environment

Create a `.env` file with:

```env
DATABASE_URL=sqlite:///./parkride.db
JWT_SECRET=change-me
JWT_ALGORITHM=HS256
```

Production database should be PostgreSQL with the SQL schema in `database/schema.sql`.
