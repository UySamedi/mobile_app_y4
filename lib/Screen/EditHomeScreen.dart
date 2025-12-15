import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/home_service.dart';

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

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.home['name']);
    addressCtrl = TextEditingController(text: widget.home['address']);
    descriptionCtrl = TextEditingController(text: widget.home['description']);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': nameCtrl.text,
        'address': addressCtrl.text,
        'description': descriptionCtrl.text,
      };

      final token = auth.token.value;
      final result = await HomeService.updateHome(widget.home['id'], data, token);

      if (result['success']) {
        Get.back(result: true); // Go back and signal a refresh
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
              ),
              TextFormField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
