import 'package:flutter/material.dart';
import '../../../data/models/camp.dart';

class CampDetailsScreen extends StatelessWidget {
  final Camp camp;

  const CampDetailsScreen({super.key, required this.camp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/edit_camp',
                arguments: camp,
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('General Information'),
            _buildDetailRow('Camp Name', camp.name),
            _buildDetailRow('Location', camp.locationName),
            _buildDetailRow('Address', camp.address),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Details'),
            _buildDetailRow('Primary Officer', camp.officerName),
            _buildDetailRow('Contact Number', camp.contactNumber),
            const SizedBox(height: 24),
            _buildSectionTitle('Coordinates'),
            _buildDetailRow('Latitude', camp.latitude?.toString() ?? 'N/A'),
            _buildDetailRow('Longitude', camp.longitude?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: camp.active ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: camp.active ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            camp.active ? Icons.check_circle : Icons.pause_circle,
            color: camp.active ? Colors.green : Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            camp.active ? 'This camp is ACTIVE' : 'This camp is INACTIVE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: camp.active ? Colors.green[800] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
