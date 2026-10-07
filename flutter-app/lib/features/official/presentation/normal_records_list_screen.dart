import 'package:flutter/material.dart';
import '../../../core/common_widgets/official_photo_view.dart';
import '../../../data/models/normal_record.dart';
import '../../../data/models/camp.dart';
import '../../../data/repositories/official_normal_record_repository.dart';
import '../../../data/repositories/camp_repository.dart';

class NormalRecordsListScreen extends StatefulWidget {
  const NormalRecordsListScreen({super.key});

  @override
  State<NormalRecordsListScreen> createState() =>
      _NormalRecordsListScreenState();
}

class _NormalRecordsListScreenState extends State<NormalRecordsListScreen> {
  final _recordRepository = OfficialNormalRecordRepository();
  final _campRepository = CampRepository();
  final _searchController = TextEditingController();
  final _ageController = TextEditingController();

  List<NormalRecord> _records = [];
  List<Camp> _camps = [];
  bool _isLoading = true;
  String? _loadError;

  // Filters
  NormalRecordStatus? _statusFilter;
  Camp? _selectedCamp;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final camps = await _campRepository.getAllCamps();
      _camps = camps;
      await _fetchRecords();
    } catch (e) {
      _showError('Error loading data: $e');
      await _fetchRecords();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRecords() async {
    try {
      final records = await _recordRepository.searchRecords(
        name: _searchController.text.trim(),
        age: int.tryParse(_ageController.text),
        campId: _selectedCamp?.id,
        status: _statusFilter,
      );
      if (mounted) setState(() { _records = records; _loadError = null; });
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
      _showError('Could not load records: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Normal Person Records')),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(padding: const EdgeInsets.all(16), child: Text(_loadError!, textAlign: TextAlign.center)),
                    TextButton(onPressed: _initData, child: const Text('Retry')),
                  ]))
                : _records.isEmpty
                ? const Center(child: Text('No records found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return _buildRecordCard(record);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _fetchRecords,
                    ),
                  ),
                  onSubmitted: (_) => _fetchRecords(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Age',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _fetchRecords(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, 'All Status'),
                ...NormalRecordStatus.values.map(
                  (s) => _buildStatusChip(s, s.name.replaceAll('_', ' ')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Camp>(
            initialValue: _selectedCamp,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              labelText: 'Filter by Camp',
            ),
            items: [
              const DropdownMenuItem<Camp>(
                value: null,
                child: Text('All Camps'),
              ),
              ..._camps.map(
                (c) => DropdownMenuItem(value: c, child: Text(c.name)),
              ),
            ],
            onChanged: (val) {
              setState(() => _selectedCamp = val);
              _fetchRecords();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(NormalRecordStatus? status, String label) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        selected: isSelected,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: (val) {
          setState(() => _statusFilter = val ? status : null);
          _fetchRecords();
        },
      ),
    );
  }

  Widget _buildRecordCard(NormalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: OfficialPhotoView(
          photoLocalPath: record.photoLocalPath,
          photoUrl: record.photoUrl,
          size: 56,
          borderRadius: 4,
        ),
        title: Text(
          record.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${record.age} | ${record.campName}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(record.status).withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                record.status.name.replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(record.status),
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/normal_record_details',
            arguments: record,
          );
          if (result == true) _fetchRecords();
        },
      ),
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
