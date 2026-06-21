// File: shared_widgets/reusable_image_picker.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/Const/api_config.dart';

// Assuming you have a l10n package for lang.S.of(context)
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/constant.dart'; // kMainColor, kNeutral800 etc.

class ReusableImagePicker extends StatefulWidget {
  final File? initialImage;
  final String? existingImageUrl; // NEW: Image URL for editing
  final Function(File?) onImagePicked;
  final Function()? onImageRemoved; // NEW: Callback for explicit removal

  const ReusableImagePicker({
    super.key,
    this.initialImage,
    this.existingImageUrl, // Added to constructor
    required this.onImagePicked,
    this.onImageRemoved, // Added to constructor
  });

  @override
  State<ReusableImagePicker> createState() => _ReusableImagePickerState();
}

class _ReusableImagePickerState extends State<ReusableImagePicker> {
  File? _pickedImage;
  String? _existingImageUrl; // State for the image URL
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Prioritize new file if passed, otherwise use existing URL
    _pickedImage = widget.initialImage;
    _existingImageUrl = widget.existingImageUrl;
  }

  // Update state if parent widget sends new values (e.g., when switching between edit screens)
  @override
  void didUpdateWidget(covariant ReusableImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != oldWidget.initialImage || widget.existingImageUrl != oldWidget.existingImageUrl) {
      // Keep the new image if present, otherwise load the URL
      _pickedImage = widget.initialImage;
      _existingImageUrl = widget.existingImageUrl;
    }
  }

  Future<void> _pickImage(ImageSource source, BuildContext dialogContext) async {
    final XFile? xFile = await _picker.pickImage(source: source);

    // Close the dialog after selection attempt
    Navigator.of(dialogContext).pop();

    if (xFile != null) {
      final newFile = File(xFile.path);
      setState(() {
        _pickedImage = newFile;
        _existingImageUrl = null; // A new file means we discard the existing URL
      });
      widget.onImagePicked(newFile); // Notify parent screen
    }
  }

  // Custom Cupertino Dialog for image source selection (unchanged)
  void _showImageSourceDialog() {
    final textTheme = Theme.of(context).textTheme;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext contexts) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          title: Text(
            lang.S.of(context).uploadImage, // Assuming this string exists
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Column(
                children: [
                  const Icon(IconlyLight.image, size: 30.0),
                  Text(
                    lang.S.of(context).useGallery, // Assuming this string exists
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onPressed: () => _pickImage(ImageSource.gallery, contexts),
            ),
            CupertinoDialogAction(
              child: Column(
                children: [
                  const Icon(IconlyLight.camera, size: 30.0),
                  Text(
                    lang.S.of(context).openCamera, // Assuming this string exists
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onPressed: () => _pickImage(ImageSource.camera, contexts),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the source to display
    final bool hasImage = _pickedImage != null || (_existingImageUrl?.isNotEmpty ?? false);

    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        onTap: _showImageSourceDialog, // Always allow tapping to change/add image
        child: !hasImage
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(IconlyLight.image, size: 30),
                    const SizedBox(height: 5),
                    Text(lang.S.of(context).addImage, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    // Conditional Image Widget
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, fit: BoxFit.cover) // Display new file
                        : Image.network(
                            // Display existing image from URL
                            '${_existingImageUrl!}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.error_outline, color: Colors.red)), // Show error icon on failed load
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _pickedImage = null;
                          _existingImageUrl = null; // Crucial: clear URL as well
                        });
                        // Notify parent that the image (file or url) is removed
                        widget.onImagePicked(null);
                        if (widget.onImageRemoved != null) {
                          widget.onImageRemoved!();
                        }
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
