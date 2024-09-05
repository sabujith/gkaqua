import 'package:flutter/material.dart';

class FemalePrawnScreen extends StatefulWidget {
  const FemalePrawnScreen({super.key});

  @override
  State<FemalePrawnScreen> createState() => _FemalePrawnScreenState();
}

class _FemalePrawnScreenState extends State<FemalePrawnScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variables to capture user input
  String? selectedPond;
  String? selectedStatus;
  DateTime? selectedDateBroughtIn;
  DateTime? selectedUpdatedDate;

  // TextEditingControllers for form fields
  final TextEditingController locationController = TextEditingController();
  final TextEditingController initialNumberController = TextEditingController();
  final TextEditingController updatedNumberController = TextEditingController();
  final TextEditingController completedMatingCycleController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController discardedValuesController =
      TextEditingController();

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the widget tree
    locationController.dispose();
    initialNumberController.dispose();
    updatedNumberController.dispose();
    completedMatingCycleController.dispose();
    notesController.dispose();
    discardedValuesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        shadowColor: Colors.blue,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Female Prawn Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Date Brought In
              Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: ListTile(
                  title: Text(
                    "Date Brought In: ${selectedDateBroughtIn != null ? selectedDateBroughtIn!.toLocal().toString().split(' ')[0] : 'Select Date'}",
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () =>
                      _selectDate(context, selectedDateBroughtIn, (date) {
                    setState(() {
                      selectedDateBroughtIn = date;
                    });
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                    labelText: 'Location',
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pond Name Dropdown
              DropdownButtonFormField<String>(
                value: selectedPond,
                decoration: InputDecoration(
                    labelText: 'Pond Name',
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                items: ["Pond 1", "Pond 2", "Pond 3"].map((String pond) {
                  return DropdownMenuItem<String>(
                    value: pond,
                    child: Text(pond),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPond = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a pond';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Initial Number
              TextFormField(
                controller: initialNumberController,
                decoration: InputDecoration(
                    labelText: "Initial Number",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Initial number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Updated Numbers
              TextFormField(
                controller: updatedNumberController,
                decoration: InputDecoration(
                  labelText: "Updated Numbers",
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Updated Number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Numbers Updated Date
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5)),
                child: ListTile(
                  title: Text(
                      "Numbers Updated Date: ${selectedUpdatedDate != null ? selectedUpdatedDate!.toLocal().toString().split(" ")[0] : 'Select Date'}"),
                  trailing: Icon(Icons.calendar_month),
                  onTap: () {
                    _selectDate(context, selectedUpdatedDate, (date) {
                      setState(() {
                        selectedUpdatedDate = date;
                      });
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                    labelText: "Status",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                items:
                    ["New", "Combined", "Again Something"].map((String status) {
                  return DropdownMenuItem(
                    child: Text(status),
                    value: status,
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the status";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Completed Mating Cycle
              TextFormField(
                controller: completedMatingCycleController,
                decoration: InputDecoration(
                    labelText: "Completed Mating Cycle",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                    labelText: "Notes",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Discarded Values
              TextFormField(
                controller: discardedValuesController,
                decoration: InputDecoration(
                    labelText: "Discarded Values",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Show submission message with all the input values
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Form Submitted Successfully!\n"
                        "Location: ${locationController.text}\n"
                        "Pond: ${selectedPond ?? 'Not selected'}\n"
                        "Initial Number: ${initialNumberController.text}\n"
                        "Updated Numbers: ${updatedNumberController.text}\n"
                        "Date Brought In: ${selectedDateBroughtIn != null ? selectedDateBroughtIn!.toLocal().toString().split(' ')[0] : 'Not selected'}\n"
                        "Numbers Updated Date: ${selectedUpdatedDate != null ? selectedUpdatedDate!.toLocal().toString().split(' ')[0] : 'Not selected'}\n"
                        "Status: ${selectedStatus ?? 'Not selected'}\n"
                        "Completed Mating Cycle: ${completedMatingCycleController.text}\n"
                        "Notes: ${notesController.text}\n"
                        "Discarded Values: ${discardedValuesController.text}",
                      ),
                    ));

                    // Clear the form fields after submission
                    locationController.clear();
                    initialNumberController.clear();
                    updatedNumberController.clear();
                    completedMatingCycleController.clear();
                    notesController.clear();
                    discardedValuesController.clear();
                    setState(() {
                      selectedPond = null;
                      selectedStatus = null;
                      selectedDateBroughtIn = null;
                      selectedUpdatedDate = null;
                    });

                    // Optionally, you can also reset the form
                    _formKey.currentState!.reset();
                  }
                },
                child: Text(
                  'SUBMIT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
