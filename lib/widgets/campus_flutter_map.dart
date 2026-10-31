import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/parkride_models.dart';
import '../services/parkride_state.dart';
import '../services/routing_service.dart';

class CampusFlutterMap extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final LocationNode? selectedOrigen;
  final LocationNode? selectedDestino;
  final Function(LocationNode)? onNodeSelected;
  final bool showDriverLocation;
  final LatLng? driverPosition;
  final bool isInteractive;
  final List<LatLng> routePoints;
  final List<ParkRideRoute> routes;
  final String? transportFilter;

  const CampusFlutterMap({
    super.key,
    this.initialCenter = ParkRideState.campusCenter,
    this.initialZoom = 16.2,
    this.selectedOrigen,
    this.selectedDestino,
    this.onNodeSelected,
    this.showDriverLocation = false,
    this.driverPosition,
    this.isInteractive = true,
    this.routePoints = const [],
    this.routes = const [],
    this.transportFilter,
  });

  @override
  State<CampusFlutterMap> createState() => _CampusFlutterMapState();
}

class _CampusFlutterMapState extends State<CampusFlutterMap> {
  late final MapController _mapController;
  final state = ParkRideState();
  bool _isLoadingRoute = false;
  String? _routeError;
  List<LatLng> _resolvedRoutePoints = <LatLng>[];
  Map<String, List<LatLng>> _routeGeometries = const {};

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadRouteIfNeeded();
    _loadRouteGeometries();
  }

  @override
  void didUpdateWidget(covariant CampusFlutterMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOrigen != widget.selectedOrigen ||
        oldWidget.selectedDestino != widget.selectedDestino ||
        oldWidget.routePoints != widget.routePoints) {
      _loadRouteIfNeeded();
    }
    if (oldWidget.routes != widget.routes ||
        oldWidget.transportFilter != widget.transportFilter) {
      _loadRouteGeometries();
    }
    if (oldWidget.initialCenter != widget.initialCenter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(widget.initialCenter, widget.initialZoom);
        }
      });
    }
  }

  Future<void> _loadRouteGeometries() async {
    final visibleRoutes = widget.routes.where((route) {
      return widget.transportFilter == null ||
          route.transportType == widget.transportFilter;
    }).toList();
    final routeGeometries = <String, List<LatLng>>{};

    await Future.wait(visibleRoutes.map((route) async {
      final geometry = await RoutingService.getRouteForStops(
        route.stops.map((stop) => stop.latLng).toList(),
      );
      if (geometry.length >= 2) {
        routeGeometries[route.id] = geometry;
      }
    }));

    if (mounted) {
      setState(() {
        _routeGeometries = routeGeometries;
      });
    }
  }

  Future<void> _loadRouteIfNeeded() async {
    final hasSelection =
        widget.selectedOrigen != null && widget.selectedDestino != null;
    if (!hasSelection) {
      if (mounted) {
        setState(() {
          _resolvedRoutePoints = <LatLng>[];
          _routeError = null;
          _isLoadingRoute = false;
        });
      }
      return;
    }

    if (widget.routePoints.isNotEmpty) {
      if (mounted) {
        setState(() {
          _resolvedRoutePoints = widget.routePoints;
          _routeError = null;
          _isLoadingRoute = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingRoute = true;
        _routeError = null;
      });
    }

    try {
      final points = await RoutingService.getRoutePoints(
        widget.selectedOrigen!.latLng,
        widget.selectedDestino!.latLng,
      );

      if (!mounted) return;
      setState(() {
        _resolvedRoutePoints = points;
        _isLoadingRoute = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolvedRoutePoints = <LatLng>[];
        _routeError = 'No se pudo cargar una ruta por calles.';
        _isLoadingRoute = false;
      });
    }
  }

  void _recenterMap() {
    _mapController.move(widget.initialCenter, widget.initialZoom);
  }

  @override
  Widget build(BuildContext context) {
    final nodes = state.nodes;
    final List<Marker> markers = [];

    markers.add(
      Marker(
        point: widget.initialCenter,
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.circle, size: 8, color: Colors.white),
            ),
          ),
        ),
      ),
    );

    for (final node in nodes) {
      final isOrigen = widget.selectedOrigen?.id == node.id;
      final isDestino = widget.selectedDestino?.id == node.id;

      Color markerColor = const Color(0xFF1E293B);
      if (isOrigen) markerColor = const Color(0xFF3B82F6);
      if (isDestino) markerColor = const Color(0xFF22C55E);

      markers.add(
        Marker(
          point: node.latLng,
          width: 90,
          height: 60,
          child: GestureDetector(
            onTap: () {
              if (widget.onNodeSelected != null) {
                widget.onNodeSelected!(node);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: markerColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isOrigen || isDestino ? Colors.white : Colors.white70,
                      width: isOrigen || isDestino ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: markerColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOrigen
                            ? Icons.my_location
                            : (isDestino ? Icons.location_on : Icons.school),
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          node.nombre.split(' - ').first,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: isOrigen || isDestino
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: markerColor, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    final visibleRoutes = widget.routes.where((route) {
      return widget.transportFilter == null ||
          route.transportType == widget.transportFilter;
    });
    final routePolylines = <Polyline>[];
    for (final route in visibleRoutes) {
      if (route.stops.length < 2) continue;
      final geometry = _routeGeometries[route.id];
      if (geometry == null || geometry.length < 2) continue;
      final color = _colorFromHex(route.color);
      routePolylines.add(
        Polyline(
          points: geometry,
          strokeWidth: 5,
          color: color,
        ),
      );
      for (final stop in route.stops) {
        markers.add(
          Marker(
            point: stop.latLng,
            width: 78,
            height: 44,
            child: Tooltip(
              message: '${route.name}: ${stop.nombre}',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: route.isAvailable
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        route.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    final driverPos = widget.driverPosition ?? const LatLng(25.7262, -100.3120);
    if (widget.showDriverLocation || state.isDriverOnline) {
      markers.add(
        Marker(
          point: driverPos,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.airport_shuttle,
                color: Colors.white, size: 22),
          ),
        ),
      );
    }

    final polylinePoints = widget.routePoints.isNotEmpty
        ? widget.routePoints
        : (_resolvedRoutePoints.isNotEmpty ? _resolvedRoutePoints : <LatLng>[]);

    final polylines = <Polyline>[
      ...routePolylines,
      if (polylinePoints.isNotEmpty)
        Polyline(
          points: polylinePoints,
          strokeWidth: 4.5,
          color: const Color(0xFF22C55E),
        ),
    ];

    return Stack(
      children: [
        if (_isLoadingRoute &&
            widget.selectedOrigen != null &&
            widget.selectedDestino != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Cargando ruta real...',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_routeError != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _routeError!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            minZoom: 9.0,
            maxZoom: 18.5,
            interactionOptions: InteractionOptions(
              flags: widget.isInteractive
                  ? InteractiveFlag.all
                  : InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.parkride.uanl.app',
            ),
            if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'map_recenter_${identityHashCode(this)}',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                elevation: 4,
                onPressed: _recenterMap,
                child: const Icon(Icons.my_location, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_zoom_in_${identityHashCode(this)}',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                elevation: 4,
                onPressed: () {
                  final zoom = _mapController.camera.zoom + 1.0;
                  _mapController.move(_mapController.camera.center, zoom);
                },
                child: const Icon(Icons.add, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_zoom_out_${identityHashCode(this)}',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                elevation: 4,
                onPressed: () {
                  final zoom = _mapController.camera.zoom - 1.0;
                  _mapController.move(
                      _mapController.camera.center, zoom.clamp(9.0, 18.5));
                },
                child: const Icon(Icons.remove, size: 20),
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '© OpenStreetMap contributors • Aeropuerto MTY',
              style: TextStyle(fontSize: 9, color: Color(0xFF475569)),
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFromHex(String raw) {
    final normalized = raw.replaceFirst('#', '');
    final value = int.tryParse(normalized, radix: 16);
    return value == null ? const Color(0xFF2563EB) : Color(0xFF000000 | value);
  }
}
