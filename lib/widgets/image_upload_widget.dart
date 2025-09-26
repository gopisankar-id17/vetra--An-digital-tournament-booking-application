import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../utils/app_theme.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(XFile?)? onImageSelected;
  final Function(String)? onImageUrlChanged;
  final String label;
  final String hint;
  final bool isRequired;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.onImageUrlChanged,
    this.label = 'Tournament Image',
    this.hint = 'Select an image or enter URL',
    this.isRequired = false,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _urlController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _webImage;
  bool _isUsingUrl = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null) {
      _urlController.text = widget.initialImageUrl!;
      _isUsingUrl = true;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _isUsingUrl = false;
          _urlController.clear();
        });

        // Load image bytes for web preview
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() => _webImage = bytes);
        }

        widget.onImageSelected?.call(image);
        widget.onImageUrlChanged?.call('');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _useImageUrl() {
    setState(() {
      _isUsingUrl = true;
      _selectedImage = null;
      _webImage = null;
    });
    widget.onImageSelected?.call(null);
    widget.onImageUrlChanged?.call(_urlController.text);
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _urlController.clear();
      _isUsingUrl = true;
    });
    widget.onImageSelected?.call(null);
    widget.onImageUrlChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 12),

        // Toggle between upload and URL
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  'Upload Image',
                  Icons.upload_file,
                  !_isUsingUrl,
                  () => setState(() => _isUsingUrl = false),
                ),
              ),
              Container(width: 1, height: 32, color: Colors.grey.shade300),
              Expanded(
                child: _buildToggleButton(
                  'Image URL',
                  Icons.link,
                  _isUsingUrl,
                  _useImageUrl,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Image preview area
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: _buildImagePreview(),
        ),

        const SizedBox(height: 12),

        // Upload/URL input area
        if (_isUsingUrl) _buildUrlInput() else _buildUploadButton(),

        if (_selectedImage != null || _urlController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: _clearImage,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Image'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Loading image...'),
          ],
        ),
      );
    }

    // Show uploaded image
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (kIsWeb && _webImage != null)
              Image.memory(
                _webImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            else if (!kIsWeb)
              Image.file(
                File(_selectedImage!.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Uploaded',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show URL image
    if (_isUsingUrl && _urlController.text.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _urlController.text,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const Text('Loading image...'),
                ],
              ),
            );
          },
        ),
      );
    }

    // Default placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No image selected',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.hint,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return TextFormField(
      controller: _urlController,
      decoration: InputDecoration(
        labelText: 'Image URL',
        hintText: 'https://example.com/image.jpg',
        prefixIcon: const Icon(Icons.link, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: widget.isRequired
          ? (value) {
              if (_selectedImage == null && (value?.isEmpty ?? true)) {
                return 'Please select an image or enter URL';
              }
              if (value != null &&
                  value.isNotEmpty &&
                  !Uri.tryParse(value)!.isAbsolute) {
                return 'Please enter a valid URL';
              }
              return null;
            }
          : null,
      onChanged: (value) {
        widget.onImageUrlChanged?.call(value);
        setState(() {}); // Trigger rebuild to update preview
      },
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _pickImage,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(_isLoading ? 'Uploading...' : 'Select Image from Device'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
