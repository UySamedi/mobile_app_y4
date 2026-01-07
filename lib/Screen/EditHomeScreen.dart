import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import '../controllers/auth_controller.dart';
import '../services/home_service.dart';
import '../services/auth_service.dart';

class EditHomeScreen extends StatefulWidget {
  final Map<String, dynamic> home;

  const EditHomeScreen({super.key, required this.home});

  @override
  State<EditHomeScreen> createState() => _EditHomeScreenState();
}

class _EditHomeScreenState extends State<EditHomeScreen> {
  final AuthController auth = Get.find();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController descriptionCtrl;
  bool _isSubmitting = false;

  List<String> _existingImages = [];
  final List<XFile> _newImages = [];
  final List<String> _imagesToDelete = [];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.home['name'] ?? '');
    addressCtrl = TextEditingController(text: widget.home['address'] ?? '');
    descriptionCtrl =
        TextEditingController(text: widget.home['description'] ?? '');

    // Load existing images
    if (widget.home['images'] != null && widget.home['images'] is List) {
      _existingImages = List<String>.from(widget.home['images']);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final token = auth.token.value;
      if (token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please login again'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      final homeId = widget.home['id'];
      if (homeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid home data'), backgroundColor: Colors.red),
        );
        return;
      }

      // If there are new images, use multipart form data
      if (_newImages.isNotEmpty || _imagesToDelete.isNotEmpty) {
        final dioInstance = dio.Dio();
        final formData = dio.FormData.fromMap({
          'name': nameCtrl.text.trim(),
          'address': addressCtrl.text.trim(),
          'description': descriptionCtrl.text.trim(),
        });

        // Add new images
        for (var image in _newImages) {
          String? mimeType = image.mimeType;
          final String fileName = image.name.toLowerCase();
          if (mimeType == null) {
            if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
              mimeType = 'image/jpeg';
            } else if (fileName.endsWith('.png')) {
              mimeType = 'image/png';
            }
          }

          formData.files.add(MapEntry(
            'images',
            await dio.MultipartFile.fromFile(
              image.path,
              filename: image.name,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          ));
        }

        try {
          final response = await dioInstance.put(
            '${AuthService.baseUrl}/homes/$homeId',
            data: formData,
            options: dio.Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );

          if (mounted) {
            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Property updated successfully'),
                    backgroundColor: Colors.green),
              );
              Get.back(result: true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(response.data['message'] ??
                        'Failed to update property'),
                    backgroundColor: Colors.red),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red),
            );
          }
        }
      } else {
        // No image changes, use regular JSON update
        final data = {
          'name': nameCtrl.text.trim(),
          'address': addressCtrl.text.trim(),
          'description': descriptionCtrl.text.trim(),
        };

        final result = await HomeService.updateHome(homeId, data, token);

        if (mounted) {
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Property updated successfully'),
                  backgroundColor: Colors.green),
            );
            Get.back(result: true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(result['message'] ?? 'Failed to update property'),
                  backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Property',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: nameCtrl,
                  label: 'Property Name',
                  hint: 'e.g. Cozy Beach Villa',
                  icon: Icons.home_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: addressCtrl,
                  label: 'Address',
                  hint: 'Full address of your property',
                  icon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter an address'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionCtrl,
                  label: 'Description',
                  hint: 'Tell guests what makes your place special...',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Property Photos'),
                const SizedBox(height: 16),
                _buildImagePickerArea(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> photos = await picker.pickMultiImage(maxWidth: 1200);
        if (photos.isNotEmpty) {
          setState(() {
            final totalImages = _existingImages.length + _newImages.length;
            final remainingSlots = 3 - totalImages;
            if (remainingSlots > 0) {
              _newImages.addAll(photos.take(remainingSlots));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maximum 3 images allowed')),
              );
            }
          });
        }
      } else {
        final XFile? photo =
            await picker.pickImage(source: source, maxWidth: 1200);
        if (photo != null) {
          setState(() {
            final totalImages = _existingImages.length + _newImages.length;
            if (totalImages < 3) {
              _newImages.add(photo);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maximum 3 images allowed')),
              );
            }
          });
        }
      }
    } on PlatformException catch (e) {
      final message = e.message ?? 'Permission denied';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access ${source.name}: $message')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    final totalImages = _existingImages.length + _newImages.length;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Select Image Source',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              enabled: totalImages < 3,
              onTap: totalImages < 3
                  ? () {
                      Get.back();
                      _pickImage(ImageSource.camera);
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              subtitle: Text(totalImages < 3
                  ? 'Select multiple photos'
                  : 'Maximum 3 images reached'),
              enabled: totalImages < 3,
              onTap: totalImages < 3
                  ? () {
                      Get.back();
                      _pickImage(ImageSource.gallery);
                    }
                  : null,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerArea() {
    final allImages = <Widget>[];

    // Show existing images
    for (int i = 0; i < _existingImages.length; i++) {
      String imageUrl = _existingImages[i];
      if (imageUrl.contains('localhost')) {
        imageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
      }
      allImages.add(_buildExistingImagePreview(imageUrl, i));
    }

    // Show new images
    for (int i = 0; i < _newImages.length; i++) {
      allImages.add(_buildNewImagePreview(_newImages[i], i));
    }

    final totalImages = _existingImages.length + _newImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allImages.isEmpty)
          GestureDetector(
            onTap: () => _showImageSourceSheet(),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.blueAccent, size: 48),
                  const SizedBox(height: 12),
                  const Text('Add property photos',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold)),
                  Text('Up to 3 images • JPG or PNG',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: allImages,
              ),
              if (totalImages < 3) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showImageSourceSheet(),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                          style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.blueAccent, size: 32),
                        SizedBox(height: 4),
                        Text('Add',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildExistingImagePreview(String imageUrl, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _imagesToDelete.add(_existingImages[index]);
                _existingImages.removeAt(index);
              });
            },
            child: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              radius: 12,
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Current',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImagePreview(XFile image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(image.path),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _newImages.removeAt(index);
              });
            },
            child: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              radius: 12,
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'New',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Text('Update Property',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
