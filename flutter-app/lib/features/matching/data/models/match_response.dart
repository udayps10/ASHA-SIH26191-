import 'match_result.dart';

class MatchResponse {
  MatchResponse({
    required this.results,
    required this.hasMore,
    this.requestId,
    this.nextPageToken,
  });

  final List<MatchResult> results;
  final bool hasMore;
  final String? requestId;
  final String? nextPageToken;

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    if (rawResults is! List) {
      throw FormatException(
        'Invalid match results: expected List, got ${rawResults.runtimeType}',
      );
    }
    return MatchResponse(
      results: rawResults.map<MatchResult>((item) {
        if (item is! Map) {
          throw FormatException(
            'Invalid match result at index: expected Map, got ${item.runtimeType}',
          );
        }
        final value = Map<String, dynamic>.from(item);
        return (value['recordType'] ?? value['record_type']) == 'critical'
            ? CriticalMatchResult.fromJson(value)
            : NormalMatchResult.fromJson(value);
      }).toList(),
      hasMore: json['hasMore'] == true || json['has_more'] == true,
      requestId: (json['requestId'] ?? json['request_id']) as String?,
      nextPageToken: (json['nextPageToken'] ?? json['next_page_token']) as String?,
    );
  }
}

class MatchPageRequest {
  MatchPageRequest({required this.requestId, required this.pageToken});

  final String requestId;
  final String pageToken;

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'page_token': pageToken,
  };
}
