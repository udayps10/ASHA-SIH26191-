import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/app_state.dart';
import '../../../data/sync/sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/official_normal_record_repository.dart';
import '../../../data/repositories/official_critical_record_repository.dart';

class OfficialDashboardScreen extends StatefulWidget {
  const OfficialDashboardScreen({super.key});

  @override
  State<OfficialDashboardScreen> createState() =>
      _OfficialDashboardScreenState();
}

class _OfficialDashboardScreenState extends State<OfficialDashboardScreen> {
  final _normalRepo = OfficialNormalRecordRepository();
  final _criticalRepo = OfficialCriticalRecordRepository();

  int _recordCount = 0;
  bool _isCounting = true;
  late final SyncService _syncService;
  SyncPhase? _lastSyncPhase;
  bool? _lastOnline;
  bool _syncStartedAfterReconnect = false;

  @override
  void initState() {
    super.initState();
    _syncService = context.read<AppState>().syncService;
    _lastSyncPhase = _syncService.phase;
    _lastOnline = _syncService.online;
    _syncService.addListener(_onSyncChanged);
    _fetchStats();
  }

  void _onSyncChanged() {
    if (!mounted) return;
    final phase = _syncService.phase;
    final becameOnline = _lastOnline == false && _syncService.online == true;
    if (becameOnline) _syncStartedAfterReconnect = true;
    if (phase == SyncPhase.syncing &&
        _lastSyncPhase != SyncPhase.syncing &&
        _syncStartedAfterReconnect) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Syncing records…')));
    } else if (phase == SyncPhase.complete &&
        _lastSyncPhase == SyncPhase.syncing &&
        _syncStartedAfterReconnect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Records synced successfully.')),
      );
      _syncStartedAfterReconnect = false;
    }
    _lastSyncPhase = phase;
    _lastOnline = _syncService.online;
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncChanged);
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final normals = await _normalRepo.getRecentRecords();
      final criticals = await _criticalRepo.getRecentRecords();
      if (mounted) {
        setState(() {
          _recordCount = normals.length + criticals.length;
          _isCounting = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCounting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.officialDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  Icons.assignment_outlined,
                  'Relocation Planning',
                  '/relocation_planning',
                ),
                _buildActionCard(
                  context,
                  Icons.location_city,
                  'Manage Camps',
                  '/manage_camps',
                ),
                _buildActionCard(
                  context,
                  Icons.people,
                  'Normal Records',
                  '/normal_records_list',
                ),
                _buildActionCard(
                  context,
                  Icons.local_hospital,
                  'Critical Records',
                  '/critical_records_list',
                  color: Colors.black,
                ),
                _buildActionCard(
                  context,
                  Icons.person_add,
                  'Add Normal Person',
                  '/add_normal',
                ),
                _buildActionCard(
                  context,
                  Icons.warning_amber,
                  'Add Critical Record',
                  '/add_critical',
                  color: AppTheme.accentColor,
                ),
                _buildActionCard(
                  context,
                  Icons.search,
                  'Search Records',
                  '/official_search',
                ),
                _buildActionCard(
                  context,
                  Icons.history,
                  'Recent Records',
                  '/recent_records',
                ),
                _buildActionCard(
                  context,
                  Icons.cloud_upload,
                  'Pending Sync',
                  '/pending_sync',
                ),
                _buildActionCard(
                  context,
                  Icons.sos,
                  'Send Emergency SOS',
                  '/sos',
                  color: AppTheme.accentColor,
                ),
                _buildActionCard(
                  context,
                  Icons.notifications_active,
                  'SOS Requests',
                  '/sos_requests',
                  color: AppTheme.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final sync = context.watch<AppState>().syncService;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            sync.online == false
                ? 'Offline'
                : (sync.phase == SyncPhase.syncing ? 'Syncing' : 'Online'),
            sync.online == false ? Icons.wifi_off : Icons.wifi,
            sync.online == false ? Colors.orange : Colors.green,
          ),
          _buildStatusItem(
            sync.phase == SyncPhase.failed
                ? 'Sync failed'
                : (sync.phase == SyncPhase.syncing
                      ? 'Syncing'
                      : 'Pending sync'),
            Icons.cloud_upload,
            sync.phase == SyncPhase.failed ? Colors.red : Colors.grey,
          ),
          _buildStatusItem(
            _isCounting ? '...' : '$_recordCount Records',
            Icons.description,
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    Color? color,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(context, route);
        if (result == true) _fetchStats();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color ?? AppTheme.primaryColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
