import 'package:flutter/material.dart';

class PondForm extends StatefulWidget {
  @override
  _PondFormState createState() => _PondFormState();
}

class _PondFormState extends State<PondForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pondController = TextEditingController();
  String? _selectedLocation; // Variable to hold the selected location

  @override
  void dispose() {
    _pondController.dispose();
    super.dispose();
  }

  // Function to show saved pond name and location in a message box
  void _showSavedPond() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Saved Pond'),
          content: Text(
            'Location: $_selectedLocation\nPond Name: ${_pondController.text}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle save button press
  void _savePond() {
    if (_formKey.currentState!.validate()) {
      _showSavedPond();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pond Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Location Dropdown Field
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Location Name',
                ),
                value: _selectedLocation,
                items: ['Pattambi', 'Edappal', 'Thrissur']
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Pond Name Field
              TextFormField(
                controller: _pondController,
                decoration: InputDecoration(
                  labelText: 'Pond Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a pond name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _savePond,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
