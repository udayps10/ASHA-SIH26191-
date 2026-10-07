import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/data/repositories/official_normal_record_repository.dart';
import '../lib/data/models/normal_record.dart';

void main() {
  test('record list uses backend route and parses normal records', () async {
    final repo = OfficialNormalRecordRepository(
      client: MockClient((request) async {
        expect(request.url.path, '/api/normal-records/list');
        return http.Response(
          '[{"id":"one","name":"Example","age":20,"status":"AT_CAMP","photoUrl":"/uploads/one/photo.jpg"}]',
          200,
        );
      }),
    );
    expect(
      (await repo.getRecentRecords()).single.photoUrl,
      '/uploads/one/photo.jpg',
    );
  });
  test('expired login is not presented as an empty list', () async {
    final repo = OfficialNormalRecordRepository(
      client: MockClient((_) async => http.Response('', 401)),
    );
    await expectLater(
      repo.getRecentRecords(),
      throwsA(predicate((e) => e.toString().contains('sign in again'))),
    );
  });
  test('failed status change is not treated as success', () async {
    final repo = OfficialNormalRecordRepository(
      client: MockClient((_) async => http.Response('', 500)),
    );
    await expectLater(
      repo.updateStatus('one', NormalRecordStatus.FOUND),
      throwsException,
    );
  });
}
