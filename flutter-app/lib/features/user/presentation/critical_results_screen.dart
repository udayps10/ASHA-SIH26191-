import 'package:flutter/material.dart';
import '../../../features/matching/data/models/match_request.dart';
import '../../../features/matching/data/models/match_result.dart';
import '../../../features/matching/data/repositories/match_repository.dart';
import '../../../features/matching/data/services/match_api_service.dart';

class CriticalResultsScreen extends StatefulWidget {
  const CriticalResultsScreen({super.key});

  @override
  State<CriticalResultsScreen> createState() => _CriticalResultsScreenState();
}

class _CriticalResultsScreenState extends State<CriticalResultsScreen> {
  final _matchRepository = MatchRepository(HttpMatchApiService());
  List<CriticalMatchResult> _matches = [];
  bool _isLoading = true;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _fetchMatches();
    }
  }

  Future<void> _fetchMatches() async {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is! MatchRequest) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _matchRepository.findMatches(args);
      if (mounted) {
        setState(() {
          _matches = response.results.whereType<CriticalMatchResult>().toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final message = e is MatchApiException
            ? e.message
            : 'Unable to load critical matches. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Critical Records'),
        backgroundColor: Colors.red[900],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Possible Critical Matches',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'For privacy and sensitivity, photographs of deceased or critical persons are never shown to the public. Please review the identifying details below.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (_matches.isEmpty)
              const Center(child: Text('No critical records matching these details were found.'))
            else
              ..._matches.map((record) => _buildCriticalCard(context, record)),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'If you recognize any of these details, please contact the listed official immediately.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalCard(BuildContext context, CriticalMatchResult record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red[100]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatConfidence(record.matchConfidence)}% Match Score',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (record.matchLabel != null)
                      Text(
                        record.matchLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (record.explanation != null)
                  Expanded(
                    child: Text(
                      record.explanation!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Name', record.name),
            _buildDetailRow('Age', '${record.age}'),
            _buildDetailRow('Last Clothing', record.lastKnownClothing ?? 'Not provided'),
            _buildDetailRow('Found At', record.campName),
            _buildDetailRow('Officer', record.officerName),
            _buildDetailRow('Contact', record.officerContact),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Please contact the listed official/camp to confirm identity.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatConfidence(num confidence) => confidence % 1 == 0
      ? confidence.toInt().toString()
      : confidence.toString();

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
