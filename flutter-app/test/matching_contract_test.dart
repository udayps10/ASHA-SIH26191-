import 'package:flutter_test/flutter_test.dart';
import 'package:aasha/features/matching/data/models/match_request.dart';
import 'package:aasha/features/matching/data/models/match_result.dart';
import 'package:aasha/features/matching/data/models/match_response.dart';
import 'package:aasha/features/matching/data/repositories/match_repository.dart';
import 'package:aasha/features/matching/data/services/match_api_service.dart';

void main() {
  test('valid match request serializes the contract fields', () {
    final request = MatchRequest(
      name: '  Jane Doe ',
      age: 24,
      photoReference: 'future-reference',
      lastKnownLocation: 'North camp',
      additionalDetails: 'Small scar',
    );

    expect(request.validate(), isEmpty);
    expect(request.toJson(), {
      'name': 'Jane Doe',
      'age': 24,
      'photo': 'future-reference',
      'lastKnownLocation': 'North camp',
      'additionalDetails': 'Small scar',
    });
  });

  test('invalid name and age are rejected by the repository', () async {
    final repository = MatchRepository(_FakeApi());

    expect(
      () => repository.findMatches(MatchRequest(name: ' ', age: 24)),
      throwsA(isA<MatchApiException>()),
    );
    expect(
      () => repository.findMatches(MatchRequest(name: 'Jane', age: 131)),
      throwsA(isA<MatchApiException>()),
    );
  });

  test('normal match response parses ranked results', () {
    final response = MatchResponse.fromJson({
      'requestId': 'request-1',
      'hasMore': true,
      'nextPageToken': 'page-2',
      'results': [
        {
          'recordId': 'normal-1',
          'name': 'Jane Doe',
          'age': 24,
          'photoUrl': 'https://example/photo.jpg',
          'campName': 'Camp A',
          'officerName': 'Officer A',
          'officerContact': '111',
          'status': 'atCamp',
          'matchConfidence': 94,
        },
      ],
    });

    expect(response.results, hasLength(1));
    expect(response.results.single, isA<NormalMatchResult>());
    expect((response.results.single as NormalMatchResult).photoUrl, isNotNull);
    expect((response.results.single as NormalMatchResult).matchConfidence, 94);
    expect(response.hasMore, isTrue);
  });

  test('FastAPI snake_case response is accepted', () {
    final response = MatchResponse.fromJson({
      'request_id': 'demo-request-001',
      'has_more': true,
      'next_page_token': 'page-2',
      'results': [
        {
          'record_id': 'normal-1',
          'name': 'Rahul Sharma',
          'age': 24,
          'camp_name': 'Demo Camp',
          'officer_name': 'Officer',
          'officer_contact': '123',
          'status': 'AT_CAMP',
          'match_confidence': 94.0,
          'record_type': 'normal',
        },
      ],
    });
    expect(response.requestId, 'demo-request-001');
    expect(response.nextPageToken, 'page-2');
    expect(response.results.single.recordId, 'normal-1');
  });

  test('real Firestore response shape with match_score parses', () {
    final response = MatchResponse.fromJson({
      'request_id': 'real-request',
      'results': [
        {
          'record_id': 'real-normal',
          'name': 'aman',
          'age': 22,
          'camp_name': 'central relief camp',
          'officer_name': 'Admin',
          'officer_contact': 'admin@example.com',
          'status': 'AT_CAMP',
          'match_score': 39.32,
          'record_type': 'normal',
        },
        {
          'record_id': 'real-critical',
          'name': 'na',
          'age': 35,
          'camp_name': 'central relief camp',
          'officer_name': 'Admin',
          'officer_contact': 'admin@example.com',
          'status': 'CRITICAL',
          'match_score': 29.8,
          'record_type': 'critical',
          'last_known_clothing': 'blue shirt black pant',
        },
      ],
      'has_more': false,
    });
    expect(response.results, hasLength(2));
    expect(response.results[0].matchConfidence, 39.32);
    expect(response.results[1], isA<CriticalMatchResult>());
  });

  test('critical response parses only sanitized public fields', () {
    final response = MatchResponse.fromJson({
      'hasMore': false,
      'results': [
        {
          'recordType': 'critical',
          'recordId': 'critical-1',
          'name': 'John Doe',
          'age': 31,
          'lastKnownClothing': 'Blue shirt',
          'campName': 'Camp B',
          'officerName': 'Officer B',
          'officerContact': '222',
          'matchConfidence': 91,
          'photoUrl': 'must-not-be-exposed',
          'clothingPhotoUrl': 'must-not-be-exposed',
        },
      ],
    });

    final result = response.results.single;
    expect(result, isA<CriticalMatchResult>());
    expect((result as CriticalMatchResult).lastKnownClothing, 'Blue shirt');
    // CriticalMatchResult intentionally has no photoUrl or clothingPhotoUrl.
    expect(result is NormalMatchResult, isFalse);
  });

  test('top three and load-more continuation are represented', () async {
    final response = await MatchRepository(_FakeApi()).findMatches(
      MatchRequest(name: 'Jane', age: 24),
    );
    expect(response.results, hasLength(3));
    expect(response.nextPageToken, 'page-2');

    final more = await MatchRepository(_FakeApi()).getMoreMatches(
      MatchPageRequest(requestId: 'request-1', pageToken: 'page-2'),
    );
    expect(more.results, hasLength(1));
  });

  test('API errors parse without exposing internal details', () {
    final error = MatchApiException.fromResponse(429, {
      'error': {'code': 'rate_limited', 'message': 'Too many requests'},
    });
    expect(error.statusCode, 429);
    expect(error.code, 'rate_limited');
    expect(error.message, 'Too many requests');
    expect(MatchApiException.fromResponse(500, null).message,
        'Matching service unavailable');
  });
}

class _FakeApi implements MatchApiService {
  @override
  Future<MatchResponse> findMatches(MatchRequest request) async =>
      MatchResponse(
        requestId: 'request-1',
        nextPageToken: 'page-2',
        hasMore: true,
        results: List.generate(
          3,
          (index) => NormalMatchResult(
            recordId: 'normal-$index',
            name: 'Jane',
            age: 24,
            campName: 'Camp',
            officerName: 'Officer',
            officerContact: '123',
            matchConfidence: 90 - index,
          ),
        ),
      );

  @override
  Future<MatchResponse> getMoreMatches(MatchPageRequest request) async =>
      MatchResponse(
        results: [
          NormalMatchResult(
            recordId: 'normal-3',
            name: 'Jane',
            age: 24,
            campName: 'Camp',
            officerName: 'Officer',
            officerContact: '123',
            matchConfidence: 87,
          ),
        ],
        hasMore: false,
      );
}
