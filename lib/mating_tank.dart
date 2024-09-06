import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class MatingForm extends StatefulWidget {
  @override
  _MatingFormState createState() => _MatingFormState();
}

class _MatingFormState extends State<MatingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  String _tankID = '';
  String _mp = '';
  String _mpNos = '';
  String _nfp = '';
  String _fpNos = '';

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
            'Mating Date: ${_dateController.text}\n'
            'Tank ID: $_tankID\n'
            'MP: $_mp\n'
            'MP Nos: $_mpNos\n'
            'NFP: $_nfp\n'
            'FP Nos: $_fpNos',
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
        title: Text('Mating Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Mating Date Field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Mating Date',
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
              // Tank ID Field
              TextFormField(
                decoration: InputDecoration(labelText: 'Tank ID'),
                onChanged: (value) {
                  _tankID = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Tank ID';
                  }
                  return null;
                },
              ),
              // MP Field
              TextFormField(
                decoration: InputDecoration(labelText: 'MP'),
                onChanged: (value) {
                  _mp = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter MP';
                  }
                  return null;
                },
              ),
              // MP Nos Field
              TextFormField(
                decoration: InputDecoration(labelText: 'MP Nos'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _mpNos = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter MP Nos';
                  }
                  return null;
                },
              ),
              // NFP Field
              TextFormField(
                decoration: InputDecoration(labelText: 'NFP'),
                onChanged: (value) {
                  _nfp = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NFP';
                  }
                  return null;
                },
              ),
              // FP Nos Field
              TextFormField(
                decoration: InputDecoration(labelText: 'FP Nos'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _fpNos = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter FP Nos';
                  }
                  return null;
                },
              ),
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