import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../features/auth/data/auth_service.dart';
import '../../../core/utils/location_service.dart';
import '../../../data/local/database/app_database.dart' as local;
import '../../../data/local/repositories/local_alert_repository.dart';
import '../../../data/sync/sync_service.dart';
import '../domain/safety_calculator.dart';
import 'emergency_repository.dart';
import 'models/disaster_zone.dart';
import 'models/emergency_alert.dart';
import 'models/user_sos.dart';
import 'models/official_sos.dart';

class SpringBootEmergencyRepository
    implements EmergencyRepository, OfficialSosRepository {
  SpringBootEmergencyRepository({
    http.Client? client,
    LocalAlertRepository? localAlerts,
    String? baseUrl,
    SyncService? syncService,
    AuthService? authService,
    this._tokenProvider,
  }) : _client = client ?? http.Client(),
       _localAlerts =
           localAlerts ??
           LocalAlertRepository(local.LocalDatabase.instance.database),
       _baseUrl = baseUrl ?? ApiConfig.matchingBaseUrl,
       _localEmergency = LocalEmergencyRepository(syncService: syncService),
       _syncService = syncService ?? SyncService.instance,
       _authService = authService ?? AuthService() {
    _syncService.configureSosSubmitter(_postSos);
  }

  final http.Client _client;
  final LocalAlertRepository _localAlerts;
  final String _baseUrl;
  final LocalEmergencyRepository _localEmergency;
  final SyncService _syncService;
  final AuthService _authService;
  final Future<String?> Function()? _tokenProvider;

  @override
  bool lastFetchUsedCache = false;

  @override
  String? lastError;

  @override
  Future<List<EmergencyAlert>> getActiveAlerts() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/alerts/active'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw StateError('Alert request failed (${response.statusCode})');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid alert response');
      }
      final alerts = <EmergencyAlert>[];
      for (final value in decoded) {
        if (value is! Map) continue;
        try {
          alerts.add(EmergencyAlert.fromJson(value.cast<String, dynamic>()));
        } catch (error) {
          debugPrint('Skipping malformed emergency alert: $error');
        }
      }
      if (decoded.isNotEmpty && alerts.isEmpty) {
        throw const FormatException('No valid alerts in response');
      }
      await _localAlerts.replaceActive(alerts);
      lastFetchUsedCache = false;
      lastError = null;
      return alerts;
    } catch (error) {
      lastFetchUsedCache = true;
      lastError = error.toString();
      return _localAlerts.getActive();
    }
  }

  @override
  Future<List<DisasterZone>> getActiveDisasterZones() async {
    final alerts = await getActiveAlerts();
    return alerts
        .where(
          (alert) =>
              alert.latitude != null &&
              alert.longitude != null &&
              alert.radiusKm != null &&
              alert.radiusKm! > 0,
        )
        .map(
          (alert) => DisasterZone(
            id: alert.id,
            disasterType: alert.disasterType,
            latitude: alert.latitude!,
            longitude: alert.longitude!,
            radiusKm: alert.radiusKm!,
            severity: alert.severity,
            title: alert.title,
            active: alert.active,
          ),
        )
        .toList();
  }

  double? distanceFromUser(EmergencyAlert alert, LocationResult? location) {
    if (location == null || alert.latitude == null || alert.longitude == null) {
      return null;
    }
    return SafetyCalculator.distanceKmBetween(
      location.latitude,
      location.longitude,
      alert.latitude!,
      alert.longitude!,
    );
  }

  @override
  Future<SosSubmissionResult> submitSos(UserSos sos) =>
      _localEmergency.submitSos(sos);

  @override
  Future<List<OfficialSos>> getSosRequests({OfficialSosStatus? status}) async {
    final query = status == null ? '' : '?status=${status.name.toUpperCase()}';
    final response = await _authorizedGet('/api/sos$query');
    final decoded = jsonDecode(response.body);
    if (decoded is! List) throw const FormatException('Invalid SOS list');
    final requests = <OfficialSos>[];
    for (final value in decoded) {
      if (value is! Map) continue;
      try {
        requests.add(OfficialSos.fromJson(value.cast<String, dynamic>()));
      } on FormatException catch (error) {
        debugPrint('Skipping malformed SOS request: $error');
      }
    }
    return requests;
  }

  @override
  Future<OfficialSos> getSosRequest(String id) async {
    final response = await _authorizedGet('/api/sos/$id');
    return OfficialSos.fromJson(jsonDecode(response.body));
  }

  @override
  Future<OfficialSos> updateSosStatus(
    String id,
    OfficialSosStatus status,
  ) async {
    final token = await _loadToken();
    final response = await _client.patch(
      Uri.parse('$_baseUrl/api/sos/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status.name.toUpperCase()}),
    );
    if (response.statusCode != 200) {
      throw StateError('SOS status update failed (${response.statusCode})');
    }
    return OfficialSos.fromJson(jsonDecode(response.body));
  }

  Future<http.Response> _authorizedGet(String path) async {
    final token = await _loadToken();
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw StateError('SOS request failed (${response.statusCode})');
    }
    return response;
  }

  Future<void> _postSos(Map<String, dynamic> payload) async {
    final token = _tokenProvider == null
        ? await _loadToken()
        : await _tokenProvider();
    if (token == null || token.isEmpty) {
      throw StateError('Authentication is required to submit SOS');
    }
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/sos'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id': payload['id'],
            'latitude': payload['latitude'],
            'longitude': payload['longitude'],
            'accuracy': payload['accuracy'],
            'message': payload['message'],
            'createdAt': payload['createdAt'],
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError('SOS request failed (${response.statusCode})');
    }
  }

  Future<String?> _loadToken() async {
    await _authService.tryAutoLogin();
    return _authService.token;
  }
}
