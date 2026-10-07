import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_state.dart';
import '../../../data/sync/sync_service.dart';

class PendingSyncScreen extends StatelessWidget {
  const PendingSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.read<AppState>().syncService;
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Sync')),
      body: ListenableBuilder(
        listenable: sync,
        builder: (context, _) => FutureBuilder<List<List<dynamic>>>(
          future: Future.wait([
            sync.queue.getPending(ownerUid: sync.ownerUid),
            sync.queue.getByStatus('syncing', ownerUid: sync.ownerUid),
            sync.queue.getByStatus('failed', ownerUid: sync.ownerUid),
          ]),
          builder: (context, snapshot) {
            final pending = snapshot.data?[0].length ?? 0;
            final syncing = snapshot.data?[1].length ?? 0;
            final failed = snapshot.data?[2].length ?? 0;
            final isOnline = sync.online == true;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: Icon(
                    isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: isOnline ? Colors.green : Colors.orange,
                  ),
                  title: Text(isOnline ? 'Online' : 'Offline'),
                  subtitle: Text(
                    sync.phase == SyncPhase.syncing
                        ? 'Synchronizing records…'
                        : (sync.lastError ?? 'Local records remain available.'),
                  ),
                ),
                const Divider(),
                _count('Pending', pending, Icons.schedule),
                _count('Syncing', syncing, Icons.sync),
                _count('Failed', failed, Icons.error_outline),
                const SizedBox(height: 24),
                if (sync.lastSuccessfulSync != null)
                  Text(
                    'Last successful sync: ${sync.lastSuccessfulSync!.toLocal()}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: sync.phase == SyncPhase.syncing
                      ? null
                      : sync.syncAll,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
                if (failed > 0)
                  TextButton(
                    onPressed: sync.syncAll,
                    child: const Text('Retry failed items'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _count(String label, int value, IconData icon) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: Text(
      '$value',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}
