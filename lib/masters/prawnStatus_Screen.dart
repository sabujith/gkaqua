import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrawnstatusScreen extends StatefulWidget {
  const PrawnstatusScreen({super.key});

  @override
  State<PrawnstatusScreen> createState() => _PrawnstatusScreenState();
}

class _PrawnstatusScreenState extends State<PrawnstatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _userId = '';
  bool _isAdmin = false;

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
  }

  //get user details
  Future<void> _getUserDetails() async {
    setState(() {
      _userId = "user123";
      _isAdmin = true;
      isLoading = false;
    });
  }

  // List to store prawn statuses and notes
  final List<Map<String, String>> _prawnStatuses = [
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
            onPressed: () {
              Navigator.of(context).pop();
            },
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1200) {
                  return largeScreenView(
                    formKey: _formKey,
                    statusController: _statusController,
                    noteController: _noteController,
                    startDateController: _startDateController,
                    endDateController: _endDateController,
                    prawnStatuses: _prawnStatuses,
                    userId: _userId,
                    isAdmin: _isAdmin,
                    submitForm: _submitForm,
                    editPrawnStatus: _editPrawnStatus,
                    confirmDelete: _confirmDelete,
                    selectStartDate: _selectStartDate,
                    selectEndDate: _selectEndDate,
                  );
                } else if (constraints.maxWidth > 800) {
                  return mediumScreenView(
                    formKey: _formKey,
                    statusController: _statusController,
                    noteController: _noteController,
                    startDateController: _startDateController,
                    endDateController: _endDateController,
                    prawnStatuses: _prawnStatuses,
                    userId: _userId,
                    isAdmin: _isAdmin,
                    submitForm: _submitForm,
                    editPrawnStatus: _editPrawnStatus,
                    confirmDelete: _confirmDelete,
                    selectStartDate: _selectStartDate,
                    selectEndDate: _selectEndDate,
                  );
                } else {
                  return smallScreenView(
                    formKey: _formKey,
                    statusController: _statusController,
                    noteController: _noteController,
                    startDateController: _startDateController,
                    endDateController: _endDateController,
                    prawnStatuses: _prawnStatuses,
                    userId: _userId,
                    isAdmin: _isAdmin,
                    submitForm: _submitForm,
                    editPrawnStatus: _editPrawnStatus,
                    confirmDelete: _confirmDelete,
                    selectStartDate: _selectStartDate,
                    selectEndDate: _selectEndDate,
                  );
                }
              },
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

// Function to select start date
  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat('dd-MM-yyyy')
            .format(picked); //"${picked.toLocal()}".split(' ')[0];
      });
    }
  }

// Function to select end date
  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

//small screen view
class smallScreenView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController statusController;
  final TextEditingController noteController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final List<Map<String, String>> prawnStatuses;
  final String userId;
  final bool isAdmin;
  final Function submitForm;
  final Function(int) editPrawnStatus;
  final Function(int) confirmDelete;
  final Function selectStartDate;
  final Function selectEndDate;

  const smallScreenView({
    super.key,
    required this.formKey,
    required this.statusController,
    required this.noteController,
    required this.startDateController,
    required this.endDateController,
    required this.prawnStatuses,
    required this.userId,
    required this.isAdmin,
    required this.submitForm,
    required this.editPrawnStatus,
    required this.confirmDelete,
    required this.selectStartDate,
    required this.selectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Form for adding a new prawn status
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input for prawn status
                TextFormField(
                  controller: statusController,
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
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                if (isAdmin)
                  TextFormField(
                    controller: startDateController,
                    readOnly: true,
                    onTap: () => selectStartDate(),
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      suffix: Icon(Icons.calendar_view_month),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a start date';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 16),
                if (isAdmin)
                  TextFormField(
                    controller: endDateController,
                    readOnly: true,
                    onTap: () => selectEndDate(),
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      suffix: Icon(Icons.calendar_view_month),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an end date';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 16),

                // Submit button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: () => submitForm(),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // List of prawn statuses
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
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: prawnStatuses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(prawnStatuses[index]['status']!),
                  subtitle: Text('( ${prawnStatuses[index]['note']!} )'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editPrawnStatus(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => confirmDelete(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//medium screen view
class mediumScreenView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController statusController;
  final TextEditingController noteController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final List<Map<String, String>> prawnStatuses;
  final String userId;
  final bool isAdmin;
  final Function submitForm;
  final Function(int) editPrawnStatus;
  final Function(int) confirmDelete;
  final Function selectStartDate;
  final Function selectEndDate;

  const mediumScreenView({
    super.key,
    required this.formKey,
    required this.statusController,
    required this.noteController,
    required this.startDateController,
    required this.endDateController,
    required this.prawnStatuses,
    required this.userId,
    required this.isAdmin,
    required this.submitForm,
    required this.editPrawnStatus,
    required this.confirmDelete,
    required this.selectStartDate,
    required this.selectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Form for adding a new prawn status
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input for prawn status
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        controller: statusController,
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
                    ),
                    const SizedBox(width: 20),

                    // Input for optional note
                    Flexible(
                      flex: 2,
                      child: TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        // maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: startDateController,
                          readOnly: true,
                          onTap: () => selectStartDate(),
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffix: Icon(Icons.calendar_view_month),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a start date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: endDateController,
                          readOnly: true,
                          onTap: () => selectEndDate(),
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffix: Icon(Icons.calendar_view_month),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an end date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 16),
                // Submit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () => submitForm(),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // List of prawn statuses
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
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: prawnStatuses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(prawnStatuses[index]['status']!),
                  subtitle: Text('( ${prawnStatuses[index]['note']!} )'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editPrawnStatus(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => confirmDelete(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//large screen view
class largeScreenView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController statusController;
  final TextEditingController noteController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final List<Map<String, String>> prawnStatuses;
  final String userId;
  final bool isAdmin;
  final Function submitForm;
  final Function(int) editPrawnStatus;
  final Function(int) confirmDelete;
  final Function selectStartDate;
  final Function selectEndDate;

  const largeScreenView({
    super.key,
    required this.formKey,
    required this.statusController,
    required this.noteController,
    required this.startDateController,
    required this.endDateController,
    required this.prawnStatuses,
    required this.userId,
    required this.isAdmin,
    required this.submitForm,
    required this.editPrawnStatus,
    required this.confirmDelete,
    required this.selectStartDate,
    required this.selectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Form for adding a new prawn status
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Input for prawn status
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: statusController,
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
                    ),
                    const SizedBox(width: 16),

                    // Input for optional note
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        // maxLines: 3,
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox())
                  ],
                ),
                const SizedBox(height: 16),
                if (isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: startDateController,
                          readOnly: true,
                          onTap: () => selectStartDate(),
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffix: Icon(Icons.calendar_view_month),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a start date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: endDateController,
                          readOnly: true,
                          onTap: () => selectEndDate(),
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffix: Icon(Icons.calendar_view_month),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an end date';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(flex: 2, child: SizedBox())
                    ],
                  ),
                const SizedBox(height: 16),
                // Submit button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: () => submitForm(),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          Column(
            children: [
              // List of prawn statuses
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
            ],
          ),
          Expanded(
            flex: 3,
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: prawnStatuses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(prawnStatuses[index]['status']!),
                  subtitle: Text('( ${prawnStatuses[index]['note']!} )'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editPrawnStatus(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => confirmDelete(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
