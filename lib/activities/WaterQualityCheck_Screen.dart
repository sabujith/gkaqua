import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WaterQualityCheckScreen extends StatefulWidget {
  const WaterQualityCheckScreen({super.key});

  @override
  State<WaterQualityCheckScreen> createState() =>
      _WaterQualityCheckScreenState();
}

class _WaterQualityCheckScreenState extends State<WaterQualityCheckScreen> {
  final _formKey = GlobalKey<FormState>();

  String? userId;
  DateTime? selectedDate;
  String? selectedDepartment;
  String? selectedDivision;
  String? selectedTankCode;

  List<Map<String, String>> waterParameters = [];
  List<TextEditingController> waterParameterControllers = [];

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getWaterParameters(); // Fetch water parameters on form initialization
  }

  // function to get user details
  Future<void> getUserDetails() async {
    setState(() {
      userId = 'user123';
    });
  }

  // function to get departments
  Future<List<String>> getDepartments() async {
    return ['Hatchery', 'Broodstock'];
  }

  // function to get divisions
  Future<List<String>> getDivisions() async {
    return ['Div1', 'Div2', 'Div3'];
  }

  // function to get tank codes
  Future<List<String>> getTankCodes() async {
    return ['T1', 'T2', 'T3'];
  }

  // function to get water parameters
  Future<void> getWaterParameters() async {
    List<Map<String, String>> data = [
      {'waterParameter': 'Temperature', 'unit': '°C'},
      {'waterParameter': 'Minerals', 'unit': 'mg'},
      {'waterParameter': 'Calcium', 'unit': 'mg'}
    ];
    setState(() {
      waterParameters = data;
      waterParameterControllers =
          List.generate(data.length, (index) => TextEditingController());
    });
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
          'Activity/Water Quality Check',
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Text(
                  'User Id : $userId',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Date Picker Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: _selectDate,
                child: Text(
                  style: TextStyle(color: Colors.blue),
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('dd-MM-yyyy').format(selectedDate!),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Department Dropdown
              FutureBuilder<List<String>>(
                future: getDepartments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedDepartment, // Set the current selected value
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    items: snapshot.data!.map((department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a department' : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              // Division and Tank Code Dropdowns in a Row
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<List<String>>(
                      future: getDivisions(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return DropdownButtonFormField<String>(
                          value:
                              selectedDivision, // Set the current selected value
                          decoration: const InputDecoration(
                            labelText: 'Division',
                            border: OutlineInputBorder(),
                          ),
                          items: snapshot.data!.map((division) {
                            return DropdownMenuItem(
                              value: division,
                              child: Text(division),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDivision = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a division' : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FutureBuilder<List<String>>(
                      future: getTankCodes(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return DropdownButtonFormField<String>(
                          value:
                              selectedTankCode, // Set the current selected value
                          decoration: const InputDecoration(
                            labelText: 'Tank Code',
                            border: OutlineInputBorder(),
                          ),
                          items: snapshot.data!.map((tankCode) {
                            return DropdownMenuItem(
                              value: tankCode,
                              child: Text(tankCode),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTankCode = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Please select a tank code'
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Water Parameters Fields
              Expanded(
                child: ListView.builder(
                  itemCount: waterParameters.length,
                  itemBuilder: (context, index) {
                    final param = waterParameters[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: param['waterParameter'],
                              enabled: false,
                              style: const TextStyle(
                                color: Colors.blue, // Change text color to blue
                              ),
                              decoration: const InputDecoration(
                                labelText: "Water Parameter",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: waterParameterControllers[index],
                              decoration: InputDecoration(
                                labelText: param['unit'],
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter ${param['waterParameter']} value';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {
                  formSubmit();
                },
                child:
                    const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void formSubmit() {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      // Collecting input values
      String allValues = "Successfully submitted \n \n"
          "Selected Date : $selectedDate \n"
          "Selected Department: $selectedDepartment\n"
          "Selected Division: $selectedDivision\n"
          "Selected Tank Code: $selectedTankCode\n";

      for (int i = 0; i < waterParameters.length; i++) {
        final param = waterParameters[i];
        final controller = waterParameterControllers[i];
        allValues +=
            "${param['waterParameter']}: ${controller.text} (${param['unit']})\n";
      }

      // submit snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(allValues),
        ),
      );

      setState(() {
        selectedDate = null;
        selectedDepartment = null;
        selectedDivision = null;
        selectedTankCode = null;
        waterParameterControllers.forEach((controller) {
          controller.clear();
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text('Please fill out all the fields'),
        ),
      );
    }
  }
}
