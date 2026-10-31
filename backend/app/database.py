from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.pool import StaticPool

from app.config import DATABASE_URL

engine_options = {}
if DATABASE_URL.startswith('sqlite'):
    engine_options['connect_args'] = {'check_same_thread': False}
    if DATABASE_URL in {'sqlite://', 'sqlite:///:memory:'}:
        engine_options['poolclass'] = StaticPool

engine = create_engine(DATABASE_URL, **engine_options)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def _add_missing_route_columns() -> None:
    """Apply additive compatibility changes for databases created before route metadata."""
    inspector = inspect(engine)
    if "routes" not in inspector.get_table_names():
        return

    existing_columns = {column["name"] for column in inspector.get_columns("routes")}
    additions = {
        "transport_type": "VARCHAR(20) NOT NULL DEFAULT 'bus'",
        "color": "VARCHAR(7) NOT NULL DEFAULT '#1D4ED8'",
        "vehicle_id": "UUID",
        "is_available": "BOOLEAN NOT NULL DEFAULT TRUE",
    }
    with engine.begin() as connection:
        for name, definition in additions.items():
            if name not in existing_columns:
                connection.execute(text(f"ALTER TABLE routes ADD COLUMN {name} {definition}"))


def initialize_database() -> None:
    """Create fresh schemas and safely add route metadata to legacy SQLite/PostgreSQL DBs."""
    Base.metadata.create_all(bind=engine)
    _add_missing_route_columns()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
