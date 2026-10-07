import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../emergency/data/emergency_repository.dart';
import '../../emergency/data/models/official_sos.dart';
import '../../emergency/data/spring_boot_emergency_repository.dart';
import 'sos_request_details_screen.dart';

class SosRequestsScreen extends StatefulWidget {
  const SosRequestsScreen({super.key, this.repository});

  final OfficialSosRepository? repository;

  @override
  State<SosRequestsScreen> createState() => _SosRequestsScreenState();
}

class _SosRequestsScreenState extends State<SosRequestsScreen> {
  late final OfficialSosRepository _repository =
      widget.repository ?? SpringBootEmergencyRepository();
  List<OfficialSos> _requests = [];
  OfficialSosStatus? _filter;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final requests = await _repository.getSosRequests(status: _filter);
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load SOS requests: $error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS Requests')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<OfficialSosStatus?>(
              initialValue: _filter,
              decoration: const InputDecoration(labelText: 'Filter by status'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All requests'),
                ),
                ...OfficialSosStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _filter = value);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, textAlign: TextAlign.center),
                    ),
                  )
                : _requests.isEmpty
                ? const Center(child: Text('No SOS requests found.'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) => _card(_requests[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(OfficialSos sos) {
    final isNew = sos.status == OfficialSosStatus.received;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNew ? AppTheme.accentColor : AppTheme.primaryColor,
          child: Icon(
            isNew ? Icons.priority_high : Icons.sos,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(sos.id)),
            _badge(sos.status),
          ],
        ),
        subtitle: Text(
          'Received ${sos.receivedAt.toLocal()}\n${sos.latitude.toStringAsFixed(5)}, ${sos.longitude.toStringAsFixed(5)}${sos.message == null ? '' : '\n${sos.message}'}',
        ),
        isThreeLine: true,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SosRequestDetailsScreen(repository: _repository, sos: sos),
            ),
          );
          _load();
        },
      ),
    );
  }

  Widget _badge(OfficialSosStatus status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    color: _statusColor(status).withAlpha(30),
    child: Text(
      status.name.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: _statusColor(status),
      ),
    ),
  );

  Color _statusColor(OfficialSosStatus status) => switch (status) {
    OfficialSosStatus.received => Colors.red.shade700,
    OfficialSosStatus.acknowledged => Colors.orange.shade800,
    OfficialSosStatus.resolved => Colors.green.shade700,
    OfficialSosStatus.cancelled => Colors.grey.shade700,
  };
}
