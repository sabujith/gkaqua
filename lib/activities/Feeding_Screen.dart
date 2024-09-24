import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  final _formKey = GlobalKey<FormState>();

  String? userId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedDepartment;
  String? selectedDivision;
  String? selectedTankCode;
  String? selectedFeedType;
  String? unit = "kg";
  String? expiry;
  double? quantity;

  @override
  void initState() {
    super.initState();
    getUser();
  }

//function to get user details
  Future<void> getUser() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      userId = "user123";
    });
  }

  // Function to get departments
  List<String> getDepartments() {
    return ['Hatchery', 'Broodstock'];
  }

  // Function to get divisions
  List<String> getDivisions() {
    return ['Div1', 'Div2', 'Div3'];
  }

  // Function to get tank codes
  List<String> getTankCodes() {
    return ['T1', 'T2', 'T3'];
  }

  // Function to get feed types
  List<String> getFeedTypes() {
    return ['Blood Worm', 'Squid'];
  }

  // Function to select date
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

//function to select time
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

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
          ),
        ),
        title: const Text(
          'Activity/Feeding',
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
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User ID Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userId == null)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      'User Id : ${userId!}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              SizedBox(height: 20),

              // Date/Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Button to select the date
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.blue, width: 1), // Blue border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _selectDate, // Your date selection function
                      child: Text(
                        style: TextStyle(color: Colors.blue),
                        selectedDate == null
                            ? 'Select Date'
                            : DateFormat('dd-MM-yyyy').format(selectedDate!),
                        textAlign:
                            TextAlign.center, // Center text inside the button
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Button to select the time
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.blue, width: 1), // Blue border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _selectTime, // Your time selection function
                      child: Text(
                        style: TextStyle(color: Colors.blue),
                        selectedTime == null
                            ? 'Select Time'
                            : selectedTime!.format(
                                context,
                              ), // Display the selected time
                        textAlign:
                            TextAlign.center, // Center text inside the button
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Department Dropdown
              DropdownButtonFormField<String>(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Select a Department";
                  } else {}
                },
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                items: getDepartments().map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                  });
                },
              ),
              SizedBox(height: 20),

              // Division and Tank Code Dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Select a Division";
                        } else {}
                      },
                      value: selectedDivision,
                      decoration: const InputDecoration(
                        labelText: 'Division',
                        border: OutlineInputBorder(),
                      ),
                      items: getDivisions().map((String division) {
                        return DropdownMenuItem<String>(
                          value: division,
                          child: Text(division),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDivision = newValue;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Select a Tank Code";
                        } else {}
                      },
                      value: selectedTankCode,
                      decoration: const InputDecoration(
                        labelText: 'Tank Code',
                        border: OutlineInputBorder(),
                      ),
                      items: getTankCodes().map((String tankCode) {
                        return DropdownMenuItem<String>(
                          value: tankCode,
                          child: Text(tankCode),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedTankCode = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Feed Details Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feeding Details',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    // Feed Type Dropdown
                    DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Select a Feed Type";
                        } else {}
                      },
                      value: selectedFeedType,
                      decoration: const InputDecoration(
                        labelText: 'Feed Type',
                        border: OutlineInputBorder(),
                      ),
                      items: getFeedTypes().map((String feedType) {
                        return DropdownMenuItem<String>(
                          value: feedType,
                          child: Text(feedType),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedFeedType = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Quantity, Unit, Expiry Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Select the Quantity";
                              } else {}
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                quantity = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: unit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                unit = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Expiry',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                expiry = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  onPressed: () {
                    // Save action
                    submitFeeding();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitFeeding() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          content: Container(
            child: Column(
              children: [
                Text(
                    "$selectedDate $selectedDepartment $selectedTime $selectedDivision $selectedTankCode $selectedFeedType $quantity $unit $expiry"),
              ],
            ),
          )));

      setState(() {
        selectedDate = null;
        selectedTime = null;
        selectedDepartment = null;
        selectedDivision = null;
        selectedTankCode = null;
        selectedFeedType = null;
        quantity = null;
        expiry = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          content: Text('Please fill out all the fields'),
        ),
      );
    }
  }
}
