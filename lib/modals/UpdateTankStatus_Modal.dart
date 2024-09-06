import 'package:flutter/material.dart';

class UpdateTankStatusModal extends StatefulWidget {
  const UpdateTankStatusModal({Key? key}) : super(key: key);

  @override
  _UpdateTankStatusModalState createState() => _UpdateTankStatusModalState();
}

class _UpdateTankStatusModalState extends State<UpdateTankStatusModal> {
  final _formKey = GlobalKey<FormState>(); // Key to access form
  String? _selectedStatus; // Variable to store selected status

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 300,
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Update Tank Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Status'),
                items: ['Empty', 'Mating', 'Resting']
                    .map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value; // Store selected value
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status'; // Error message if no value is selected
                  }
                  return null; // No error if valid
                },
              ),
              const SizedBox(height: 16),
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
                  // Validate form
                  if (_formKey.currentState!.validate()) {
                    // If valid, close the modal
                    Navigator.of(context).pop();
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
