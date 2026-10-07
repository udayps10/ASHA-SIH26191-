import '../../../core/common_widgets/aasha_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/location_service.dart';
import '../../../data/models/camp.dart';
import '../../../data/repositories/camp_repository.dart';
import '../data/emergency_repository.dart';
import '../data/live_hazard_repository.dart';
import '../data/models/disaster_zone.dart';
import '../data/models/emergency_alert.dart';
import '../data/spring_boot_emergency_repository.dart';
import '../domain/nearest_camp.dart';
import '../domain/safety_calculator.dart';
import '../domain/safety_zone.dart';
import '../data/hazard_route_repository.dart';

class SafetyMapScreen extends StatefulWidget {
  const SafetyMapScreen({super.key, this.repository, this.initialDisaster});

  final EmergencyRepository? repository;
  final DisasterZone? initialDisaster;

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen> {
  final _mapController = MapController();
  late final LocationService _locationService = LocationService();
  final _campRepository = CampRepository();
  late final EmergencyRepository _emergencyRepository =
      widget.repository ?? SpringBootEmergencyRepository();

  final _hazardRepository = LiveHazardRepository();
  final _routeRepository = HazardRouteRepository();
  CheckedCampRoute? _route;
  bool _routing = false;
  String? _routeMessage;
  LiveHazard? _liveHazard;
  String? _hazardMessage;
  LocationResult? _location;

  @override
  void dispose() {
    _hazardRepository.close();
    _routeRepository.close();
    super.dispose();
  }

  List<DisasterZone> _disasters = [];
  List<EmergencyAlert> _alerts = [];
  bool _alertsFailed = false;
  List<Camp> _camps = [];
  bool _loading = true;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _loadSafetyData();
  }

  Future<void> _loadSafetyData() async {
    setState(() {
      _loading = true;
      _route = null;
      _routeMessage = null;
    });
    final cachedCamps = context.read<AppState>().syncService.camps;
    List<DisasterZone> zones;
    try {
      _alerts = (await _emergencyRepository.getActiveAlerts())
          .where((a) => a.active && a.latitude != null && a.longitude != null)
          .toList();
      _alertsFailed = false;
      zones = _alerts
          .where((a) => a.radiusKm != null && a.radiusKm! > 0)
          .map(
            (a) => DisasterZone(
              id: a.id,
              disasterType: a.disasterType,
              latitude: a.latitude!,
              longitude: a.longitude!,
              radiusKm: a.radiusKm!,
              severity: a.severity,
              title: a.title,
            ),
          )
          .where(_isValidZone)
          .toList();
    } catch (_) {
      _alertsFailed = true;
      zones = [];
    }
    List<Camp> camps;
    try {
      final remoteCamps = await _campRepository.getActiveCamps();
      camps = remoteCamps.isNotEmpty
          ? remoteCamps
          : await cachedCamps.getActive();
    } catch (_) {
      camps = await cachedCamps.getActive();
    }

    final permission = await _locationService.checkAndRequestPermission();
    LocationResult? location;
    if (permission == LocationPermissionStatus.granted) {
      location = await _locationService.getCurrentLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => null,
      );
    }
    LiveHazard? live;
    String? hazardMessage;
    if (location != null) {
      try {
        live = await _hazardRepository.fetch(
          location.latitude,
          location.longitude,
        );
      } catch (_) {
        hazardMessage =
            'Live weather and elevation unavailable. Reported disaster information is still shown.';
      }
    }
    if (!mounted) return;
    setState(() {
      _liveHazard = live;
      _hazardMessage = hazardMessage;
      _location = location;
      _disasters = [
        if (widget.initialDisaster != null &&
            _isValidZone(widget.initialDisaster!))
          widget.initialDisaster!,
        ...zones.where((zone) => zone.id != widget.initialDisaster?.id),
      ];
      _camps = camps;
      _loading = false;
      _locationMessage = location == null ? _locationError(permission) : null;
    });
  }

  String _locationError(LocationPermissionStatus status) {
    return switch (status) {
      LocationPermissionStatus.denied => 'Location permission was denied.',
      LocationPermissionStatus.deniedForever =>
        'Location permission is disabled in app settings.',
      LocationPermissionStatus.serviceDisabled => 'Location services are off.',
      _ => 'Your current location is unavailable.',
    };
  }

  bool _isValidZone(DisasterZone zone) {
    return zone.active &&
        zone.radiusKm.isFinite &&
        zone.radiusKm > 0 &&
        zone.latitude.isFinite &&
        zone.latitude >= -90 &&
        zone.latitude <= 90 &&
        zone.longitude.isFinite &&
        zone.longitude >= -180 &&
        zone.longitude <= 180;
  }

  @override
  Widget build(BuildContext context) {
    final location = _location;
    final disasterResult = location == null
        ? null
        : _nearestDisasterResult(location);
    final nearestCamp = location == null
        ? null
        : findNearestCamp(
            userLatitude: location.latitude,
            userLongitude: location.longitude,
            camps: _camps,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Map')),
      body: AashaSurface(
        maxWidth: 1000,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadSafetyData,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _statusCard(disasterResult, nearestCamp),
                    const SizedBox(height: 16),
                    _map(location),
                    const SizedBox(height: 10),
                    _legend(),
                    if (_alertsFailed)
                      _infoCard(
                        Icons.cloud_off,
                        'Alerts could not be refreshed',
                        'Pull down to retry. Missing alerts do not mean the area is safe.',
                      ),
                    if (_alerts.any((a) => a.radiusKm == null))
                      _infoCard(
                        Icons.info_outline,
                        'Affected boundaries unavailable',
                        'Alert markers show reported locations. Zones are drawn only when an affected-area radius is provided.',
                      ),
                    if (_locationMessage != null) _locationUnavailable(),
                    if (!_alertsFailed && _alerts.isEmpty && _disasters.isEmpty)
                      _infoCard(
                        Icons.check_circle_outline,
                        'No active disaster information',
                        'No verified active disaster information is available right now.',
                      ),
                    if (nearestCamp != null) ...[
                      const SizedBox(height: 16),
                      _campCard(nearestCamp, location!),
                    ],
                    if (location != null && nearestCamp == null) ...[
                      const SizedBox(height: 16),
                      _infoCard(
                        Icons.home_work_outlined,
                        'No verified safe locations nearby',
                        'Active camps with geographic coordinates will appear here when available.',
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/emergency_alerts'),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('View emergency alerts'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  SafetyResult? _nearestDisasterResult(LocationResult location) {
    SafetyResult? nearest;
    for (final disaster in _disasters) {
      final result = SafetyCalculator.classify(
        userLatitude: location.latitude,
        userLongitude: location.longitude,
        disasterLatitude: disaster.latitude,
        disasterLongitude: disaster.longitude,
        radiusKm: disaster.radiusKm,
        hazardFactors: disaster.hazardFactors,
      );
      if (nearest == null ||
          result.distanceFromDisasterKm! < nearest.distanceFromDisasterKm!) {
        nearest = result;
      }
    }
    return _liveHazard?.combine(nearest) ?? nearest;
  }

  Widget _statusCard(SafetyResult? result, Camp? camp) {
    final zone = result?.zone ?? SafetyZone.unknown;
    final color = _zoneColor(zone);
    final riskScore = result?.riskScore;
    final label = switch (zone) {
      SafetyZone.red => 'RED ZONE',
      SafetyZone.orange => 'ORANGE ZONE',
      SafetyZone.yellow => 'YELLOW ZONE',
      SafetyZone.green => 'GREEN ZONE',
      SafetyZone.safe => 'OUTSIDE REPORTED RADIUS',
      SafetyZone.unknown => 'RISK NOT DETERMINED',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOUR SAFETY STATUS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.shield_outlined, color: color, size: 30),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            if (result?.radiusKm != null) ...[
              const SizedBox(height: 8),
              Text('Nearest affected area: ${_nearestDisasterName()}'),
              Text(
                'Affected radius: ${result!.radiusKm!.toStringAsFixed(1)} km',
              ),
            ],
            if (result?.distanceFromDisasterKm != null) ...[
              const SizedBox(height: 8),
              Text(
                'You are ${result!.distanceFromDisasterKm!.toStringAsFixed(1)} km from the affected area.',
              ),
            ],
            if (camp != null) ...[
              const SizedBox(height: 6),
              Text('Nearest registered camp: ${camp.name}'),
            ],
            if (_liveHazard != null) ...[
              const SizedBox(height: 10),
              Text(_liveHazard!.details, style: const TextStyle(fontSize: 12)),
            ],
            if (_hazardMessage != null) Text(_hazardMessage!),
            if (riskScore != null)
              Text('Risk: $riskScore/100 (rule-based estimate)'),
            if (result?.factors != null && result!.factors!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'WHY (risk factors)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 6),
              for (final f in result.factors!.take(4))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.factorName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f.contributionScore == 0
                              ? ''
                              : "${f.isNegative ? '−' : '+'}${f.contributionScore}",
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _nearestDisasterName() {
    if (_disasters.isEmpty) return 'Unavailable';
    var nearest = _disasters.first;
    var distance = SafetyCalculator.distanceKmBetween(
      _location!.latitude,
      _location!.longitude,
      nearest.latitude,
      nearest.longitude,
    );
    for (final disaster in _disasters.skip(1)) {
      final candidate = SafetyCalculator.distanceKmBetween(
        _location!.latitude,
        _location!.longitude,
        disaster.latitude,
        disaster.longitude,
      );
      if (candidate < distance) {
        nearest = disaster;
        distance = candidate;
      }
    }
    return nearest.title.isEmpty ? nearest.disasterType : nearest.title;
  }

  Widget _map(LocationResult? location) {
    final userPoint = location == null
        ? null
        : LatLng(location.latitude, location.longitude);
    final center =
        userPoint ??
        (_alerts.isNotEmpty
            ? LatLng(_alerts.first.latitude!, _alerts.first.longitude!)
            : const LatLng(22.5, 79.0));
    final markers = <Marker>[
      if (userPoint != null)
        Marker(
          point: userPoint,
          width: 84,
          height: 52,
          child: _marker(Icons.person_pin_circle, 'YOU', AppTheme.primaryColor),
        ),
    ];
    for (final alert in _alerts.where(
      (a) => !_disasters.any((d) => d.id == a.id),
    )) {
      markers.add(
        Marker(
          point: LatLng(alert.latitude!, alert.longitude!),
          width: 110,
          height: 52,
          child: Tooltip(
            message: '${alert.title}\nAffected boundary unavailable',
            child: _marker(
              Icons.warning_amber_rounded,
              'ALERT',
              alert.severity == EmergencySeverity.critical ||
                      alert.severity == EmergencySeverity.severe
                  ? Colors.red
                  : Colors.amber.shade800,
            ),
          ),
        ),
      );
    }
    final circles = <CircleMarker>[];
    for (final disaster in _disasters) {
      final point = LatLng(disaster.latitude, disaster.longitude);
      markers.add(
        Marker(
          point: point,
          width: 110,
          height: 52,
          child: _marker(
            Icons.warning_amber_rounded,
            'DISASTER',
            AppTheme.accentColor,
          ),
        ),
      );
      circles.addAll([
        CircleMarker(
          point: point,
          radius: disaster.radiusKm * 1000,
          useRadiusInMeter: true,
          color: Colors.green.withAlpha(35),
          borderColor: Colors.green,
          borderStrokeWidth: 1,
        ),
        CircleMarker(
          point: point,
          radius: disaster.radiusKm * .7 * 1000,
          useRadiusInMeter: true,
          color: Colors.amber.withAlpha(35),
          borderColor: Colors.amber.shade800,
          borderStrokeWidth: 1,
        ),
        CircleMarker(
          point: point,
          radius: disaster.radiusKm * .3 * 1000,
          useRadiusInMeter: true,
          color: Colors.red.withAlpha(45),
          borderColor: Colors.red,
          borderStrokeWidth: 1,
        ),
      ]);
    }
    for (final camp in _camps.where(
      (camp) => camp.latitude != null && camp.longitude != null && camp.active,
    )) {
      markers.add(
        Marker(
          point: LatLng(camp.latitude!, camp.longitude!),
          width: 90,
          height: 48,
          child: _marker(Icons.home_work_outlined, 'CAMP', Colors.teal),
        ),
      );
    }
    return SizedBox(
      height: 360,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: location == null ? 5 : 11,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aasha.disasterconnect',
                ),
                CircleLayer(circles: circles),
                if (_route != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route!.points,
                        strokeWidth: 6,
                        color: Colors.teal.shade700,
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                heroTag: 'recenter-map',
                tooltip: 'Center on my location',
                onPressed: location == null ? null : _recenter,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend() => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        children: const [
          _LegendItem(color: Colors.red, label: 'RED = Danger'),
          _LegendItem(color: Colors.amber, label: 'YELLOW = Caution'),
          _LegendItem(color: Colors.green, label: 'Outer radius band'),
          _LegendItem(color: Colors.teal, label: 'Camp'),
        ],
      ),
    ),
  );

  void _recenter() {
    final location = _location;
    if (location == null) return;
    _mapController.move(LatLng(location.latitude, location.longitude), 11);
  }

  Widget _marker(IconData icon, String label, Color color) => Column(
    children: [
      Icon(icon, color: color, size: 30),
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    ],
  );

  Widget _locationUnavailable() => _infoCard(
    Icons.location_off_outlined,
    'Location unavailable',
    '$_locationMessage GPS is needed to calculate your safety status.',
  );

  Widget _infoCard(IconData icon, String title, String message) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppTheme.secondaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
    ),
  );

  Widget _campCard(Camp camp, LocationResult location) {
    final distance = SafetyCalculator.distanceKmBetween(
      location.latitude,
      location.longitude,
      camp.latitude!,
      camp.longitude!,
    );
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.home_work_outlined, color: Colors.teal),
            title: Text(camp.name),
            subtitle: Text(
              '${distance.toStringAsFixed(1)} km straight-line\n${camp.address}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: _routing ? null : _findRoute,
                  icon: const Icon(Icons.alt_route),
                  label: Text(
                    _routing
                        ? 'Checking road alternatives…'
                        : 'Find safer route',
                  ),
                ),
                const Text(
                  'Checks driving routes to up to 3 nearby camps. Sends your location and camp coordinates to OSRM when tapped.',
                  style: TextStyle(fontSize: 12),
                ),
                if (_routeMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_routeMessage!),
                  ),
                if (_route != null) ...[
                  Text(
                    'Route to ${_route!.camp.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_route!.kilometres.toStringAsFixed(1)} km by road · about ${_route!.minutes.ceil()} min driving',
                  ),
                  Text(
                    '${_route!.rejected} options excluded by reported hazard boundaries. Teal line shows the checked road route.',
                  ),
                  const Text(
                    'Checked now against mapped alerts with a 100 m buffer. Some boundaries are estimated. Road closures, camp space and unreported hazards still need local confirmation.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _findRoute() async {
    final location = _location;
    if (location == null) return;
    setState(() {
      _routing = true;
      _route = null;
      _routeMessage = null;
    });
    try {
      final alerts = await _emergencyRepository.getActiveAlerts().timeout(
        const Duration(seconds: 10),
      );
      final active = alerts
          .where(
            (a) =>
                a.active &&
                (a.expiresAt == null || a.expiresAt!.isAfter(DateTime.now())),
          )
          .toList();
      final unmapped = active
          .where(
            (a) =>
                a.latitude == null || a.longitude == null || a.radiusKm == null,
          )
          .length;
      final mapped = active
          .where(
            (a) =>
                a.latitude != null &&
                a.longitude != null &&
                a.radiusKm != null &&
                a.radiusKm! > 0,
          )
          .toList();
      if (mapped.isEmpty) {
        throw Exception(
          'No active alert has a mapped boundary. Consult the officer before travelling.',
        );
      }
      final zones = mapped
          .map(
            (a) => DisasterZone(
              id: a.id,
              disasterType: a.disasterType,
              latitude: a.latitude!,
              longitude: a.longitude!,
              radiusKm: a.radiusKm!,
              severity: a.severity,
              title: a.title,
            ),
          )
          .toList();
      if (widget.initialDisaster != null &&
          _isValidZone(widget.initialDisaster!)) {
        zones.add(widget.initialDisaster!);
      }
      final camps = await _campRepository.getActiveCamps().timeout(
        const Duration(seconds: 10),
      );
      final result = await _routeRepository.find(
        LatLng(location.latitude, location.longitude),
        camps,
        zones,
      );
      if (!mounted) return;
      setState(() {
        _disasters = zones;
        _camps = camps;
        _route = result;
        _routeMessage = result == null
            ? 'No suitable route found among the checked alternatives. Contact an officer for evacuation assistance.'
            : unmapped > 0
            ? 'Route checked against mapped alerts. $unmapped active alert(s) had no boundary; confirm with the officer before travelling.'
            : null;
      });
      if (result != null) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(result.points),
            padding: const EdgeInsets.all(30),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _routeMessage =
              'Route check unavailable. ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  Color _zoneColor(SafetyZone zone) => switch (zone) {
    SafetyZone.red => Colors.red.shade700,
    SafetyZone.orange => Colors.orange.shade800,
    SafetyZone.yellow => Colors.amber.shade800,
    SafetyZone.green => Colors.green.shade700,
    SafetyZone.safe => Colors.teal,
    SafetyZone.unknown => AppTheme.secondaryColor,
  };
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
