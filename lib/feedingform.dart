import 'package:flutter/material.dart';

class FeedForm extends StatefulWidget {
  @override
  _FeedFormState createState() => _FeedFormState();
}

class _FeedFormState extends State<FeedForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedTypeController = TextEditingController();
  final TextEditingController _feedingTimeController = TextEditingController();

  // Function to show saved feed type and feeding time in a message box
  void _showSavedFeed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Saved Feed Information'),
          content: Text(
            'Type of Feed: ${_feedTypeController.text}\nFeeding Time: ${_feedingTimeController.text}',
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
  void _saveFeed() {
    if (_formKey.currentState!.validate()) {
      _showSavedFeed();
    }
  }

  @override
  void dispose() {
    _feedTypeController.dispose();
    _feedingTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Type of Feed Dropdown Field with Text Controller
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Type of Feed',
                ),
                value: _feedTypeController.text.isEmpty
                    ? null
                    : _feedTypeController.text,
                items: [
                  'Egg Custard',
                  'Blood Worm',
                  'Artemia',
                  'Formulated Feed',
                ].map((feedType) => DropdownMenuItem(
                      value: feedType,
                      child: Text(feedType),
                    )).toList(),
                onChanged: (value) {
                  setState(() {
                    _feedTypeController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a type of feed';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Feeding Time Dropdown Field with Text Controller
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Feeding Time',
                ),
                value: _feedingTimeController.text.isEmpty
                    ? null
                    : _feedingTimeController.text,
                items: [
                  'Morning',
                  'Afternoon',
                  'Evening',
                  'Night',
                ].map((feedingTime) => DropdownMenuItem(
                      value: feedingTime,
                      child: Text(feedingTime),
                    )).toList(),
                onChanged: (value) {
                  setState(() {
                    _feedingTimeController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a feeding time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveFeed,
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
