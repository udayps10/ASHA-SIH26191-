import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/camp.dart';
import '../../../data/repositories/camp_repository.dart';
import '../../../core/app_state.dart';
import '../../../core/common_widgets/app_button.dart';
import '../../../core/common_widgets/app_text_field.dart';
import '../../../core/utils/location_service.dart';

class AddCampScreen extends StatefulWidget {
  final Camp? camp;

  const AddCampScreen({super.key, this.camp});

  @override
  State<AddCampScreen> createState() => _AddCampScreenState();
}

class _AddCampScreenState extends State<AddCampScreen> {
  final _formKey = GlobalKey<FormState>();
  final _campRepository = CampRepository();
  final _locationService = LocationService();

  bool _isLoading = false;
  bool _isFetchingLocation = false;
  LocationResult? _tempLocation;

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _contactController;
  late TextEditingController _officerController;
  bool _active = true;
  double? _locationAccuracy;

  @override
  void initState() {
    super.initState();
    final camp = widget.camp;
    _nameController = TextEditingController(text: camp?.name);
    _locationController = TextEditingController(text: camp?.locationName);
    _addressController = TextEditingController(text: camp?.address);
    _latController = TextEditingController(text: camp?.latitude?.toString());
    _lonController = TextEditingController(text: camp?.longitude?.toString());
    _contactController = TextEditingController(text: camp?.contactNumber);
    _officerController = TextEditingController(text: camp?.officerName);
    _active = camp?.active ?? true;
    _locationAccuracy = camp?.locationAccuracy;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _contactController.dispose();
    _officerController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      final status = await _locationService.checkAndRequestPermission();

      if (!mounted) return;

      switch (status) {
        case LocationPermissionStatus.granted:
          final result = await _locationService.getCurrentLocation();
          if (result != null) {
            setState(() => _tempLocation = result);
          } else {
            _showSnackBar('Failed to get location. Please try again.');
          }
          break;
        case LocationPermissionStatus.denied:
          _showSnackBar(
            'Location permission is required to automatically detect the camp location.',
          );
          break;
        case LocationPermissionStatus.deniedForever:
          _showPermissionDeniedForeverDialog();
          break;
        case LocationPermissionStatus.serviceDisabled:
          _showLocationServiceDisabledDialog();
          break;
        case LocationPermissionStatus.error:
          _showSnackBar('An error occurred while requesting location.');
          break;
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _useDetectedLocation() {
    if (_tempLocation == null) return;

    setState(() {
      _latController.text = _tempLocation!.latitude.toString();
      _lonController.text = _tempLocation!.longitude.toString();
      _locationAccuracy = _tempLocation!.accuracy;

      if (_tempLocation!.address != null) {
        _addressController.text = _tempLocation!.address!;
      }

      if (_tempLocation!.locationName != null) {
        _locationController.text = _tempLocation!.locationName!;
      }

      _tempLocation = null; // Clear confirmation UI
    });

    _showSnackBar('Location information updated.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permissions are permanently denied. Please enable them in app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _locationService.openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable GPS/Location services on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _locationService.openLocationSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCamp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final appState = context.read<AppState>();
      final officerUid = appState.firebaseUser!.uid;

      final campData = Camp(
        id: widget.camp?.id ?? '',
        name: _nameController.text.trim(),
        locationName: _locationController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lonController.text),
        contactNumber: _contactController.text.trim(),
        officerName: _officerController.text.trim(),
        officerUid: widget.camp?.officerUid ?? officerUid,
        active: _active,
        locationAccuracy: _locationAccuracy,
        createdAt: widget.camp?.createdAt,
      );

      if (widget.camp == null) {
        await _campRepository.createCamp(campData);
      } else {
        await _campRepository.updateCamp(campData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.camp == null
                  ? 'Camp created successfully.'
                  : 'Camp updated successfully.',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving camp: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.camp != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Camp' : 'Add New Camp')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationFetcher(),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Camp Name',
                hint: 'e.g., Central Relief Camp',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location Name',
                hint: 'e.g., North District Sports Ground',
                controller: _locationController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Full Address',
                hint: 'Enter detailed address',
                controller: _addressController,
                maxLines: 2,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Latitude',
                      hint: '0.00',
                      controller: _latController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: 'Longitude',
                      hint: '0.00',
                      controller: _lonController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (_locationAccuracy != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Accuracy: ~${_locationAccuracy!.toStringAsFixed(1)} m',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Contact Number',
                hint: 'Emergency contact for the camp',
                controller: _contactController,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Officer-in-Charge',
                hint: 'Name of the primary officer',
                controller: _officerController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Active Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: _active,
                    onChanged: (val) => setState(() => _active = val),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              AppButton(
                text: isEditing ? 'Update Camp' : 'Save Camp',
                isLoading: _isLoading,
                onPressed: _saveCamp,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(
                  child: Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFetcher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on, size: 20, color: Colors.blueGrey),
            SizedBox(width: 8),
            Text(
              'Camp Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_tempLocation == null)
          AppButton(
            text: 'Fetch Current Location',
            isLoading: _isFetchingLocation,
            color: Colors.blueGrey,
            onPressed: _fetchLocation,
          )
        else
          _buildLocationConfirmation(),
      ],
    );
  }

  Widget _buildLocationConfirmation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Location Found',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Address: ${_tempLocation!.address ?? "N/A"}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Coordinates: ${_tempLocation!.latitude.toStringAsFixed(4)}, ${_tempLocation!.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            'Accuracy: ~${_tempLocation!.accuracy.toStringAsFixed(1)} m',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _tempLocation = null),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _useDetectedLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use This Location'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
