import 'package:flutter/material.dart';

import '../../emergency/data/emergency_repository.dart';
import '../../emergency/data/models/official_sos.dart';

class SosRequestDetailsScreen extends StatefulWidget {
  const SosRequestDetailsScreen({
    super.key,
    required this.repository,
    required this.sos,
  });

  final OfficialSosRepository repository;
  final OfficialSos sos;

  @override
  State<SosRequestDetailsScreen> createState() =>
      _SosRequestDetailsScreenState();
}

class _SosRequestDetailsScreenState extends State<SosRequestDetailsScreen> {
  late OfficialSos _sos = widget.sos;
  bool _updating = false;
  String? _error;

  Future<void> _changeStatus(OfficialSosStatus status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${status.name[0].toUpperCase()}${status.name.substring(1)} SOS?',
        ),
        content: Text('Mark this SOS as ${status.name.toUpperCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      final updated = await widget.repository.updateSosStatus(_sos.id, status);
      if (!mounted) return;
      setState(() {
        _sos = updated;
        _updating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Status was not changed: $error';
        _updating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = switch (_sos.status) {
      OfficialSosStatus.received => [
        OfficialSosStatus.acknowledged,
        OfficialSosStatus.resolved,
        OfficialSosStatus.cancelled,
      ],
      OfficialSosStatus.acknowledged => [
        OfficialSosStatus.resolved,
        OfficialSosStatus.cancelled,
      ],
      _ => <OfficialSosStatus>[],
    };
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Request Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'EMERGENCY REQUEST',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(_sos.id, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'STATUS: ${_sos.status.name.toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 28),
          _section('User', [_row('User reference', _sos.userUid)]),
          _section('Location', [
            _row('Latitude', _sos.latitude.toString()),
            _row('Longitude', _sos.longitude.toString()),
            _row('GPS accuracy', '${_sos.accuracy.toStringAsFixed(1)} m'),
          ]),
          _section('Times', [
            _row('Created', _sos.createdAt.toLocal().toString()),
            _row('Received', _sos.receivedAt.toLocal().toString()),
            _row('Updated', _sos.updatedAt.toLocal().toString()),
          ]),
          _section('Message', [
            _row(
              '',
              _sos.message?.isNotEmpty == true
                  ? _sos.message!
                  : 'No message provided.',
            ),
          ]),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 18),
          if (_updating)
            const Center(child: CircularProgressIndicator())
          else
            ...actions.map(
              (status) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton(
                  onPressed: () => _changeStatus(status),
                  child: Text(status.name.toUpperCase()),
                ),
              ),
            ),
          if (actions.isEmpty)
            Text(
              _sos.status == OfficialSosStatus.resolved
                  ? 'RESOLVED'
                  : 'CANCELLED',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(label.isEmpty ? value : '$label: $value'),
  );
}
