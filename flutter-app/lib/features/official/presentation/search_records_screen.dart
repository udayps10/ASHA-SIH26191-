import 'package:flutter/material.dart';
import '../../../core/common_widgets/official_photo_view.dart';
import '../../../data/models/critical_record.dart';
import '../../../data/models/normal_record.dart';
import '../../../data/repositories/official_critical_record_repository.dart';
import '../../../data/repositories/official_normal_record_repository.dart';

class SearchRecordsScreen extends StatefulWidget {
  const SearchRecordsScreen({super.key});

  @override
  State<SearchRecordsScreen> createState() => _SearchRecordsScreenState();
}

class _SearchRecordsScreenState extends State<SearchRecordsScreen> {
  final _normalRepository = OfficialNormalRecordRepository();
  final _criticalRepository = OfficialCriticalRecordRepository();
  List<Object> _allRecords = [];
  List<Object> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('[SEARCH SCREEN] opened');
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final results = await Future.wait([
        _normalRepository.searchRecords(),
        _criticalRepository.searchRecords(),
      ]);
      if (!mounted) return;
      setState(() {
        _allRecords = [
          ...results[0] as List<NormalRecord>,
          ...results[1] as List<CriticalRecord>,
        ];
        _filteredRecords = _allRecords;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load records: $e';
        _isLoading = false;
      });
    }
  }

  void _filterRecords(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        final name = record is NormalRecord
            ? record.name
            : (record as CriticalRecord).name;
        return name.toLowerCase().contains(normalizedQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Records')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterRecords,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterRecords('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : ListView.builder(
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      final isCritical = record is CriticalRecord;
                      final name = isCritical
                          ? record.name
                          : (record as NormalRecord).name;
                      final age = isCritical
                          ? record.age
                          : (record as NormalRecord).age;
                      return ListTile(
                        leading: OfficialPhotoView(
                          photoLocalPath: isCritical ? record.photoLocalPath : (record as NormalRecord).photoLocalPath,
                          photoUrl: isCritical ? record.photoUrl : (record as NormalRecord).photoUrl,
                          size: 40,
                          borderRadius: 20,
                          placeholderIcon: isCritical ? Icons.lock : Icons.person,
                          placeholderColor: isCritical ? Colors.red[50] : Colors.blue[50],
                        ),
                        title: Text(name),
                        subtitle: Text(
                          'Age: $age | ${isCritical ? 'CRITICAL' : 'NORMAL'}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showDetails(record),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetails(Object record) {
    final isCritical = record is CriticalRecord;
    final name = isCritical ? record.name : (record as NormalRecord).name;
    final age = isCritical ? record.age : (record as NormalRecord).age;
    final status = isCritical
        ? record.status.name
        : (record as NormalRecord).status.name;
    final camp = isCritical
        ? record.campName
        : (record as NormalRecord).campName;
    final officer = isCritical
        ? record.officerName
        : (record as NormalRecord).officerName;
    final contact = isCritical
        ? record.officerContact
        : (record as NormalRecord).officerContact;
    final clothing = isCritical ? record.lastKnownClothing : null;
    // Show a basic detail dialog or navigate to a details screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(
                child: OfficialPhotoView(
                  photoLocalPath: isCritical ? record.photoLocalPath : (record as NormalRecord).photoLocalPath,
                  photoUrl: isCritical ? record.photoUrl : (record as NormalRecord).photoUrl,
                  size: 200,
                  borderRadius: 16,
                  placeholderIcon: isCritical ? Icons.lock : Icons.person,
                  placeholderColor: isCritical ? Colors.red[50] : Colors.blue[50],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (isCritical)
                const Chip(
                  label: Text('CRITICAL'),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              const Divider(height: 32),
              _buildDetail('Age', '$age'),
              _buildDetail('Status', status.toUpperCase()),
              _buildDetail('Camp', camp),
              _buildDetail('Officer', officer),
              _buildDetail('Contact', contact),
              if (clothing != null) _buildDetail('Last Clothing', clothing),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (isCritical) {
                    Navigator.pushNamed(context, '/critical_record_details', arguments: record as CriticalRecord);
                  } else {
                    Navigator.pushNamed(context, '/normal_record_details', arguments: record as NormalRecord);
                  }
                },
                child: const Text('Update Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
