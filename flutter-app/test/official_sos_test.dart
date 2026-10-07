import 'package:flutter_test/flutter_test.dart';
import 'package:aasha/features/emergency/data/models/official_sos.dart';

void main() {
  test('parses all official SOS statuses', () {
    for (final status in OfficialSosStatus.values) {
      final sos = OfficialSos.fromJson(_json(status.name.toUpperCase()));
      expect(sos.status, status);
    }
  });

  test('rejects malformed official SOS responses', () {
    final malformed = _json('RECEIVED')..remove('updatedAt');
    expect(() => OfficialSos.fromJson(malformed), throwsFormatException);
  });
}

Map<String, dynamic> _json(String status) => {
  'id': 'sos-1',
  'userUid': 'user-1',
  'latitude': 19.1,
  'longitude': 72.9,
  'accuracy': 8,
  'message': 'Need help',
  'status': status,
  'createdAt': '2026-09-17T12:00:00',
  'receivedAt': '2026-09-17T12:00:01',
  'updatedAt': '2026-09-17T12:00:01',
};
