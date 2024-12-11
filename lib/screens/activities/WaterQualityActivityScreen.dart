import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/models/waterParameter.dart';
import 'package:gk_aqua/screens/activities/WaterQualityActivityView.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/division_services.dart';
import 'package:gk_aqua/services/tank_services.dart';
import 'package:gk_aqua/services/waterParameter_services.dart';
import 'package:gk_aqua/services/waterQuality_services.dart';

class WaterQuality extends StatelessWidget {
  const WaterQuality({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaterqualityActivityScreen(),
    );
  }
}

class WaterqualityActivityScreen extends StatefulWidget {
  const WaterqualityActivityScreen({super.key});

  @override
  State<WaterqualityActivityScreen> createState() =>
      _WaterqualityActivityScreenState();
}

class _WaterqualityActivityScreenState
    extends State<WaterqualityActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  final TextEditingController _dateController = TextEditingController();
  Department? _selectedDepartment;
  DivisionModel? _selectedDivision;
  TankModel? _selectedTank;
  final TextEditingController _notesController = TextEditingController();

  List<Department> departments = [];
  List<DivisionModel> divisions = [];
  List<TankModel> tanks = [];
  List<waterParameterModel> waterparameters = [];
  Map<int, TextEditingController> parameterControllers = {};

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
    _fetchData();
  }

  //fetch datas
  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await _getDepartments();
    await _getDivisions();
    await _getTanks();
    await _getWaterParameters();
    setState(() {
      _isLoading = false;
    });
  }

  //Get user details
  void _getUserDetails() async {
    setState(() {
      _userId = "user123";
    });
  }

  //Select date
  void _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
        controller.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // Format: YYYY-MM-DD
      });
    }
  }

  // Get departments
  Future<void> _getDepartments() async {
    DepartmentService departmentService = DepartmentService();
    try {
      List<Department> fetchedDepartments =
          await departmentService.fetchDepartments();
      setState(() {
        departments = fetchedDepartments;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Error'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Error fetching departments: $e'),
              ),
            ],
          );
        },
      );
    }
  }

  // get divisions
  Future<void> _getDivisions() async {
    DivisionServices divisionServices = DivisionServices();
    try {
      if (_selectedDepartment == null) {
        List<DivisionModel> fetchedDivisions =
            await divisionServices.fetchDivisions();

        setState(() {
          divisions = fetchedDivisions;
        });
      } else {
        List<DivisionModel> fetchedDivisions = await divisionServices
            .fetchDivisionsByDepartmentId(id: _selectedDepartment!.id);
        setState(() {
          divisions = fetchedDivisions;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Error'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Error in fetching divisions: $e'),
              )
            ],
          );
        },
      );
    }
  }

  // get tanks details
  Future<void> _getTanks() async {
    TankService tankService = TankService();
    try {
      if (_selectedDivision == null) {
        List<TankModel> fetchedTanks = await tankService.fetchTanks();

        setState(() {
          tanks = fetchedTanks;
        });
      } else {
        List<TankModel> fetchedTanks = await tankService.fetchTanksByDivisionId(
            id: _selectedDivision!.id!);

        setState(() {
          tanks = fetchedTanks;
        });
      }
    } catch (e) {
      bool isTankUnavailable =
          e.toString().contains('No Tanks found under this Criteria');

      if (isTankUnavailable) {
        setState(() {
          tanks = [];
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(isTankUnavailable ? 'Tank Unavailable' : 'Error'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(e.toString()),
                )
              ]);
        },
      );
    }
  }

  //Get water parameters
  Future<void> _getWaterParameters() async {
    WaterparameterServices waterParameterService = WaterparameterServices();
    try {
      List<waterParameterModel> fetchedWaterParameters =
          await waterParameterService.fetchWaterParameters();
      setState(() {
        waterparameters = fetchedWaterParameters;
        // Initialize controllers for each parameter
        for (var parameter in waterparameters) {
          parameterControllers[parameter.id!] = TextEditingController();
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Error'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Error in fetching water parameters: $e'),
              )
            ],
          );
        },
      );
    }
  }

  // Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Collect date, user ID, department, division, and tank information
    String checkDate = _dateController.text;
    String employeeCode = _userId ?? '';
    int? departmentId = _selectedDepartment?.id;
    int? divisionId = _selectedDivision?.id;
    int? tankId = _selectedTank?.id;
    String? notes = _notesController.text;

    if (departmentId == null || divisionId == null || tankId == null) {
      // Show error message if any required field is missing
      return;
    }

    // Collect input values for each parameter
    List<Map<String, dynamic>> records = [];
    for (var parameter in waterparameters) {
      var inputController = parameterControllers[parameter.id];
      String inputValue = inputController?.text ?? '';

      records.add({
        "check_date": checkDate,
        "employee_code": employeeCode,
        "department_id": departmentId,
        "division_id": divisionId,
        "tank_id": tankId,
        "notes": notes,
        "water_parameter_id": parameter.id,
        "input_value": double.tryParse(inputValue) ?? 0.0,
      });
    }

    // Wrap the records in a map with a key "records"
    Map<String, dynamic> requestData = {
      "records": records,
    };

    try {
      WaterqualityServices waterParameterService = WaterqualityServices();
      var response =
          await waterParameterService.createWaterQualityCheck(requestData);
      // print(requestData);

      if (response.statusCode == 201) {
        // Handle successful response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Water parameters submitted successfully!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );

        _clearForm();
      } else {
        throw 'Failed to submit water parameters';
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Submission Failed"),
            content: Text("Something went wrong: $error"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  //clear form
  void _clearForm() {
    _dateController.clear();
    _selectedDepartment = null;
    _selectedDivision = null;
    _selectedTank = null;
    _notesController.clear();
    setState(() {
      for (var parameter in waterparameters) {
        parameterControllers[parameter.id!] = TextEditingController();
      }
    });
  }

  //confirmation dialog
  void _showConfirmationDialog({required String purpose}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$purpose Confirmation'),
          content: Text('Are you sure you want to $purpose the Data?'),
          actions: <Widget>[
            TextButton(
              child: Text('$purpose'),
              onPressed: () {
                if (purpose == 'Submit') {
                  _submitForm();
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _desktopView();
                } else {
                  return _mobileView();
                }
              }));
  }

  Widget _desktopView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //User Id
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'User Id : ${_userId}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return WaterQualityActivityView();
                          },
                        ),
                      );
                    },
                    child: const Wrap(
                      children: [
                        Text(
                          "View Water Quality Check",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.remove_red_eye_outlined, color: Colors.white)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Date and Department
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateController),
                      decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffix: Icon(Icons.calendar_month)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),

                  //Department Dropdown
                  Expanded(
                    child: DropdownButtonFormField<Department>(
                        value: _selectedDepartment,
                        onChanged: (Department? newValue) {
                          setState(() {
                            _selectedDepartment = newValue;
                            _getDivisions();
                            _selectedDivision = null;
                          });
                        },
                        items: departments.map<DropdownMenuItem<Department>>(
                            (Department department) {
                          return DropdownMenuItem<Department>(
                            value: department,
                            child: Text(department.departmentName),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a department';
                          }
                          return null;
                        }),
                  ),
                ],
              ),

              SizedBox(height: 10),

              //Division Dropdown and Tank Dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DivisionModel>(
                      value: _selectedDivision,
                      onChanged: (DivisionModel? newValue) {
                        setState(() {
                          _selectedDivision = newValue;
                          _getTanks();
                          _selectedTank = null;
                        });
                      },
                      items: divisions.map<DropdownMenuItem<DivisionModel>>(
                          (DivisionModel division) {
                        return DropdownMenuItem<DivisionModel>(
                          value: division,
                          child: Text(division.division_name),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Division',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a division';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),

                  // Tank Dropdown
                  Expanded(
                    child: DropdownButtonFormField<TankModel>(
                      value: _selectedTank,
                      onChanged: (TankModel? newValue) {
                        setState(() {
                          _selectedTank = newValue!;
                        });
                      },
                      items: tanks
                          .map((TankModel tank) => DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_code),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Tank'),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a tank';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              //Water Parameter Fields
              Wrap(
                children: [
                  ...waterparameters.map((parameter) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: parameter
                                    .parameter_name, // Display parameter name
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Water Parameter',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: parameterControllers[parameter.id],
                                decoration: InputDecoration(
                                  labelText: parameter
                                      .unit!.unit_name, // Display unit name
                                  border: OutlineInputBorder(),
                                ),
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Please enter a value for ${parameter.unit!.unit_name}';
                                //   }
                                //   return null;
                                // },
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 10),

              //Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  constraints: BoxConstraints(
                    minHeight:
                        50.0, // Adjust this to match TextFormField height
                  ),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 10),

              //Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showConfirmationDialog(purpose: "Submit");
                      }
                    },
                    child: const Text('Submit',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //User Id
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'User Id : ${_userId}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //View collection button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return WaterQualityActivityView();
                          },
                        ),
                      );
                    },
                    child: const Wrap(
                      children: [
                        Text(
                          "View Water Quality Check",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.remove_red_eye_outlined, color: Colors.white)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context, _dateController),
                decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffix: Icon(Icons.calendar_month)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Department Dropdown
              DropdownButtonFormField<Department>(
                  value: _selectedDepartment,
                  onChanged: (Department? newValue) {
                    setState(() {
                      _selectedDepartment = newValue;
                      _getDivisions();
                      _selectedDivision = null;
                    });
                  },
                  items: departments.map<DropdownMenuItem<Department>>(
                      (Department department) {
                    return DropdownMenuItem<Department>(
                      value: department,
                      child: Text(department.departmentName),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a department';
                    }
                    return null;
                  }),
              SizedBox(height: 10),

              //Division Dropdown
              DropdownButtonFormField<DivisionModel>(
                value: _selectedDivision,
                onChanged: (DivisionModel? newValue) {
                  setState(() {
                    _selectedDivision = newValue;
                    _getTanks();
                    _selectedTank = null;
                  });
                },
                items: divisions.map<DropdownMenuItem<DivisionModel>>(
                    (DivisionModel division) {
                  return DropdownMenuItem<DivisionModel>(
                    value: division,
                    child: Text(division.division_name),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Division',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a division';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Tank Dropdown
              DropdownButtonFormField<TankModel>(
                value: _selectedTank,
                onChanged: (TankModel? newValue) {
                  setState(() {
                    _selectedTank = newValue!;
                  });
                },
                items: tanks
                    .map((TankModel tank) => DropdownMenuItem<TankModel>(
                          value: tank,
                          child: Text(tank.tank_code),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Tank'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a tank';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Water Parameter Fields
              Wrap(
                children: [
                  ...waterparameters.map((parameter) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: parameter
                                    .parameter_name, // Display parameter name
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Water Parameter',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: parameterControllers[parameter.id],
                                decoration: InputDecoration(
                                  labelText: parameter
                                      .unit!.unit_name, // Display unit name
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value for ${parameter.unit!.unit_name}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 10),

              //Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 10),

              //Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _showConfirmationDialog(purpose: "Submit");
                        }
                      },
                      child: const Text('Submit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
