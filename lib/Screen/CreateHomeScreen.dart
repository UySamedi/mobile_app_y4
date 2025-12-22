import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';

import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

class Createhomescreen extends StatefulWidget {
  const Createhomescreen({super.key});

  @override
  State<Createhomescreen> createState() => _CreatehomescreenState();
}

class _CreatehomescreenState extends State<Createhomescreen> {
  final AuthController auth = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  List<XFile> _pickedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  void _handleApiResponse(http.Response res) {
    if (!mounted) return;
    final data = jsonDecode(res.body);
    final message = data['message'] ?? 'An unexpected error occurred.';

    if (res.statusCode >= 200 && res.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green));
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomes();
      }
      Get.back();
    } else if (res.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unauthorized. Please login again.'),
          backgroundColor: Colors.red));
      auth.logout();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final baseUrl = auth.baseUrl;
      final token = auth.token.value;
      final uri = Uri.parse('$baseUrl/homes');

      final body = {
        'name': nameCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
      };

      http.Response res;
      if (_pickedImages.isNotEmpty) {
        final req = http.MultipartRequest('POST', uri);
        req.headers['Authorization'] = 'Bearer $token';
        req.fields.addAll(body);

        // Add all images to the request
        for (var image in _pickedImages) {
          String? mimeType = image.mimeType;
          final String fileName = image.name.toLowerCase();
          if (mimeType == null) {
            if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
              mimeType = 'image/jpeg';
            } else if (fileName.endsWith('.png')) {
              mimeType = 'image/png';
            }
          }

          req.files.add(await http.MultipartFile.fromPath(
            'images',
            image.path,
            filename: image.name,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }

        final streamedRes =
            await req.send().timeout(const Duration(seconds: 30));
        res = await http.Response.fromStream(streamedRes);
      } else {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };
        final fullBody = {...body, 'images': []};
        res = await http
            .post(uri, headers: headers, body: jsonEncode(fullBody))
            .timeout(const Duration(seconds: 12));
      }
      _handleApiResponse(res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        // Allow picking multiple images from gallery
        final List<XFile> photos = await picker.pickMultiImage(maxWidth: 1200);
        if (photos.isNotEmpty) {
          setState(() {
            // Limit to 3 images total
            final remainingSlots = 3 - _pickedImages.length;
            if (remainingSlots > 0) {
              _pickedImages.addAll(photos.take(remainingSlots));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maximum 3 images allowed')));
            }
          });
        }
      } else {
        // Camera - single image
        final XFile? photo =
            await picker.pickImage(source: source, maxWidth: 1200);
        if (photo != null) {
          setState(() {
            if (_pickedImages.length < 3) {
              _pickedImages.add(photo);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maximum 3 images allowed')));
            }
          });
        }
      }
    } on PlatformException catch (e) {
      final message = e.message ?? 'Permission denied';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not access ${source.name}: $message')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('List Your Property',
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

  Widget _buildImagePickerArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pickedImages.isEmpty)
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
                children: List.generate(
                  _pickedImages.length,
                  (index) => _buildImagePreview(_pickedImages[index], index),
                ),
              ),
              if (_pickedImages.length < 3) ...[
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

  Widget _buildImagePreview(XFile image, int index) {
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
                _pickedImages.removeAt(index);
              });
            },
            child: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              radius: 12,
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
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
              subtitle: Text(_pickedImages.length < 3
                  ? 'Take a photo'
                  : 'Maximum 3 images reached'),
              enabled: _pickedImages.length < 3,
              onTap: _pickedImages.length < 3
                  ? () {
                      Get.back();
                      _pickImage(ImageSource.camera);
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              subtitle: Text(_pickedImages.length < 3
                  ? 'Select multiple photos'
                  : 'Maximum 3 images reached'),
              enabled: _pickedImages.length < 3,
              onTap: _pickedImages.length < 3
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
          : const Text('Publish Property',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
