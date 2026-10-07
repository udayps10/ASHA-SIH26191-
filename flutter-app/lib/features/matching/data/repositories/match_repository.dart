import '../models/match_request.dart';
import '../models/match_response.dart';
import '../services/match_api_service.dart';

class MatchRepository {
  MatchRepository(this._api);

  final MatchApiService _api;

  Future<MatchResponse> findMatches(MatchRequest request) {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      throw MatchApiException(statusCode: 400, message: errors.join(', '));
    }
    return _api.findMatches(request);
  }

  Future<MatchResponse> getMoreMatches(MatchPageRequest request) =>
      _api.getMoreMatches(request);
}
