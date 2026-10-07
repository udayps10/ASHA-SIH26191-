import 'package:flutter/material.dart';
import '../../../core/common_widgets/official_photo_view.dart';
import '../../../data/models/normal_record.dart';
import '../../../data/repositories/official_normal_record_repository.dart';

class NormalRecordDetailsScreen extends StatefulWidget {
  final NormalRecord record;

  const NormalRecordDetailsScreen({super.key, required this.record});

  @override
  State<NormalRecordDetailsScreen> createState() =>
      _NormalRecordDetailsScreenState();
}

class _NormalRecordDetailsScreenState extends State<NormalRecordDetailsScreen> {
  late NormalRecord _currentRecord;
  final _recordRepository = OfficialNormalRecordRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
    debugPrint('[DETAILS SCREEN] opened for recordId=${_currentRecord.id}');
  }

  Future<void> _updateStatus(NormalRecordStatus newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(
          'Are you sure you want to change the status to ${newStatus.name.replaceAll('_', ' ')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
        title: const Text('Record Details'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Personal Information'),
            _buildDetailRow('Full Name', _currentRecord.name),
            _buildDetailRow('Age', _currentRecord.age.toString()),
            const SizedBox(height: 24),
            _buildSectionTitle('Rescue Details'),
            _buildDetailRow('Camp', _currentRecord.campName),
            _buildDetailRow(
              'Date Found',
              '${_currentRecord.foundAt.day}/${_currentRecord.foundAt.month}/${_currentRecord.foundAt.year}',
            ),
            _buildDetailRow(
              'Additional Details',
              _currentRecord.additionalDetails.isEmpty
                  ? 'None provided'
                  : _currentRecord.additionalDetails,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Officer in Charge'),
            _buildDetailRow('Name', _currentRecord.officerName),
            _buildDetailRow('Contact', _currentRecord.officerContact),
            const SizedBox(height: 32),
            _buildStatusActions(),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Last updated: ${_currentRecord.updatedAt?.toLocal().toString() ?? 'Never'}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          OfficialPhotoView(
            photoLocalPath: _currentRecord.photoLocalPath,
            photoUrl: _currentRecord.photoUrl,
            size: 150,
            borderRadius: 16,
          ),
          const SizedBox(height: 16),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
          'Update Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NormalRecordStatus.values.map((s) {
            final isCurrent = s == _currentRecord.status;
            return ChoiceChip(
              label: Text(s.name.replaceAll('_', ' ')),
              selected: isCurrent,
              onSelected: isCurrent ? null : (_) => _updateStatus(s),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(NormalRecordStatus status) {
    switch (status) {
      case NormalRecordStatus.FOUND:
        return Colors.blue;
      case NormalRecordStatus.AT_CAMP:
        return Colors.orange;
      case NormalRecordStatus.IDENTIFIED:
        return Colors.purple;
      case NormalRecordStatus.UNITED_WITH_FAMILY:
        return Colors.green;
    }
  }
}
