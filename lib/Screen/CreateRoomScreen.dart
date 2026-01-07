import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;

import '../controllers/auth_controller.dart';
import '../services/home_service.dart';

class CreateRoomScreen extends StatefulWidget {
  final Map<String, dynamic> home;

  const CreateRoomScreen({super.key, required this.home});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final AuthController auth = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController roomNameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController capacityCtrl = TextEditingController();

  final List<XFile> _pickedImages = [];
  bool _isAvailable = true;
  int? _selectedRuleId;
  List<dynamic> _rules = [];
  bool _isLoadingRules = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchRules();
  }

  @override
  void dispose() {
    roomNameCtrl.dispose();
    priceCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRules() async {
    setState(() => _isLoadingRules = true);
    try {
      final token = auth.token.value;
      if (token.isEmpty) {
        if (mounted) {
          setState(() => _isLoadingRules = false);
        }
        return;
      }
      final result = await HomeService.getRules(token);

      if (mounted) {
        setState(() {
          _isLoadingRules = false;
          if (result['success']) {
            _rules = result['data'] ?? [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRules = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final token = auth.token.value;
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login again'), backgroundColor: Colors.red),
        );
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

      final formData = dio.FormData.fromMap({
        'homeId': homeId,
        'roomName': roomNameCtrl.text.trim(),
        'price': priceCtrl.text.trim(),
        'capacity': capacityCtrl.text.trim(),
        'isAvailable': _isAvailable.toString(),
        if (_selectedRuleId != null) 'ruleId': _selectedRuleId.toString(),
      });

      // Add images if any
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

        formData.files.add(MapEntry(
          'images',
          await dio.MultipartFile.fromFile(
            image.path,
            filename: image.name,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ),
        ));
      }

      final result = await HomeService.createRoom(formData, token);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Room created successfully'),
                backgroundColor: Colors.green),
          );
          Get.back(result: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result['message'] ?? 'Failed to create room'),
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
        final List<XFile> photos = await picker.pickMultiImage(maxWidth: 1200);
        if (photos.isNotEmpty) {
          setState(() {
            final remainingSlots = 3 - _pickedImages.length;
            if (remainingSlots > 0) {
              _pickedImages.addAll(photos.take(remainingSlots));
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
            if (_pickedImages.length < 3) {
              _pickedImages.add(photo);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Room',
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
                _buildSectionHeader('Room Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: roomNameCtrl,
                  label: 'Room Name',
                  hint: 'e.g. Master Bedroom',
                  icon: Icons.bed_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter room name'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: priceCtrl,
                  label: 'Price per Month',
                  hint: 'e.g. 150.0',
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: capacityCtrl,
                  label: 'Capacity',
                  hint: 'Number of guests (e.g. 2)',
                  icon: Icons.people_outline,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter capacity';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildAvailabilityToggle(),
                const SizedBox(height: 32),
                _buildSectionHeader('Room Rules (Optional)'),
                const SizedBox(height: 16),
                _buildRuleSelector(),
                const SizedBox(height: 32),
                _buildSectionHeader('Room Photos'),
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
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Available',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Switch(
            value: _isAvailable,
            onChanged: (value) => setState(() => _isAvailable = value),
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSelector() {
    if (_isLoadingRules) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedRuleId,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.rule_outlined, color: Colors.blueAccent),
              border: InputBorder.none,
              hintText: 'Select a rule (optional)',
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('No rule (optional)'),
              ),
              ..._rules.map((rule) => DropdownMenuItem<int>(
                    value: rule['id'],
                    child: Text(
                      rule['ruleTitle'] ?? 'Rule',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
            selectedItemBuilder: (context) {
              // Return a widget for each item in the dropdown
              final List<Widget> widgets = [
                const Text('No rule (optional)'),
              ];
              for (var rule in _rules) {
                widgets.add(
                  Text(
                    rule['ruleTitle'] ?? 'Rule',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }
              return widgets;
            },
            onChanged: (value) => setState(() => _selectedRuleId = value),
          ),
        ),
        if (_selectedRuleId != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      try {
                        final selectedRule = _rules.firstWhere(
                          (rule) => rule['id'] == _selectedRuleId,
                        );
                        return Text(
                          selectedRule['ruleTitle']?.toString() ?? 'Rule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      } catch (e) {
                        return Text(
                          'Rule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            fontSize: 14,
                          ),
                        );
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.blue[700],
                  onPressed: () => setState(() => _selectedRuleId = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
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
                  const Text('Add room photos',
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
          : const Text('Create Room',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
