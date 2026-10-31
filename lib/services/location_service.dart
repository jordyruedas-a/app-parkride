import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ParkRideCurrentLocation {
  final LatLng coordinates;
  final String address;

  const ParkRideCurrentLocation({
    required this.coordinates,
    required this.address,
  });
}

class ParkRideLocationService {
  static const LatLng fallbackLocation = LatLng(25.7252, -100.3131);

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested != LocationPermission.denied &&
          requested != LocationPermission.deniedForever;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<LatLng?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  Future<ParkRideCurrentLocation?> getCurrentLocationWithAddress() async {
    final coordinates = await getCurrentPosition();
    if (coordinates == null) return null;
    return _withAddress(coordinates);
  }

  Stream<ParkRideCurrentLocation> watchCurrentLocationWithAddress() async* {
    final allowed = await requestLocationPermission();
    if (!allowed) return;

    await for (final position in Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    )) {
      yield await _withAddress(LatLng(position.latitude, position.longitude));
    }
  }

  Future<ParkRideCurrentLocation> _withAddress(LatLng coordinates) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      final place = placemarks.isEmpty ? null : placemarks.first;
      final parts = <String>[
        if (place?.street?.trim().isNotEmpty == true) place!.street!.trim(),
        if (place?.subLocality?.trim().isNotEmpty == true)
          place!.subLocality!.trim(),
        if (place?.locality?.trim().isNotEmpty == true) place!.locality!.trim(),
      ];
      return ParkRideCurrentLocation(
        coordinates: coordinates,
        address: parts.isEmpty ? 'Ubicación actual' : parts.join(', '),
      );
    } catch (_) {
      return ParkRideCurrentLocation(
        coordinates: coordinates,
        address: 'Ubicación actual',
      );
    }
  }
}
