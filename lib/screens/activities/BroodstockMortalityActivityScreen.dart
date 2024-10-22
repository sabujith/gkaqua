import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/broodstockMortalityServices.dart';
import 'package:gk_aqua/services/division_services.dart';
import 'package:gk_aqua/services/tank_services.dart';

class BroodstockMortality extends StatelessWidget {
  const BroodstockMortality({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BroodstockMortalityActivityScreen(),
    );
  }
}

class BroodstockMortalityActivityScreen extends StatefulWidget {
  const BroodstockMortalityActivityScreen({super.key});

  @override
  State<BroodstockMortalityActivityScreen> createState() =>
      _BroodstockMortalityActivityScreenState();
}

class _BroodstockMortalityActivityScreenState
    extends State<BroodstockMortalityActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? UserId;
  final _dateController = TextEditingController();
  Department? _selectedDepartment;
  DivisionModel? _selectedDivision;
  TankModel? _selectedTankCode;
  final _malePrawnController = TextEditingController();
  final _femalePrawnController = TextEditingController();
  final _noteController = TextEditingController();

  List<Department> departments = [];
  List<DivisionModel> divisions = [];
  List<TankModel> tanks = [];

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
    _fetchData();
  }

  //
  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    // await Future.wait([_getDepartments(), _getDivisions(), _getTanks()]);
    try {
      // First, fetch departments
      await _getDepartments();

      // Then, after fetching departments, fetch divisions
      await _getDivisions();

      // Finally, fetch tanks
      await _getTanks();
    } catch (e) {
      // Handle errors if necessary
      print('Error fetching data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

// get user details
  void _getUserDetails() async {
    setState(() {
      UserId = "123";
    });
  }

  // get departments
  Future<void> _getDepartments() async {
    DepartmentService departmentService = DepartmentService();
    try {
      List<Department> fetchedDepartments =
          await departmentService.fetchDepartments();

      setState(() {
        departments = fetchedDepartments;
        //if any of the department name is "Broodstock" then set _selectedDepartment to that department
        if (departments
            .any((department) => department.departmentName == "Broodstock")) {
          _selectedDepartment = departments.firstWhere(
              (department) => department.departmentName == "Broodstock");
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: const Text('Error'), children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Error in fetching departments: $e'),
            )
          ]);
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
      print(tanks);
    } catch (e) {
      bool isTankUnavailable =
          e.toString().contains('No Tanks found under this Division');

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

  // select date
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

  //submit form
  void _submitForm() async {
    BroodstockMortalityService broodstockMortalityService =
        BroodstockMortalityService();

    if (_formKey.currentState!.validate()) {
      String date = _dateController.text;
      String? employeeId = UserId;
      int? departmentId = _selectedDepartment!.id;
      int? divisionId = _selectedDivision!.id;
      int? tankId = _selectedTankCode!.id;
      String malePrawn = _malePrawnController.text;
      String femalePrawn = _femalePrawnController.text;
      String note = _noteController.text;

      Map<String, dynamic> requestData = {
        'date': date,
        'employee_code': employeeId,
        'department_id': departmentId,
        'division_id': divisionId,
        'tank_id': tankId,
        'male_prawn_count': malePrawn,
        'female_prawn_count': femalePrawn,
        'notes': note
      };

      try {
        var response =
            await broodstockMortalityService.createMortality(requestData);

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: const Text('Success'),
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Mortality added successfully!'),
                  )
                ],
              );
            },
          );

          _clearForm();
        } else {
          throw 'Failed to add mortality';
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Error'),
              children: <Widget>[
                Text(e.toString()),
              ],
            );
          },
        );
      }
    }
  }

  //clear form
  void _clearForm() {
    setState(() {
      _dateController.clear();
      _selectedDepartment = null;
      _selectedDivision = null;
      _selectedTankCode = null;
      _noteController.clear();
      _malePrawnController.clear();
      _femalePrawnController.clear();
    });
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
          'Activity/Broodstock-Mortality',
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _desktopView();
              } else {
                return _mobileView();
              }
            }),
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
              // User ID Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('User Id : ${UserId}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),

              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context, _dateController),
                decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Department Dropdown
              DropdownButtonFormField<Department>(
                value: departments.firstWhere(
                  (department) => department.departmentName == "Broodstock",
                  orElse: () => departments[0], // Fallback to first if no match
                ),
                onChanged: (Department? newValue) {
                  // Only allow changing if the selected value is not null and matches Broodstock
                  if (newValue?.departmentName == "Broodstock") {
                    setState(() {
                      _selectedDepartment = newValue!;
                      _getDivisions();
                      _selectedDivision = null;
                      _selectedTankCode = null;
                    });
                  }
                },
                items: departments.map((Department department) {
                  return DropdownMenuItem<Department>(
                    value: department,
                    enabled: department.departmentName ==
                        "Broodstock", // Disable if not Broodstock
                    child: Text(
                      department.departmentName,
                      style: TextStyle(
                        color: department.departmentName == "Broodstock"
                            ? Colors.black
                            : Colors.grey, // Optional: Grey out disabled items
                      ),
                    ),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Department',
                ),
                validator: (value) {
                  if (value == null || value.departmentName != "Broodstock") {
                    return 'Please select Broodstock department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Division Dropdown
              DropdownButtonFormField<DivisionModel>(
                value: _selectedDivision,
                onChanged: (DivisionModel? newValue) {
                  setState(() {
                    _selectedDivision = newValue!;
                    _getTanks();
                    _selectedTankCode = null;
                  });
                },
                items: divisions
                    .map((DivisionModel division) =>
                        DropdownMenuItem<DivisionModel>(
                          value: division,
                          child: Text(division.division_name),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Division'),
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
                value: _selectedTankCode,
                onChanged: (TankModel? newValue) {
                  setState(() {
                    _selectedTankCode = newValue!;
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
                    return 'Please select a Tank';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Male Prawns Mortality Number Input
              TextFormField(
                controller: _malePrawnController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Male Prawns Mortality Number',
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of male prawns';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Female Prawns Mortality Number Input
              TextFormField(
                controller: _femalePrawnController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Female Prawns Mortality Number',
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of female prawns';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                    labelText: 'Note', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // User ID Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('User Id : ${UserId}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),

              //Date and Department Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Date
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateController),
                      decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),

                  // Department Dropdown
                  Expanded(
                    child: DropdownButtonFormField<Department>(
                        value: departments.firstWhere(
                          (department) =>
                              department.departmentName == "Broodstock",
                          orElse: () =>
                              departments[0], // Fallback to first if no match
                        ),
                        onChanged: (Department? newValue) {
                          // Only allow changing if the selected value is not null and matches Broodstock
                          if (newValue?.departmentName == "Broodstock") {
                            setState(() {
                              _selectedDepartment = newValue!;
                              _getDivisions();
                              _selectedDivision = null;
                              _selectedTankCode = null;
                            });
                          }
                        },
                        items: departments.map((Department department) {
                          return DropdownMenuItem<Department>(
                            value: department,
                            enabled: department.departmentName ==
                                "Broodstock", // Disable if not Broodstock
                            child: Text(
                              department.departmentName,
                              style: TextStyle(
                                color: department.departmentName == "Broodstock"
                                    ? Colors.black
                                    : Colors
                                        .grey, // Optional: Grey out disabled items
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Department',
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

              // Division and Tank Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Division Dropdown
                  Expanded(
                    child: DropdownButtonFormField<DivisionModel>(
                        value: _selectedDivision,
                        onChanged: (DivisionModel? newValue) {
                          setState(() {
                            _selectedDivision = newValue!;
                            _getTanks();
                            _selectedTankCode = null;
                          });
                        },
                        items: divisions
                            .map((DivisionModel division) =>
                                DropdownMenuItem<DivisionModel>(
                                  value: division,
                                  child: Text(division.division_name),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Division'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a division';
                          }
                          return null;
                        }),
                  ),
                  SizedBox(width: 10),

                  // Tank Dropdown
                  Expanded(
                    child: DropdownButtonFormField<TankModel>(
                        value: _selectedTankCode,
                        onChanged: (TankModel? newValue) {
                          setState(() {
                            _selectedTankCode = newValue!;
                          });
                        },
                        items: tanks
                            .map(
                                (TankModel tank) => DropdownMenuItem<TankModel>(
                                      value: tank,
                                      child: Text(tank.tank_code),
                                    ))
                            .toList(),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Tank'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a Tank';
                          }
                          return null;
                        }),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Male Prawns Mortality Number Input
                  Expanded(
                    child: TextFormField(
                      controller: _malePrawnController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Male Prawns Mortality Number',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of male prawns';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),

                  // Female Prawns Mortality Number Input
                  Expanded(
                    child: TextFormField(
                      controller: _femalePrawnController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Female Prawns Mortality Number',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of female prawns';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              //Note Input
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                    labelText: 'Note', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              // Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
