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
  String? unit = "mg";
  String? expiry = "19/05/2023";
  double? quantity;

  bool isLoading = true; // Added isLoading state

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Fetch all data
    await Future.wait([
      getUser(),
      getDepartments(),
      getDivisions(),
      getTankCodes(),
      getFeedTypes(),
    ]);

    // stop loading after getting required data
    setState(() {
      isLoading = false;
    });
  }

  // Function to get user details
  Future<void> getUser() async {
    await Future.delayed(const Duration(microseconds: 500));
    setState(() {
      userId = "user123";
    });
  }

  // Function to get departments
  Future<List<String>> getDepartments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Hatchery', 'Broodstock'];
  }

  // Function to get divisions
  Future<List<String>> getDivisions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ['Div1', 'Div2', 'Div3'];
  }

  // Function to get tank codes
  Future<List<String>> getTankCodes() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ['T1', 'T2', 'T3'];
  }

  // Function to get feed types
  Future<List<String>> getFeedTypes() async {
    await Future.delayed(const Duration(milliseconds: 100));
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

  // Function to select time
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
          onPressed: () {
            Navigator.of(context).pop();
          },
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Single global loader
            )
          : SingleChildScrollView(
              child: Padding(
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
                          Text(
                            'User Id : ${userId!}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Date/Time Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blue, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: _selectDate,
                              child: Text(
                                style: TextStyle(color: Colors.blue),
                                selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('dd-MM-yyyy')
                                        .format(selectedDate!),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blue, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: _selectTime,
                              child: Text(
                                style: TextStyle(color: Colors.blue),
                                selectedTime == null
                                    ? 'Select Time'
                                    : selectedTime!.format(
                                        context,
                                      ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Department Dropdown
                      FutureBuilder<List<String>>(
                          future: getDepartments(),
                          builder: (context, snapshot) {
                            return DropdownButtonFormField<String>(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Select a Department";
                                }
                                return null;
                              },
                              value: selectedDepartment,
                              decoration: const InputDecoration(
                                labelText: 'Department',
                                border: OutlineInputBorder(),
                              ),
                              items: snapshot.data?.map((String department) {
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
                            );
                          }),
                      SizedBox(height: 20),

                      // Division and Tank Code Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder(
                                future: getDivisions(),
                                builder: (context, snapshot) {
                                  return DropdownButtonFormField<String>(
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
                                    items:
                                        snapshot.data?.map((String division) {
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
                                  );
                                }),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              child: FutureBuilder(
                                  future: getTankCodes(),
                                  builder: (context, snapshot) {
                                    return DropdownButtonFormField<String>(
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
                                      items:
                                          snapshot.data?.map((String tankCode) {
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
                                    );
                                  })),
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
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),

                            // Feed Type Dropdown
                            FutureBuilder(
                                future: getFeedTypes(),
                                builder: (context, snapshot) {
                                  return DropdownButtonFormField<String>(
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
                                    items:
                                        snapshot.data?.map((String feedType) {
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
                                  );
                                }),
                            SizedBox(height: 10),

                            //quantity, Unit, Expiry
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
                                      labelText: "Quantity",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    enabled: false,
                                    style: TextStyle(color: Colors.blue),
                                    initialValue: unit,
                                    // readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Unit",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: expiry,
                                    enabled: false,
                                    style: TextStyle(color: Colors.blue),
                                    decoration: const InputDecoration(
                                        labelText: "Expiry",
                                        border: OutlineInputBorder()),
                                  ),
                                )
                              ],
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            submitFeeding();
                          },
                          child: const Text('Submit',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

//submission fn
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
