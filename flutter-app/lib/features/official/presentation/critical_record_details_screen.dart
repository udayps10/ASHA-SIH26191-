import 'package:flutter/material.dart';
import '../../../core/common_widgets/official_photo_view.dart';
import '../../../data/models/critical_record.dart';
import '../../../data/repositories/official_critical_record_repository.dart';

class CriticalRecordDetailsScreen extends StatefulWidget {
  final CriticalRecord record;

  const CriticalRecordDetailsScreen({super.key, required this.record});

  @override
  State<CriticalRecordDetailsScreen> createState() =>
      _CriticalRecordDetailsScreenState();
}

class _CriticalRecordDetailsScreenState
    extends State<CriticalRecordDetailsScreen> {
  late CriticalRecord _currentRecord;
  final _recordRepository = OfficialCriticalRecordRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
  }

  Future<void> _updateStatus(CriticalRecordStatus newStatus) async {
    String message =
        'Are you sure you want to change the status to ${newStatus.name.replaceAll('_', ' ')}?';
    if (newStatus == CriticalRecordStatus.CONFIRMED_DECEASED) {
      message =
          'WARNING: You are marking this person as CONFIRMED DECEASED. This action is sensitive and must be verified. Proceed?';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Sensitive Status'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == CriticalRecordStatus.CONFIRMED_DECEASED
                  ? Colors.black
                  : null,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _recordRepository.updateStatus(_currentRecord.id, newStatus);
        final updated = await _recordRepository.getRecordById(
          _currentRecord.id,
        );
        if (updated != null) {
          setState(() => _currentRecord = updated);
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Status updated.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Critical Record Details'),
        backgroundColor: Colors.red[900],
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfidentialHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Personal Information'),
            _buildDetailRow('Full Name', _currentRecord.name),
            _buildDetailRow('Age', _currentRecord.age.toString()),
            _buildDetailRow(
              'Last Known Clothing',
              _currentRecord.lastKnownClothing,
            ),
            if (_currentRecord.clothingPhotoLocalPath != null || _currentRecord.clothingPhotoUrl != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Clothing Photo (Official Only)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OfficialPhotoView(
                photoLocalPath: _currentRecord.clothingPhotoLocalPath,
                photoUrl: _currentRecord.clothingPhotoUrl,
                size: 140,
                borderRadius: 12,
                placeholderIcon: Icons.checkroom,
              ),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle('Location & Camp'),
            _buildDetailRow('Assigned Camp', _currentRecord.campName),
            _buildDetailRow('Found At', _currentRecord.foundLocation),
            _buildDetailRow(
              'Coordinates',
              '${_currentRecord.foundLatitude?.toStringAsFixed(4) ?? 'N/A'}, ${_currentRecord.foundLongitude?.toStringAsFixed(4) ?? 'N/A'}',
            ),
            _buildDetailRow(
              'Accuracy',
              _currentRecord.locationAccuracy != null
                  ? '~${_currentRecord.locationAccuracy!.toStringAsFixed(1)} m'
                  : 'N/A',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Official Info'),
            _buildDetailRow('Reporting Officer', _currentRecord.officerName),
            _buildDetailRow('Officer Contact', _currentRecord.officerContact),
            _buildDetailRow(
              'Date Found',
              '${_currentRecord.foundAt.toLocal()}',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Details'),
            Text(
              _currentRecord.additionalDetails.isEmpty
                  ? 'No additional identifying information.'
                  : _currentRecord.additionalDetails,
            ),
            const Divider(height: 48),
            _buildStatusActions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidentialHeader() {
    return Center(
      child: Column(
        children: [
          OfficialPhotoView(
            photoLocalPath: _currentRecord.photoLocalPath,
            photoUrl: _currentRecord.photoUrl,
            size: 128,
            borderRadius: 64,
            placeholderIcon: Icons.lock,
            placeholderColor: Colors.red[50],
          ),
          const SizedBox(height: 16),
          const Text(
            'CONFIDENTIAL RECORD',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentRecord.status).withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentRecord.status.name.replaceAll('_', ' '),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(_currentRecord.status),
              ),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Update Sensitive Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CriticalRecordStatus.values.map((s) {
            final isCurrent = s == _currentRecord.status;
            return ChoiceChip(
              label: Text(s.name.replaceAll('_', ' ')),
              selected: isCurrent,
              selectedColor: _getStatusColor(s).withAlpha(50),
              onSelected: isCurrent ? null : (_) => _updateStatus(s),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(CriticalRecordStatus status) {
    switch (status) {
      case CriticalRecordStatus.CRITICAL:
        return Colors.orange;
      case CriticalRecordStatus.IDENTIFIED:
        return Colors.purple;
      case CriticalRecordStatus.CONFIRMED_DECEASED:
        return Colors.black;
      case CriticalRecordStatus.RELEASED_TO_FAMILY:
        return Colors.green;
    }
  }
}
