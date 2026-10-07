import 'package:flutter/material.dart';

import '../../../core/utils/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/emergency_repository.dart';
import '../data/models/emergency_alert.dart';
import '../data/spring_boot_emergency_repository.dart';
import '../domain/safety_calculator.dart';

class EmergencyAlertsScreen extends StatefulWidget {
  const EmergencyAlertsScreen({super.key, this.repository});

  final EmergencyRepository? repository;

  @override
  State<EmergencyAlertsScreen> createState() => _EmergencyAlertsScreenState();
}

class _EmergencyAlertsScreenState extends State<EmergencyAlertsScreen> {
  late final EmergencyRepository _repository =
      widget.repository ?? SpringBootEmergencyRepository();
  final _locationService = LocationService();
  List<EmergencyAlert> _alerts = [];
  LocationResult? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    List<EmergencyAlert> alerts;
    try {
      alerts = await _repository.getActiveAlerts();
    } catch (_) {
      alerts = [];
    }
    final permission = await _locationService.checkAndRequestPermission();
    if (permission == LocationPermissionStatus.granted) {
      _location = await _locationService.getCurrentLocation();
    }
    if (!mounted) return;
    setState(() {
      _alerts = alerts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alerts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_repository.lastFetchUsedCache)
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade50,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _alerts.isEmpty
                          ? 'Offline: no cached emergency alerts are available.'
                          : 'Offline: showing cached emergency alerts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                if (_location == null)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Your location is unavailable. Distances and geographic relevance are not shown.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: _alerts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 60,
                                  color: AppTheme.secondaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _repository.lastError == null
                                      ? 'No active emergency alerts'
                                      : 'Emergency alerts are unavailable',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _repository.lastError == null
                                      ? 'Verified government warnings will appear here.'
                                      : 'Please try again when a network connection is available.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                FilledButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/safety_map',
                                  ),
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('Open safety map'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAlerts,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: _alerts.map(_alertCard).toList(),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _alertCard(EmergencyAlert alert) {
    final color =
        alert.severity == EmergencySeverity.critical ||
            alert.severity == EmergencySeverity.severe
        ? Colors.red.shade700
        : Colors.amber.shade800;
    final distance = _distanceFromUser(alert);
    final relevant =
        distance != null &&
        alert.radiusKm != null &&
        distance <= alert.radiusKm!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: color),
                const SizedBox(width: 8),
                Text(
                  'GOVERNMENT ALERT',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alert.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(alert.message),
            const SizedBox(height: 12),
            Text('Type: ${alert.disasterType}'),
            if (alert.district != null || alert.state != null)
              Text(
                'Area: ${[alert.district, alert.state].whereType<String>().join(', ')}',
              ),
            Text('Issued: ${_formatDate(alert.createdAt)}'),
            if (distance != null)
              Text(
                'Distance: ${distance.toStringAsFixed(1)} km${relevant ? ' · Relevant to your location' : ''}',
              ),
            if (alert.radiusKm != null)
              Text('Affected radius: ${alert.radiusKm!.toStringAsFixed(1)} km'),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/emergency_alert_detail',
                arguments: alert,
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View alert details'),
            ),
          ],
        ),
      ),
    );
  }

  double? _distanceFromUser(EmergencyAlert alert) {
    final location = _location;
    if (location == null || alert.latitude == null || alert.longitude == null) {
      return null;
    }
    return SafetyCalculator.distanceKmBetween(
      location.latitude,
      location.longitude,
      alert.latitude!,
      alert.longitude!,
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
