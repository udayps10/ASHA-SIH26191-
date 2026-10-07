import 'package:flutter/material.dart';

import '../data/models/disaster_zone.dart';
import '../data/models/emergency_alert.dart';

class EmergencyAlertDetailScreen extends StatelessWidget {
  const EmergencyAlertDetailScreen({super.key, required this.alert});

  final EmergencyAlert alert;

  @override
  Widget build(BuildContext context) {
    final hasArea =
        alert.latitude != null &&
        alert.longitude != null &&
        alert.radiusKm != null &&
        alert.radiusKm! > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alert')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(alert.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(alert.message),
          const SizedBox(height: 20),
          _row('Severity', alert.severity.name.toUpperCase()),
          _row('Type', alert.disasterType),
          if (alert.district != null) _row('District', alert.district!),
          if (alert.state != null) _row('State', alert.state!),
          if (alert.radiusKm != null)
            _row('Affected radius', '${alert.radiusKm!.toStringAsFixed(1)} km'),
          _row('Issued', alert.createdAt.toLocal().toString()),
          if (hasArea) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/safety_map',
                arguments: DisasterZone(
                  id: alert.id,
                  disasterType: alert.disasterType,
                  latitude: alert.latitude!,
                  longitude: alert.longitude!,
                  radiusKm: alert.radiusKm!,
                  severity: alert.severity,
                  title: alert.title,
                  active: alert.active,
                ),
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text('View affected area on safety map'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text('$label: $value'),
  );
}
