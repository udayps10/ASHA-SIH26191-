import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/critical_record.dart';
import '../../../data/models/camp.dart';
import '../../../data/repositories/camp_repository.dart';
import '../../../data/repositories/official_critical_record_repository.dart';
import '../../../core/app_state.dart';
import '../../../core/common_widgets/app_button.dart';
import '../../../core/common_widgets/app_text_field.dart';
import '../../../core/utils/location_service.dart';
import '../../images/data/image_selection_service.dart';
import '../../images/data/local_image_store.dart';
import '../../images/presentation/image_source_picker.dart';

class AddCriticalRecordScreen extends StatefulWidget {
  const AddCriticalRecordScreen({super.key});

  @override
  State<AddCriticalRecordScreen> createState() =>
      _AddCriticalRecordScreenState();
}

class _AddCriticalRecordScreenState extends State<AddCriticalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _campRepository = CampRepository();
  final _recordRepository = OfficialCriticalRecordRepository();
  final _locationService = LocationService();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _clothingController = TextEditingController();
  final _foundLocationController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _detailsController = TextEditingController();

  List<Camp> _activeCamps = [];
  Camp? _selectedCamp;
  DateTime _foundAt = DateTime.now();
  bool _isLoading = false;
  bool _isFetchingCamps = true;
  bool _isFetchingLocation = false;
  LocationResult? _tempLocation;
  double? _locationAccuracy;
  String? _photoLocalPath;
  String? _clothingPhotoLocalPath;
  final ImageSelectionService _imageSelection = LocalImageSelectionService();
  final _imageStore = const LocalImageStore();

  @override
  void initState() {
    super.initState();
    _fetchActiveCamps();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _clothingController.dispose();
    _foundLocationController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _fetchActiveCamps() async {
    try {
      final camps = await _campRepository.getActiveCamps();
      if (!mounted) return;
      debugPrint('[ADD CRITICAL][CAMP_LOOKUP] count=${camps.length}');
      setState(() {
        _activeCamps = camps;
        _isFetchingCamps = false;
      });
    } catch (e, stackTrace) {
      debugPrint('[ADD CRITICAL][CAMP_LOOKUP] failed: $e');
      debugPrint('$stackTrace');
      if (mounted) {
        setState(() => _isFetchingCamps = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading camps: $e')));
      }
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final status = await _locationService.checkAndRequestPermission();
      if (!mounted) return;

      if (status == LocationPermissionStatus.granted) {
        final result = await _locationService.getCurrentLocation();
        if (result != null) {
          setState(() => _tempLocation = result);
        } else {
          _showSnackBar('Failed to get location. Please try again.');
        }
      } else {
        _showSnackBar('Location permission is required.');
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
        _foundLocationController.text = _tempLocation!.address!;
      }
      _tempLocation = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCamp == null) {
      _showSnackBar('Please select a camp.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appState = context.read<AppState>();
      final sync = appState.syncService;
      debugPrint(
        '[ADD CRITICAL] isOnline=${sync.online} currentUserUid=${appState.firebaseUser?.uid} selectedCampId=${_selectedCamp?.id} campActive=${_selectedCamp?.active}',
      );
      final profile = appState.userProfile!;

      final record = CriticalRecord(
        id: '',
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        lastKnownClothing: _clothingController.text.trim(),
        campId: _selectedCamp!.id,
        campName: _selectedCamp!.name,
        officerUid: appState.firebaseUser!.uid,
        officerName: profile.name,
        officerContact: profile.email,
        foundLocation: _foundLocationController.text.trim(),
        foundLatitude: double.tryParse(_latController.text),
        foundLongitude: double.tryParse(_lonController.text),
        locationAccuracy: _locationAccuracy,
        additionalDetails: _detailsController.text.trim(),
        status: CriticalRecordStatus.CRITICAL,
        foundAt: _foundAt,
        photoLocalPath: _photoLocalPath,
        clothingPhotoLocalPath: _clothingPhotoLocalPath,
      );

      await _recordRepository.createRecord(record);
      debugPrint(
        '[ADD CRITICAL] localSaveSucceeded=true queueInsertSucceeded=true finalResult=success',
      );

      if (mounted) {
        _showSnackBar(
          'Critical record saved locally. It will sync when connection returns.',
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('[ADD CRITICAL][SAVE] failed: $e');
      debugPrint('$stackTrace');
      if (mounted) {
        _showSnackBar('Error saving record: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto({
    required bool clothing,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final image = await _imageSelection.pickImage(source: source);
      if (image == null) return;
      final validation = await _imageSelection.validateImage(image);
      if (!validation.isValid) {
        _showSnackBar(validation.message ?? 'Invalid image');
        return;
      }
      final path = await _imageStore.save(
        image,
        prefix: clothing ? 'critical_clothing' : 'critical',
      );
      if (!mounted) return;
      setState(() {
        if (clothing) {
          _clothingPhotoLocalPath = path;
        } else {
          _photoLocalPath = path;
        }
      });
    } catch (error, stackTrace) {
      debugPrint('[ADD CRITICAL][IMAGE_PICK] failed: $error');
      debugPrint('$stackTrace');
      if (mounted) _showSnackBar('Unable to select or save the photo.');
    }
  }

  Future<void> _choosePhotoSource({required bool clothing}) async {
    final source = await chooseImageSource(context);
    if (source != null) await _pickPhoto(clothing: clothing, source: source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Critical Record'),
        backgroundColor: Colors.red[900],
      ),
      body: _isFetchingCamps
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrivacyWarning(),
                    _buildPhotoPlaceholders(),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Full Name',
                      hint: 'Enter full name',
                      controller: _nameController,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Age',
                      hint: 'Enter age',
                      keyboardType: TextInputType.number,
                      controller: _ageController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        final age = int.tryParse(val);
                        if (age == null || age < 0) return 'Invalid age';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Last Known Clothing',
                      hint: 'Describe clothing in detail',
                      controller: _clothingController,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCampDropdown(),
                    const SizedBox(height: 24),
                    _buildLocationFetcher(),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Found Location Description',
                      hint: 'Specific area or landmark',
                      controller: _foundLocationController,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCoordinatesFields(),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Additional Identifying Info',
                      hint: 'Tattoos, birthmarks, etc.',
                      controller: _detailsController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: 'Save Critical Record',
                      isLoading: _isLoading,
                      color: Colors.red[900],
                      onPressed: _saveRecord,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrivacyWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'CONFIDENTIAL: Photographs of critical or deceased persons are restricted and will never be shown to normal users.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholders() {
    return Row(
      children: [
        Expanded(
          child: _buildPhotoBox(
            'Person Photo',
            Icons.person,
            _photoLocalPath,
            () => _choosePhotoSource(clothing: false),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPhotoBox(
            'Clothing Photo',
            Icons.checkroom,
            _clothingPhotoLocalPath,
            () => _choosePhotoSource(clothing: true),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoBox(
    String label,
    IconData icon,
    String? localPath,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: localPath == null
                ? Icon(icon, size: 40, color: Colors.grey)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(localPath), fit: BoxFit.cover),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_a_photo, size: 16),
          label: Text(label),
        ),
      ],
    );
  }

  Widget _buildCampDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Camp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_activeCamps.isEmpty && !_isFetchingCamps)
          TextButton.icon(
            onPressed: _fetchActiveCamps,
            icon: const Icon(Icons.refresh),
            label: const Text('No camps loaded. Tap to retry'),
          ),
        DropdownButtonFormField<Camp>(
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          items: _activeCamps
              .map(
                (camp) => DropdownMenuItem(value: camp, child: Text(camp.name)),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedCamp = val),
          hint: const Text('Select active camp'),
          isDense: true,
          validator: (val) => val == null ? 'Camp is required' : null,
        ),
      ],
    );
  }

  Widget _buildLocationFetcher() {
    if (_tempLocation == null) {
      return AppButton(
        text: 'Fetch Current Location',
        isLoading: _isFetchingLocation,
        color: Colors.blueGrey,
        onPressed: _fetchLocation,
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Text(
            'Location detected: ${_tempLocation!.address ?? "Coordinates only"}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _tempLocation = null),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _useDetectedLocation,
                  child: const Text('Use'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesFields() {
    return Row(
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
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date/Time Found',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _foundAt,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null && mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_foundAt),
              );
              if (time != null) {
                setState(() {
                  _foundAt = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 12),
                Text(
                  '${_foundAt.day}/${_foundAt.month}/${_foundAt.year} ${_foundAt.hour}:${_foundAt.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
