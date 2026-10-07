import 'package:flutter/material.dart';
import '../../../data/models/camp.dart';
import '../../../data/repositories/camp_repository.dart';
import '../../../core/theme/app_theme.dart';

class ManageCampsScreen extends StatefulWidget {
  const ManageCampsScreen({super.key});

  @override
  State<ManageCampsScreen> createState() => _ManageCampsScreenState();
}

class _ManageCampsScreenState extends State<ManageCampsScreen> {
  final CampRepository _campRepository = CampRepository();
  bool _isLoading = true;
  List<Camp> _camps = [];

  @override
  void initState() {
    super.initState();
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    setState(() => _isLoading = true);
    try {
      final camps = await _campRepository.getAllCamps();
      setState(() => _camps = camps);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading camps: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Camps'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchCamps),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _camps.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _camps.length,
              itemBuilder: (context, index) {
                final camp = _camps[index];
                return _buildCampCard(camp);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_camp');
          if (result == true) _fetchCamps();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No camps found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap the + button to add a new camp.'),
        ],
      ),
    );
  }

  Widget _buildCampCard(Camp camp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          camp.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(camp.locationName)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(camp.officerName),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: camp.active ? Colors.green[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: camp.active ? Colors.green[200]! : Colors.grey[300]!,
                ),
              ),
              child: Text(
                camp.active ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: camp.active ? Colors.green[800] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/camp_details',
            arguments: camp,
          );
          if (result == true) _fetchCamps();
        },
      ),
    );
  }
}
