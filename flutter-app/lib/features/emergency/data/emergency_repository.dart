import 'models/disaster_zone.dart';
import 'models/emergency_alert.dart';
import 'models/user_sos.dart';
import 'models/official_sos.dart';
import '../../../data/sync/sync_service.dart';

enum SosDeliveryState { pendingLocal, submitted, failed }

abstract interface class OfficialSosRepository {
  Future<List<OfficialSos>> getSosRequests({OfficialSosStatus? status});
  Future<OfficialSos> getSosRequest(String id);
  Future<OfficialSos> updateSosStatus(String id, OfficialSosStatus status);
}

class SosSubmissionResult {
  final SosDeliveryState state;
  final String message;

  const SosSubmissionResult({required this.state, required this.message});
}

abstract interface class EmergencyRepository {
  Future<List<EmergencyAlert>> getActiveAlerts();

  Future<List<DisasterZone>> getActiveDisasterZones();

  Future<SosSubmissionResult> submitSos(UserSos sos);

  bool get lastFetchUsedCache => false;

  String? get lastError => null;
}

/// Placeholder until the backend contract is implemented and verified.
class LocalEmergencyRepository implements EmergencyRepository {
  LocalEmergencyRepository({SyncService? syncService})
    : _syncService = syncService ?? SyncService.instance;

  final SyncService _syncService;

  @override
  bool get lastFetchUsedCache => false;

  @override
  String? get lastError => null;

  @override
  Future<List<EmergencyAlert>> getActiveAlerts() async => const [];

  @override
  Future<List<DisasterZone>> getActiveDisasterZones() async => const [];

  @override
  Future<SosSubmissionResult> submitSos(UserSos sos) async {
    if (sos.userId != null && _syncService.ownerUid != sos.userId) {
      await _syncService.startSession(sos.userId!);
    }
    final delivered = await _syncService.saveSos(sos);
    if (delivered) {
      return const SosSubmissionResult(
        state: SosDeliveryState.submitted,
        message: 'SOS sent. The emergency service confirmed receipt.',
      );
    }
    return const SosSubmissionResult(
      state: SosDeliveryState.pendingLocal,
      message:
          'No internet connection. SOS has been saved on this device and will be sent when connection is restored.',
    );
  }
}
