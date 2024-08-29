import 'package:flutter/material.dart';

class MalePrawnScreen extends StatefulWidget {
  const MalePrawnScreen({super.key});

  @override
  State<MalePrawnScreen> createState() => _MalePrawnScreenState();
}

class _MalePrawnScreenState extends State<MalePrawnScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPond;
  String? selectedStatus;
  DateTime? selectedDateBroughtIn;
  DateTime? selectedUpdatedDate;

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.blue,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context)
                .pop(); // To navigate back to the previous screen
          },
        ),
        title: const Text('Male Prawn Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Date Brought In
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
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
                decoration: InputDecoration(
                    labelText: "Location",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Pond Name Dropdown
              DropdownButtonFormField<String>(
                value: selectedPond,
                decoration: InputDecoration(
                    labelText: "Pond Name",
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
                  if (value == null) {
                    return 'Please select a pond';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Initial Numbers
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Initial Numbers",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter initial numbers';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Updated Numbers
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Updated Numbers",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter updated numbers';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Numbers Updated Date
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  title: Text(
                    "Numbers Updated Date: ${selectedUpdatedDate != null ? selectedUpdatedDate!.toLocal().toString().split(' ')[0] : 'Select Date'}",
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () =>
                      _selectDate(context, selectedUpdatedDate, (date) {
                    setState(() {
                      selectedUpdatedDate = date;
                    });
                  }),
                ),
              ),
              SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                    labelText: "Status",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                items: ["NEW", "Combined", "Discarded"].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Completed Mating Cycle
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Completed Mating Cycle",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Notes",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                maxLines: 4,
              ),
              SizedBox(height: 16),

              // Discarded Values
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Discarded Values",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1))),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // Handle form submission here
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form submitted successfully!')),
                    );
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
