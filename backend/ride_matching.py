from __future__ import annotations

from dataclasses import dataclass
from math import atan2, cos, radians, sin, sqrt


@dataclass
class DriverCandidate:
    id: str
    nombre: str
    vehicle_info: str
    capacidad_pasajeros: int
    is_online: bool
    latitude: float
    longitude: float


@dataclass
class MatchingResult:
    matched: bool
    score: int
    status: str
    driver_name: str
    vehicle_info: str
    driver: DriverCandidate | None = None


class RideMatchingService:
    @staticmethod
    def find_best_match(passenger_origin, passenger_destination, requested_passengers, drivers):
        eligible = [
            driver for driver in drivers
            if driver.is_online and driver.capacidad_pasajeros >= requested_passengers
        ]

        if not eligible:
            return MatchingResult(
                matched=False,
                score=0,
                status=f"Sin chofer disponible para {requested_passengers} pasajero(s)",
                driver_name='Ninguno',
                vehicle_info='Sin vehículo disponible',
            )

        scored = []
        for driver in eligible:
            origin_distance = RideMatchingService._haversine_km(
                (driver.latitude, driver.longitude),
                (passenger_origin['latitude'], passenger_origin['longitude']),
            )
            destination_distance = RideMatchingService._haversine_km(
                (driver.latitude, driver.longitude),
                (passenger_destination['latitude'], passenger_destination['longitude']),
            )

            base_score = max(0.0, 100 - (origin_distance * 12.0))
            destination_bonus = max(0.0, 100 - (destination_distance * 14.0)) * 0.3
            capacity_bonus = max(0.0, (driver.capacidad_pasajeros - requested_passengers) * 10.0)
            final_score = int(min(100, base_score + destination_bonus + capacity_bonus + 15.0))
            scored.append((driver, final_score))

        best_driver, best_score = max(scored, key=lambda item: item[1])

        if best_score < 55:
            return MatchingResult(
                matched=False,
                score=best_score,
                status='Sin chofer disponible con un match aceptable',
                driver_name=best_driver.nombre,
                vehicle_info=best_driver.vehicle_info,
                driver=best_driver,
            )

        return MatchingResult(
            matched=True,
            score=best_score,
            status=f"Asignado a {best_driver.nombre} • match {best_score}/100",
            driver_name=best_driver.nombre,
            vehicle_info=best_driver.vehicle_info,
            driver=best_driver,
        )

    @staticmethod
    def _haversine_km(start, end):
        lat1, lon1 = map(radians, start)
        lat2, lon2 = map(radians, end)
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = (
            sin(dlat / 2) ** 2
            + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
        )
        c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return 6371.0 * c
