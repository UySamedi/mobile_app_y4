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
  XFile? _pickedImage;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomes();
      }
      Get.back();
    } else if (res.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unauthorized. Please login again.'), backgroundColor: Colors.red));
      auth.logout();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
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
      if (_pickedImage != null) {
        final req = http.MultipartRequest('POST', uri);
        req.headers['Authorization'] = 'Bearer $token';
        req.fields.addAll(body);

        String? mimeType = _pickedImage!.mimeType;
        final String fileName = _pickedImage!.name.toLowerCase();
        if (mimeType == null) {
          if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
            mimeType = 'image/jpeg';
          } else if (fileName.endsWith('.png')) {
            mimeType = 'image/png';
          }
        }

        req.files.add(await http.MultipartFile.fromPath(
          'images', // Reverted to lowercase 'images'
          _pickedImage!.path,
          filename: _pickedImage!.name,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));

        final streamedRes = await req.send().timeout(const Duration(seconds: 20));
        res = await http.Response.fromStream(streamedRes);
      } else {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };
        final fullBody = {...body, 'images': []}; // Reverted to lowercase 'images'
        res = await http.post(uri, headers: headers, body: jsonEncode(fullBody)).timeout(const Duration(seconds: 12));
      }
      _handleApiResponse(res);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
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
      final XFile? photo = await picker.pickImage(source: source, maxWidth: 1200);
      if (photo != null) {
        setState(() => _pickedImage = photo);
      }
    } on PlatformException catch (e) {
      final message = e.message ?? 'Permission denied';
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not access ${source.name}: $message')));
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Home'), backgroundColor: Colors.blueAccent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name', filled: true, fillColor: Colors.white),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address', filled: true, fillColor: Colors.white),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter an address' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description', filled: true, fillColor: Colors.white),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                 if (_pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Selected: ${_pickedImage!.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ),
                const SizedBox(height: 12),
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pickedImage!.path),
                      key: ValueKey(_pickedImage!.path),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Could not load image', style: TextStyle(color: Colors.red))),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, disabledBackgroundColor: Colors.grey),
                    child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Home'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
