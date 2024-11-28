import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/models/waterParameter.dart';
import 'package:gk_aqua/screens/activities/WaterQualityActivityScreen.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/division_services.dart';
import 'package:gk_aqua/services/tank_services.dart';
import 'package:gk_aqua/services/waterParameter_services.dart';
import 'package:gk_aqua/services/waterQuality_services.dart';

class WaterQualityUpdate extends StatelessWidget {
  const WaterQualityUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaterQualityActivityUpdateScreen(),
    );
  }
}

class WaterQualityActivityUpdateScreen extends StatefulWidget {
  final Map<String, dynamic>? WaterQualityData;
  const WaterQualityActivityUpdateScreen({super.key, this.WaterQualityData});

  @override
  State<WaterQualityActivityUpdateScreen> createState() =>
      _WaterQualityActivityUpdateScreenState();
}

class _WaterQualityActivityUpdateScreenState
    extends State<WaterQualityActivityUpdateScreen> {
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
  waterParameterModel? _selectedWaterParameter;
  String? _selectedWaterParameterUnit;
  final TextEditingController _inputValueController = TextEditingController();
  Map<int, TextEditingController> parameterControllers = {};

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await _getUserDetails();
    await _getDepartments();
    await _getDivisions();
    await _getTanks();
    await _getWaterParameters();
    await _initializeData();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserDetails() async {
    setState(() {
      _userId = 'user123';
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

//Initialize data
  Future<void> _initializeData() async {
    setState(() {
      _dateController.text = widget.WaterQualityData!['check_date'].toString();
      _selectedDepartment = departments.fold(null, (previousValue, element) {
        if (element.id == widget.WaterQualityData!['department_id']) {
          return element;
        }
        return previousValue;
      });

      _selectedDivision = divisions.fold(null, (previousValue, element) {
        if (element.id == widget.WaterQualityData!['division_id']) {
          return element;
        }
        return previousValue;
      });

      _selectedTank = tanks.fold(null, (previousValue, element) {
        if (element.id == widget.WaterQualityData!['tank_id']) {
          return element;
        }
        return previousValue;
      });

      _selectedWaterParameter =
          waterparameters.fold(null, (previousValue, element) {
        if (element.id == widget.WaterQualityData!['water_parameter_id']) {
          return element;
        }

        _selectedWaterParameterUnit =
            _selectedWaterParameter?.unit?.unit_name ?? "Unit";

        _inputValueController.text = widget.WaterQualityData!['input_value'];

        return previousValue;
      });

      _notesController.text = widget.WaterQualityData!['notes'] ?? '';
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
                if (purpose == 'Update') {
                  _updateWaterQuality();
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

//Update water quality
  void _updateWaterQuality() async {
    int id = widget.WaterQualityData!['id'];
    String date = _dateController.text;
    int departmentId = _selectedDepartment!.id;
    int divisionId = _selectedDivision!.id!;
    int tankId = _selectedTank!.id!;
    int waterParameterId = _selectedWaterParameter!.id!;
    String inputValue = _inputValueController.text;
    String notes = _notesController.text;

    Map<String, dynamic> requestBody = {
      'id': id,
      'check_date': date,
      'employee_code': _userId,
      'department_id': departmentId,
      'division_id': divisionId,
      'tank_id': tankId,
      'water_parameter_id': waterParameterId,
      'input_value': inputValue,
      'notes': notes
    };

    try {
      await WaterqualityServices().updateWaterQualityCheck(id, requestBody);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Success'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Data updated successfully!'),
              ),
            ],
          );
        },
      );
      _cancelUpdate();
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Error'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Something went wrong \n$e'),
                ),
              ],
            );
          });
    }
  }

  //Cancel Update
  void _cancelUpdate() {
    setState(() {
      _dateController.clear();
      _selectedDepartment = null;
      _selectedDivision = null;
      _selectedTank = null;
      _selectedWaterParameter = null;
      _inputValueController.clear();
      _notesController.clear();
    });

    Navigator.pop(context);
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
          'Activity/Water Quality Update',
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
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _desktopView();
                } else {
                  return _mobileView();
                }
              },
            ),
    );
  }

  Widget _desktopView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //User Id Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                            return WaterQuality();
                          },
                        ),
                      );
                    },
                    child: const Wrap(
                      children: [
                        Text(
                          "Add New Water Quality Check",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.add, color: Colors.white)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Date and Department Row
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
                  const SizedBox(width: 10),

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
              const SizedBox(height: 10),

              //Division and Tank Row
              Row(
                children: [
                  //Division Dropdown
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
                  const SizedBox(width: 10),

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
              const SizedBox(height: 10),

              //Water Parameters Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          _selectedWaterParameter?.parameter_name ?? "",
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Water Parameter',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _inputValueController,
                      decoration: InputDecoration(
                        labelText: _selectedWaterParameterUnit,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Notes
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //Update or Cancel row
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
                        _showConfirmationDialog(purpose: "Update");
                      }
                    },
                    child: const Text('Update',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _cancelUpdate,
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //User Id Row
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
              Center(
                child: ElevatedButton(
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
                          return WaterQuality();
                        },
                      ),
                    );
                  },
                  child: const Wrap(
                    children: [
                      Text(
                        "Add New Water Quality Check",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.add, color: Colors.white)
                    ],
                  ),
                ),
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
              const SizedBox(height: 10),

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
              const SizedBox(height: 10),

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
              const SizedBox(height: 10),

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
              const SizedBox(height: 10),

              //Water Parameters Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          _selectedWaterParameter?.parameter_name ?? "",
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Water Parameter',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _inputValueController,
                      decoration: InputDecoration(
                        labelText: _selectedWaterParameterUnit,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Notes
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //Update or Cancel row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                          _showConfirmationDialog(purpose: "Update");
                        }
                      },
                      child: const Text('Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _cancelUpdate,
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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
