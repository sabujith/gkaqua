import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatingTankForm extends StatefulWidget {
  @override
  _MatingTankFormState createState() => _MatingTankFormState();
}

class _MatingTankFormState extends State<MatingTankForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  String _tankName = '';
  String _tankSize = '';
  String _tankStatus = 'Empty'; // Default value for dropdown

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Function to display input values in an AlertDialog
  void _showValues() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Entered Data'),
          content: Text(
            'Date Brought In: ${_dateController.text}\n'
            'Tank Name: $_tankName\n'
            'Tank Size: $_tankSize\n'
            'Tank Status: $_tankStatus',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mating Tank Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Date Brought In Field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date Brought In',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              // Tank Name Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tank Name',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _tankName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Tank Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              // Tank Size Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tank Size',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _tankSize = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Tank Size';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              // Tank Status Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tank Status',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: _tankStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    _tankStatus = newValue!;
                  });
                },
                items: <String>['Empty', 'Mating', 'Resting']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Tank Status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showValues(); // Show the entered values in a dialog
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

