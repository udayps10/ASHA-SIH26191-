import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../domain/safety_zone.dart';

class LiveHazard {
  final SafetyResult result;
  final double? rainfallMmhr, elevationM;
  final String? observedAt;
  final String source;
  const LiveHazard({
    required this.result,
    this.rainfallMmhr,
    this.elevationM,
    this.observedAt,
    required this.source,
  });

  factory LiveHazard.fromJson(Map<String, dynamic> json) {
    final score = json['riskScore'];
    if (score != null && (score is! int || score < 0 || score > 100)) {
      throw const FormatException('Invalid risk score');
    }
    double? number(String name) {
      final value = json[name];
      if (value == null) return null;
      if (value is! num || !value.isFinite) {
        throw const FormatException('Invalid measurement');
      }
      return value.toDouble();
    }

    final rain = number('rainfallMmhr');
    if (rain == null && score != null) {
      throw const FormatException('Score without rainfall');
    }
    final zone = score == null
        ? SafetyZone.unknown
        : score >= 80
        ? SafetyZone.red
        : score >= 50
        ? SafetyZone.orange
        : score >= 30
        ? SafetyZone.yellow
        : SafetyZone.green;
    return LiveHazard(
      result: SafetyResult(
        zone: zone,
        riskScore: score,
        factors: [
          if (rain != null)
            SafetyFactor(
              factorName: 'Modelled rainfall: ${rain.toStringAsFixed(1)} mm/h',
              contributionScore: (score ?? 0).toDouble(),
            ),
        ],
      ),
      rainfallMmhr: rain,
      elevationM: number('elevationM'),
      observedAt: json['observedAt'] as String?,
      source: json['dataSource'] as String? ?? 'Open-Meteo',
    );
  }

  /// Keep the higher warning. Weather cannot clear a reported disaster zone.
  SafetyResult combine(SafetyResult? reported) {
    if (result.riskScore == null) return reported ?? result;
    int rank(SafetyZone zone) => switch (zone) {
      SafetyZone.red => 4,
      SafetyZone.orange => 3,
      SafetyZone.yellow => 2,
      SafetyZone.green => 1,
      _ => 0,
    };
    if (reported != null &&
        (rank(reported.zone) > rank(result.zone) ||
            (reported.riskScore ?? 0) >= result.riskScore!)) {
      return reported;
    }
    return SafetyResult(
      zone: result.zone,
      riskScore: result.riskScore,
      factors: result.factors,
      distanceFromDisasterKm: reported?.distanceFromDisasterKm,
      radiusKm: reported?.radiusKm,
      percentageOfRadius: reported?.percentageOfRadius,
    );
  }

  String get details =>
      'Rainfall: ${rainfallMmhr == null ? "unavailable" : "${rainfallMmhr!.toStringAsFixed(1)} mm/h (model estimate)"}\n'
      'Elevation: ${elevationM == null ? "unavailable" : "${elevationM!.toStringAsFixed(0)} m above sea level (context only)"}\n'
      '${observedAt == null ? "Weather time unavailable" : "Weather time: $observedAt"}\n'
      'Source: $source • open-meteo.com\n'
      'Partial data: river distance, slope, drainage, flood history and land use unavailable. This is not a flood probability.';
}

class LiveHazardRepository {
  final http.Client _client;
  final String _baseUrl;
  LiveHazardRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.matchingBaseUrl;
  Future<LiveHazard> fetch(double latitude, double longitude) async {
    final uri = Uri.parse('$_baseUrl/api/hazard/risk').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw StateError('Live environmental data unavailable');
    }
    return LiveHazard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  void close() => _client.close();
}
