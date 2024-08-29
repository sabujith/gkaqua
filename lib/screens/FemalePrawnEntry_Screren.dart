import 'package:flutter/material.dart';

class FemalePrawnScreen extends StatefulWidget {
  const FemalePrawnScreen({super.key});

  @override
  State<FemalePrawnScreen> createState() => _FemalePrawnScreenState();
}

class _FemalePrawnScreenState extends State<FemalePrawnScreen> {
  //variables for validation and data passing
  final _formKey = GlobalKey<FormState>();
  String? selectedPond;
  String? selectedStatus;
  DateTime? selectedDateBroughtIn;
  DateTime? selectedUpdatedDate;

  //function to pick a date
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.blue,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Female Prawn Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                //Date Brought In
                Container(
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  child: ListTile(
                    title: Text(
                      "Date Brought In: ${selectedDateBroughtIn != null ? selectedDateBroughtIn!.toLocal().toString().split(' ')[0] : 'Selected Date'} ",
                      style: TextStyle(),
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () =>
                        _selectDate(context, selectedDateBroughtIn, (date) {
                      setState(() {});
                      (() {
                        selectedDateBroughtIn = date;
                      });
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                //Location
                TextFormField(
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
                SizedBox(height: 16),

                //Pond Name Dropdown
                DropdownButtonFormField<String>(
                    value: selectedPond,
                    decoration: InputDecoration(
                        labelText: 'Pond Name',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1))),
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
                    }),
                SizedBox(height: 16),

                //initila number field
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Initial Number",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Initial number ";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                //updated Numbers field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Updated Numbers",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Updated Number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Number Updated Date
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5)),
                  child: ListTile(
                    title: Text(
                        "Numbers updated Date: ${selectedUpdatedDate != null ? selectedUpdatedDate!.toLocal().toString().split(" ")[0] : 'Select Date'}"),
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
                SizedBox(height: 16),

                //Status Dropdown
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                      labelText: "Status",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  items: ["New", "Combined", "Again Something"]
                      .map((String status) {
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
                SizedBox(height: 16),

                //completed mating cycle
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Completed Mating Cycle",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                //Notes
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Notes",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  maxLines: 4,
                ),
                SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Discarded Values",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 16,
                ),

                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Form Submitted Successfully')));
                      }
                    },
                    child: Text('SUBMIT'))
              ],
            )),
      ),
    );
  }
}
