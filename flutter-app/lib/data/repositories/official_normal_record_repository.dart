import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/authenticated_client.dart';
import '../../core/config/api_config.dart';
import '../models/normal_record.dart';

class OfficialNormalRecordRepository {
  OfficialNormalRecordRepository({http.Client? client})
    : _client = client ?? AuthenticatedClient();
  final http.Client _client;
  final String _baseUrl = ApiConfig.matchingBaseUrl;

  Future<String> createRecord(NormalRecord record) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/normal-records'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': record.name,
            'age': record.age,
            'photoUrl': record.photoUrl,
            'campId': record.campId,
            'campName': record.campName,
            'officerUid': record.officerUid,
            'officerName': record.officerName,
            'officerContact': record.officerContact,
            'status': record.status.name,
            'additionalDetails': record.additionalDetails,
            'foundAt': record.foundAt?.toIso8601String(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final id = data['id'];
      if (id is! String || id.isEmpty)
        throw Exception('Server did not return a record ID.');
      return id;
    }
    throw _requestError(response.statusCode);
  }

  Future<List<NormalRecord>> getRecentRecords() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/api/normal-records/list'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NormalRecord.fromMap(e['id'], e)).toList();
    }
    throw _requestError(response.statusCode);
  }

  Future<List<NormalRecord>> searchRecords({
    String? name,
    int? age,
    String? campId,
    NormalRecordStatus? status,
  }) async {
    final records = await getRecentRecords();
    return records.where((r) {
      if (name != null &&
          name.isNotEmpty &&
          !r.name.toLowerCase().contains(name.toLowerCase()))
        return false;
      if (age != null && r.age != age) return false;
      if (campId != null && r.campId != campId) return false;
      if (status != null && r.status != status) return false;
      return true;
    }).toList();
  }

  Future<NormalRecord?> getRecordById(String id) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/api/normal-records/$id'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NormalRecord.fromMap(data['id'], data);
    }
    if (response.statusCode == 404) return null;
    throw _requestError(response.statusCode);
  }

  Future<void> updateStatus(String recordId, NormalRecordStatus status) async {
    final response = await _client
        .patch(
          Uri.parse('$_baseUrl/api/normal-records/$recordId/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': status.name}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _requestError(response.statusCode);
    }
  }

  Exception _requestError(int status) => Exception(
    status == 401 || status == 403
        ? 'Your session has expired or access was denied. Please sign in again.'
        : 'Could not load or save the record (HTTP $status). Please retry.',
  );
}
