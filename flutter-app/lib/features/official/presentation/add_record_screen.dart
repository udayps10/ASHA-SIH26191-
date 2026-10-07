import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/disaster_record.dart';
import '../../../data/models/normal_record.dart';
import '../../../data/models/camp.dart';
import '../../../data/repositories/camp_repository.dart';
import '../../../data/repositories/official_normal_record_repository.dart';
import '../../../core/app_state.dart';
import '../../../core/common_widgets/app_button.dart';
import '../../../core/common_widgets/app_text_field.dart';
import '../../images/data/image_selection_service.dart';
import '../../images/data/image_upload_api_service.dart';
import '../../images/data/local_image.dart';
import '../../images/data/local_image_store.dart';
import '../../images/presentation/image_source_picker.dart';

class AddRecordScreen extends StatefulWidget {
  final RecordType type;

  const AddRecordScreen({super.key, required this.type});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _campRepository = CampRepository();
  final _recordRepository = OfficialNormalRecordRepository();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _detailsController = TextEditingController();

  List<Camp> _activeCamps = [];
  Camp? _selectedCamp;
  DateTime _foundAt = DateTime.now();
  bool _isLoading = false;
  bool _isFetchingCamps = true;
  String? _photoLocalPath;
  String? _createdRecordId;
  final ImageSelectionService _imageSelection = LocalImageSelectionService();
  final _imageStore = const LocalImageStore();

  @override
  void initState() {
    super.initState();
    _fetchActiveCamps();
  }

  Future<void> _fetchActiveCamps() async {
    try {
      final camps = await _campRepository.getActiveCamps();
      if (!mounted) return;
      debugPrint('[ADD NORMAL][CAMP_LOOKUP] count=${camps.length}');
      setState(() {
        _activeCamps = camps;
        _isFetchingCamps = false;
      });
    } catch (e, stackTrace) {
      debugPrint('[ADD NORMAL][CAMP_LOOKUP] failed: $e');
      debugPrint('$stackTrace');
      if (mounted) {
        setState(() => _isFetchingCamps = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading camps: $e')));
      }
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCamp == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a camp.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appState = context.read<AppState>();
      final sync = appState.syncService;
      debugPrint(
        '[ADD NORMAL] isOnline=${sync.online} currentUserUid=${appState.firebaseUser?.uid} selectedCampId=${_selectedCamp?.id} campActive=${_selectedCamp?.active}',
      );
      final profile = appState.userProfile!;

      if (widget.type == RecordType.normal) {
        final record = NormalRecord(
          id: '',
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text),
          campId: _selectedCamp!.id,
          campName: _selectedCamp!.name,
          officerUid: appState.firebaseUser!.uid,
          officerName: profile.name,
          officerContact:
              profile.email, // Using email as placeholder for contact
          status: NormalRecordStatus.AT_CAMP,
          additionalDetails: _detailsController.text.trim(),
          foundAt: _foundAt,
          photoLocalPath: _photoLocalPath,
        );

        final recordId =
            _createdRecordId ?? await _recordRepository.createRecord(record);
        _createdRecordId = recordId;
        debugPrint(
          '[ADD NORMAL] recordCreated id=$recordId photoPath=$_photoLocalPath',
        );

        if (_photoLocalPath != null && recordId.isNotEmpty) {
          try {
            final imageService = HttpImageUploadApiService();
            final file = File(_photoLocalPath!);
            final exists = await file.exists();
            if (!exists) {
              throw Exception(
                'Selected photo is no longer available. Please select it again.',
              );
            } else {
              final bytes = await file.readAsBytes();
              final image = LocalImage(
                file: XFile(_photoLocalPath!),
                bytes: bytes,
              );
              final ref = await imageService.uploadNormalPhoto(
                recordId: recordId,
                image: image,
              );
              debugPrint(
                '[ADD NORMAL] photoUploaded storageId=${ref.storageId}',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo uploaded successfully!')),
                );
              }
            }
          } catch (e, st) {
            debugPrint('[ADD NORMAL] photoUploadFailed: $e');
            debugPrint('$st');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Record saved, but photo upload failed: $e. Tap Save to retry the photo.',
                  ),
                ),
              );
            }
            return;
          }
        } else {
          debugPrint(
            '[ADD NORMAL] SKIPPED photo upload: path=$_photoLocalPath recordId=$recordId',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No photo selected. path=$_photoLocalPath id=$recordId',
                ),
              ),
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record saved successfully.')),
          );
          Navigator.pop(context);
        }
      } else {
        // Critical records not implemented in this step
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Critical records implementation coming soon.'),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[ADD NORMAL][SAVE] failed: $e');
      debugPrint('$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving record: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto({ImageSource source = ImageSource.gallery}) async {
    try {
      final image = await _imageSelection.pickImage(source: source);
      if (image == null) return;
      final validation = await _imageSelection.validateImage(image);
      if (!validation.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validation.message ?? 'Invalid image')),
          );
        }
        return;
      }
      final path = await _imageStore.save(image, prefix: 'normal');
      if (mounted) setState(() => _photoLocalPath = path);
    } catch (error, stackTrace) {
      debugPrint('[ADD NORMAL][IMAGE_PICK] failed: $error');
      debugPrint('$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to select or save the photo.')),
        );
      }
    }
  }

  Future<void> _choosePhotoSource() async {
    final source = await chooseImageSource(context);
    if (source != null) await _pickPhoto(source: source);
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = widget.type == RecordType.critical;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCritical ? 'Add Critical Record' : 'Add Normal Person'),
        backgroundColor: isCritical ? Colors.red[900] : null,
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
                    if (isCritical) _buildCriticalWarning(),
                    _buildPhotoPlaceholder(isCritical),
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
                    _buildCampDropdown(),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Additional Details',
                      hint: 'Identifying marks, health info, etc.',
                      controller: _detailsController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: 'Save Record',
                      isLoading: _isLoading,
                      onPressed: _saveRecord,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCriticalWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Critical/deceased photographs are confidential and must never be displayed to normal users.',
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(bool isCritical) {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: _choosePhotoSource,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _photoLocalPath == null
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_photoLocalPath!),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _choosePhotoSource,
            icon: const Icon(Icons.add_a_photo),
            label: Text(
              isCritical ? 'Person Photo (Internal)' : 'Person Photo',
            ),
          ),
        ],
      ),
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
          initialValue: _selectedCamp,
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
