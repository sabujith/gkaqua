import 'package:flutter/material.dart';

class UpdateprawnstatusModal extends StatefulWidget {
  const UpdateprawnstatusModal({super.key});

  @override
  State<UpdateprawnstatusModal> createState() => _UpdateprawnstatusModalState();
}

class _UpdateprawnstatusModalState extends State<UpdateprawnstatusModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to hold selected dropdown values
  String? _selectedMaleStatus;
  String? _selectedFemaleStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 400, // Optional height adjustment
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Center(
                child: Text(
                  'Update Prawn Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Male Prawn Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Male Prawn Status',
                  border: OutlineInputBorder(),
                ),
                items: ['Combined', 'Discard', 'Resting']
                    .map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                value: _selectedMaleStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedMaleStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the male prawn status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Female Prawn Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Female Prawn Status',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['Combined', 'Discard', 'Resting', 'Move to hatching tank']
                        .map((status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                value: _selectedFemaleStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedFemaleStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the female prawn status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue.withOpacity(0.8), // Add transparency
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with the update
                    Navigator.of(context).pop(); // Close modal after processing
                  }
                },
                child: const Text(
                  'Update',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
