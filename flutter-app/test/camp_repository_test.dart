import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/data/repositories/camp_repository.dart';

void main() {
  test('active camps use the backend active-list route and parse results', () async {
    final repository = CampRepository(client: MockClient((request) async {
      expect(request.url.path, '/api/camps/list/active');
      return http.Response('[{"id":"camp-1","name":"Camp Alpha","active":true}]', 200);
    }));
    final camps = await repository.getActiveCamps();
    expect(camps.single.id, 'camp-1');
    expect(camps.single.name, 'Camp Alpha');
  });
  test('all camps use the backend list route', () async {
    final repository = CampRepository(client: MockClient((request) async {
      expect(request.url.path, '/api/camps/list');
      return http.Response('[]', 200);
    }));
    expect(await repository.getAllCamps(), isEmpty);
  });
  test('failed lookup is not silently treated as an empty camp list', () async {
    final repository = CampRepository(client: MockClient((_) async => http.Response('', 401)));
    expect(repository.getActiveCamps(), throwsException);
  });
}
