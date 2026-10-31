import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / '.env')

DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///./parkride.db')
JWT_SECRET = os.getenv('JWT_SECRET', 'dev-secret-key')
JWT_ALGORITHM = os.getenv('JWT_ALGORITHM', 'HS256')
QR_VALIDITY_MINUTES = int(os.getenv('QR_VALIDITY_MINUTES', '15'))
CORS_ORIGINS = [
    origin.strip()
    for origin in os.getenv(
        'CORS_ORIGINS',
        'http://localhost:3000,http://127.0.0.1:3000',
    ).split(',')
    if origin.strip()
]
