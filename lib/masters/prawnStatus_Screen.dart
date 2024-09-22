import 'package:flutter/material.dart';

class PrawnstatusScreen extends StatefulWidget {
  const PrawnstatusScreen({super.key});

  @override
  State<PrawnstatusScreen> createState() => _PrawnstatusScreenState();
}

class _PrawnstatusScreenState extends State<PrawnstatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // List to store prawn statuses and notes
  List<Map<String, String>> _prawnStatuses = [
    {"status": "New", "note": "Newly arrived Prawns"},
    {"status": "Resting", "note": "Not Mating"},
    {"status": "Mating", "note": "On Mating"},
    {"status": "Combined", "note": "With Repeatation Mating"},
    {"status": "Discard", "note": "Of no use"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            )),
        title: const Text(
          'Update Prawn Status',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form for adding a new prawn status
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input for prawn status
                  TextFormField(
                    controller: _statusController,
                    decoration: const InputDecoration(
                      labelText: 'Prawn Status',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a prawn status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input for optional note
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: _submitForm,
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            //list of prawn statuses
            ListTile(
              title: Text(
                "Status",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "Actions",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _prawnStatuses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_prawnStatuses[index]['status']!),
                    subtitle: Text('( ${_prawnStatuses[index]['note']!} )'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editPrawnStatus(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(
                                index); // Call the confirmation dialog
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Submit form and add the new prawn status
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _prawnStatuses.add({
          "status": _statusController.text,
          "note": _noteController.text,
        });

        // Clear the form fields
        _statusController.clear();
        _noteController.clear();
      });

      // Show snackbar on successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            backgroundColor: Colors.green,
            content: Text('Successfully submitted')),
      );
    }
  }

  // Edit prawn status
  void _editPrawnStatus(int index) {
    _statusController.text = _prawnStatuses[index]['status']!;
    _noteController.text = _prawnStatuses[index]['note']!;
    setState(() {
      _prawnStatuses
          .removeAt(index); // Remove the item temporarily to allow editing
    });
  }

  // Show confirmation dialog before deletion
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this status?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deletePrawnStatus(index); // Call the delete function
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
            ),
          ],
        );
      },
    );
  }

  // Delete prawn status from the list
  void _deletePrawnStatus(int index) {
    setState(() {
      _prawnStatuses.removeAt(index);
    });

    // Show snackbar for deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          backgroundColor: Colors.red,
          content: Text('Status deleted')),
    );
  }

  @override
  void dispose() {
    _statusController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
