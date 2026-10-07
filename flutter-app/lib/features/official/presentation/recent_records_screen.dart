import 'package:flutter/material.dart';
import '../../../core/common_widgets/official_photo_view.dart';
import '../../../data/models/normal_record.dart';
import '../../../data/models/critical_record.dart';
import '../../../data/repositories/official_normal_record_repository.dart';
import '../../../data/repositories/official_critical_record_repository.dart';

class RecentRecordsScreen extends StatefulWidget {
  const RecentRecordsScreen({super.key});

  @override
  State<RecentRecordsScreen> createState() => _RecentRecordsScreenState();
}

class _RecentRecordsScreenState extends State<RecentRecordsScreen> {
  final _normalRepo = OfficialNormalRecordRepository();
  final _criticalRepo = OfficialCriticalRecordRepository();

  List<dynamic> _recentRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecent();
  }

  Future<void> _fetchRecent() async {
    setState(() => _isLoading = true);
    try {
      final normals = await _normalRepo.getRecentRecords();
      final criticals = await _criticalRepo.getRecentRecords();

      final combined = [...normals, ...criticals];

      // Sort combined list by createdAt descending
      combined.sort((a, b) {
        final dateA =
            (a is NormalRecord
                ? a.createdAt
                : (a as CriticalRecord).createdAt) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final dateB =
            (b is NormalRecord
                ? b.createdAt
                : (b as CriticalRecord).createdAt) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      setState(() => _recentRecords = combined);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recent records: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Records')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            width: double.infinity,
            color: Colors.blue[50],
            child: const Row(
              children: [
                Icon(Icons.sync, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Showing latest verified records from Firestore',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentRecords.isEmpty
                ? const Center(child: Text('No records found.'))
                : ListView.separated(
                    itemCount: _recentRecords.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = _recentRecords[index];
                      final bool isCritical = r is CriticalRecord;

                      return ListTile(
                        leading: OfficialPhotoView(
                          photoLocalPath: r is NormalRecord ? r.photoLocalPath : (r as CriticalRecord).photoLocalPath,
                          photoUrl: r is NormalRecord ? r.photoUrl : (r as CriticalRecord).photoUrl,
                          size: 40,
                          borderRadius: 20,
                          placeholderIcon: isCritical ? Icons.lock : Icons.person,
                          placeholderColor: isCritical ? Colors.red[50] : Colors.blue[50],
                        ),
                        title: Text(
                          isCritical ? r.name : (r as NormalRecord).name,
                        ),
                        subtitle: Text(
                          'Found at ${isCritical ? r.campName : (r as NormalRecord).campName}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isCritical
                                  ? r.status.name.replaceAll('_', ' ')
                                  : (r as NormalRecord).status.name.replaceAll(
                                      '_',
                                      ' ',
                                    ),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCritical ? Colors.red : Colors.blue,
                              ),
                            ),
                            Text(
                              '${(isCritical ? r.foundAt : (r as NormalRecord).foundAt).day}/${(isCritical ? r.foundAt : (r as NormalRecord).foundAt).month}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (isCritical) {
                            Navigator.pushNamed(
                              context,
                              '/critical_record_details',
                              arguments: r,
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/normal_record_details',
                              arguments: r,
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
