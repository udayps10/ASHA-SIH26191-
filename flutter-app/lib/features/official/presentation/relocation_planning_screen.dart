import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/authenticated_client.dart';
import '../../../core/utils/location_service.dart';

class RelocationPlanningScreen extends StatefulWidget {
  const RelocationPlanningScreen({super.key, this.client});
  final http.Client? client;
  @override
  State<RelocationPlanningScreen> createState() =>
      _RelocationPlanningScreenState();
}

class _RelocationPlanningScreenState extends State<RelocationPlanningScreen> {
  late final http.Client _client = widget.client ?? AuthenticatedClient();
  Map<String, dynamic>? _state;
  String? _error;
  bool _busy = false, _editing = false;
  Timer? _timer;
  List<dynamic> get _villages => _state?['habitations'] as List<dynamic>? ?? [];
  Map<String, dynamic> get _result =>
      _state?['result'] as Map<String, dynamic>? ?? {};
  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_editing) _refresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _client.close();
    super.dispose();
  }

  Future<dynamic> _api(String path, {Object? body}) async {
    final uri = Uri.parse(
      '${ApiConfig.matchingBaseUrl}/api/relocation/evacuation$path',
    );
    final r =
        await (body == null
                ? _client.get(uri)
                : _client.post(
                    uri,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(body),
                  ))
            .timeout(const Duration(seconds: 20));
    final d = jsonDecode(r.body);
    if (r.statusCode >= 400) {
      throw Exception(
        d is Map
            ? (d['error'] ?? d['message'] ?? 'Request failed')
            : 'Request failed',
      );
    }
    return d;
  }

  Future<void> _refresh({String path = '', Object? body}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final s = await _api(path, body: body);
      if (mounted) setState(() => _state = s as Map<String, dynamic>);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error =
              'Live priority unavailable. ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<LatLng?> _mapPoint({LatLng? initial, bool select = true}) async {
    LatLng? picked = initial;
    return showDialog<LatLng>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(select ? 'Pick habitation location' : 'Active red zones'),
          content: SizedBox(
            width: 600,
            height: 380,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: initial ?? const LatLng(22.5, 79),
                initialZoom: initial == null ? 5 : 13,
                onTap: select ? (_, p) => update(() => picked = p) : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aasha.disasterconnect',
                ),
                CircleLayer(
                  circles: [
                    for (final z in _result['zones'] ?? [])
                      CircleMarker(
                        point: LatLng(
                          (z['latitude'] as num).toDouble(),
                          (z['longitude'] as num).toDouble(),
                        ),
                        radius: (z['radiusKm'] as num).toDouble() * 1000,
                        useRadiusInMeter: true,
                        color: Colors.red.withAlpha(45),
                        borderColor: Colors.red,
                        borderStrokeWidth: 2,
                      ),
                  ],
                ),
                if (picked != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: picked!,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (select)
              FilledButton(
                onPressed: picked == null
                    ? null
                    : () => Navigator.pop(context, picked),
                child: const Text('Use this location'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit([Map<String, dynamic>? old]) async {
    _editing = true;
    final name = TextEditingController(text: old?['name'] ?? '');
    final population = TextEditingController(
      text: old?['population']?.toString() ?? '',
    );
    LatLng? point = old == null
        ? null
        : LatLng(
            (old['latitude'] as num).toDouble(),
            (old['longitude'] as num).toDouble(),
          );
    String? error;
    bool locating = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Habitation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Habitation Name',
                  ),
                ),
                TextField(
                  controller: population,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Population',
                  ),
                ),
                Text(
                  point == null
                      ? 'Location: choose a point'
                      : 'Location selected',
                ),
                TextButton(
                  onPressed: locating
                      ? null
                      : () async {
                          update(() => locating = true);
                          try {
                            final service = LocationService();
                            final permission = await service
                                .checkAndRequestPermission();
                            final location =
                                permission == LocationPermissionStatus.granted
                                ? await service.getCurrentLocation().timeout(
                                    const Duration(seconds: 15),
                                  )
                                : null;
                            if (!dialogContext.mounted) return;
                            update(() {
                              if (location != null) {
                                point = LatLng(
                                  location.latitude,
                                  location.longitude,
                                );
                                error = null;
                              } else {
                                error = 'Location unavailable. Pick on Map.';
                              }
                            });
                          } catch (_) {
                            if (dialogContext.mounted) {
                              update(
                                () => error =
                                    'Location unavailable. Pick on Map.',
                              );
                            }
                          } finally {
                            if (dialogContext.mounted) {
                              update(() => locating = false);
                            }
                          }
                        },
                  child: Text(
                    locating ? 'Getting location…' : 'Use Current Location',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final p = await _mapPoint(initial: point);
                    if (p != null && dialogContext.mounted) {
                      update(() => point = p);
                    }
                  },
                  child: const Text('Pick on Map'),
                ),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final p = int.tryParse(population.text);
                if (name.text.trim().isEmpty ||
                    point == null ||
                    p == null ||
                    p < 1) {
                  update(
                    () =>
                        error = 'Complete the name, location and valid counts.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save habitation'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && mounted) {
      final v = {
        'id': old?['id'],
        'name': name.text.trim(),
        'latitude': point!.latitude,
        'longitude': point!.longitude,
        'population': int.parse(population.text),
        'assistance': old?['assistance'] ?? 0,
      };
      final all = [..._villages];
      if (old == null) {
        all.add(v);
      } else {
        all[all.indexWhere((x) => x['id'] == old['id'])] = v;
      }
      await _refresh(body: all);
    }
    // Dialog closing animation can still reference controllers; dispose after it.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    population.dispose();
    _editing = false;
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final zones = r['zones'] as List? ?? [];
    final ready =
        _error == null &&
        !_busy &&
        _villages.isNotEmpty &&
        zones.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Evacuation Priority')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Ranked by red-zone proximity (within 20 km) plus flood history from ISRO Bhuvan (1998\u20132010 annual maps). Population supports resource planning.',
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            const Text(
              '1. Habitations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            for (final v in _villages)
              Card(
                child: ListTile(
                  title: Text(v['name']),
                  subtitle: Text(
                    '${v['population']} people',
                  ),
                  onTap: _busy
                      ? null
                      : () => _edit(Map<String, dynamic>.from(v)),
                  trailing: IconButton(
                    tooltip: 'Remove Habitation',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _busy
                        ? null
                        : () => _refresh(
                            body: _villages
                                .where((x) => x['id'] != v['id'])
                                .toList(),
                          ),
                  ),
                ),
              ),
            FilledButton(
              onPressed: _busy ? null : () => _edit(),
              child: const Text('Add Habitation'),
            ),
            const SizedBox(height: 20),
            const Text(
              'EVACUATION PRIORITY',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              zones.isEmpty
                  ? 'No mapped active RED zone. Priority unavailable.'
                  : 'Active Risk: ${zones.length} RED zone(s)',
            ),
            const Text(
              'Refreshes every 30 seconds. Red boundaries match AASHA’s risk map; missing radius uses its existing estimate.',
              style: TextStyle(fontSize: 12),
            ),
            if ((r['unmappedAlerts'] ?? 0) > 0)
              const Text(
                'Some active alerts have no boundary. Ranking covers mapped alerts only. Officers must check unmapped alerts before acting.',
              ),
            if (_error == null)
              for (final p in r['priorities'] ?? [])
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['rank'] == 0
                              ? 'AWAITING RED ZONE'
                              : 'PRIORITY ${p['rank']}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          p['habitation']['name'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        if (p['priorityScore'] != null)
                          Text(
                            'Priority score: ${(p['priorityScore'] as num).toStringAsFixed(1)} / 100',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (p['floodCount'] != null)
                          Text(
                            (p['floodYears'] as List?)?.isEmpty ?? true
                                ? 'Flood history (1998\u20132010): no flood recorded here'
                                : 'Flood history (1998\u20132010): ${p['floodCount']} of 13 years \u2014 ${(p['floodYears'] as List).join(', ')}',
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        if (p['distanceKm'] == null)
                          Text(
                            p['zone'] != null
                                ? 'Distance unavailable'
                                : 'No active red zone',
                          )
                        else
                          Text(
                            p['distanceKm'] == 0
                                ? 'Inside Red Zone'
                                : '${(p['distanceKm'] as num).toStringAsFixed(2)} km from Red Zone',
                          ),
                        if (p['zone'] != null)
                          Text(
                            '${p['zone']['name']}${p['zone']['estimated'] == true ? ' · estimated boundary' : ''}',
                          ),
                        Text(
                          '${p['habitation']['population']} people',
                        ),
                        TextButton(
                          onPressed: () => _mapPoint(
                            initial: LatLng(
                              (p['habitation']['latitude'] as num).toDouble(),
                              (p['habitation']['longitude'] as num).toDouble(),
                            ),
                            select: false,
                          ),
                          child: const Text('View on Map'),
                        ),
                      ],
                    ),
                  ),
                ),
            FilledButton(
              onPressed: ready
                  ? () => _refresh(path: '/generate', body: {})
                  : null,
              child: const Text('Generate Evacuation Plan'),
            ),
            const SizedBox(height: 20),
            const Text(
              '2. Registered camps',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'Automatically uses registered capacity minus occupancy. Camps inside red zones are excluded.',
            ),
            for (final c in r['camps'] ?? [])
              ListTile(
                title: Text(c['name']),
                subtitle: Text('${c['available']} places · ${c['reason']}'),
              ),
            if (_state?['generated'] == true && _error == null) ...[
              const Text(
                'Proposed evacuation plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              for (final p in r['placements'] ?? [])
                Text(
                  '${p['habitation']} → ${p['camp']} · ${p['people']} people',
                ),
              Text('${r['remaining']} people still need placement.'),
              const Text(
                'Officers coordinate family groups, transport and assistance. Review does not issue orders or reserve beds.',
              ),
              if (_state?['reviewed'] == true)
                const Text('Officer review recorded')
              else
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Confirm officer review?'),
                              content: const Text(
                                'Confirm you have reviewed this plan and will coordinate through the responsible authority.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          if (yes == true) {
                            await _refresh(path: '/review', body: {});
                          }
                        },
                  child: const Text('Confirm officer review'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
