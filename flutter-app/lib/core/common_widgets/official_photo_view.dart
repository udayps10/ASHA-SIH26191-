import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../features/images/data/image_upload_api_service.dart';
import '../utils/photo_url_helper.dart';

class OfficialPhotoView extends StatefulWidget {
  final String? photoLocalPath;
  final String? photoUrl;
  final double size;
  final double borderRadius;
  final IconData placeholderIcon;
  final Color? placeholderColor;

  const OfficialPhotoView({
    super.key,
    this.photoLocalPath,
    this.photoUrl,
    this.size = 80,
    this.borderRadius = 8,
    this.placeholderIcon = Icons.person,
    this.placeholderColor,
  });

  @override
  State<OfficialPhotoView> createState() => _OfficialPhotoViewState();
}

class _OfficialPhotoViewState extends State<OfficialPhotoView> {
  final _imageService = HttpImageUploadApiService();
  Future<String?>? _urlFuture;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(OfficialPhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      _resolveUrl();
    }
  }

  void _resolveUrl() {
    final raw = widget.photoUrl;
    if (raw == null || raw.isEmpty) {
      _urlFuture = null;
      _resolvedUrl = null;
      return;
    }

    // Try parsing storageId
    String? storageId;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        storageId = (decoded['storageId'] ?? decoded['storage_id']) as String?;
      }
    } catch (_) {
      storageId = raw;
    }

    if (storageId != null && storageId.startsWith('cloudinary|')) {
      _urlFuture = _imageService.getImageUrl(storageId).then((url) {
        if (mounted) setState(() => _resolvedUrl = url);
        return url;
      });
    } else {
      _urlFuture = Future.value(PhotoUrlHelper.getDisplayUrl(raw));
      _urlFuture!.then((url) {
        if (mounted) setState(() => _resolvedUrl = url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Local Path (Highest priority)
    if (widget.photoLocalPath != null && widget.photoLocalPath!.isNotEmpty) {
      final file = File(widget.photoLocalPath!);
      if (file.existsSync()) {
        return _wrap(Image.file(file, width: widget.size, height: widget.size, fit: BoxFit.cover));
      }
    }

    // 2. Resolved URL (from backend or direct)
    if (_resolvedUrl != null) {
      return _wrap(
        Image.network(
          _resolvedUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }

    // 3. Loading or Placeholder
    return FutureBuilder<String?>(
      future: _urlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.placeholderColor ?? Colors.grey[200],
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _placeholder();
      },
    );
  }

  Widget _wrap(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: child,
    );
  }

  Widget _placeholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.placeholderColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Icon(widget.placeholderIcon, color: Colors.grey, size: widget.size * 0.5),
    );
  }
}
