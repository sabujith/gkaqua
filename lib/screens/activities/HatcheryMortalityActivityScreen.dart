import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/screens/activities/HatcheryMortalityViewScreen.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/division_services.dart';
import 'package:gk_aqua/services/hatcheryMortalityServices.dart';
import 'package:gk_aqua/services/tank_services.dart';

class HatcheryMortality extends StatelessWidget {
  const HatcheryMortality({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HatcheryMortalityActivityScreen(),
    );
  }
}

class HatcheryMortalityActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? updatingData;
  final bool isEditing;
  const HatcheryMortalityActivityScreen(
      {super.key, this.updatingData, this.isEditing = false});

  @override
  State<HatcheryMortalityActivityScreen> createState() =>
      _HatcheryMortalityActivityScreenState();
}

class _HatcheryMortalityActivityScreenState
    extends State<HatcheryMortalityActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? UserId;
  final _dateController = TextEditingController();
  Department? _selectedDepartment;
  DivisionModel? _selectedDivision;
  TankModel? _selectedTankCode;
  final _larvaeCountController = TextEditingController();
  final _countMultiplierController = TextEditingController();
  final _totalCountController = TextEditingController();
  final _notesController = TextEditingController();

  List<Department> departments = [];
  List<DivisionModel> divisions = [];
  List<TankModel> tanks = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
    _fetchData();
    // Add listeners to the text fields to calculate the total count on input change
    _larvaeCountController.addListener(_calculateTotalCount);
    _countMultiplierController.addListener(_calculateTotalCount);
  }

  // Fetch data
  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _getDepartments();
      await _getDivisions();
      await _getTanks();
      await _initializeData();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get user details
  void _getUserDetails() {
    setState(() {
      UserId = 'user123';
    });
  }

  //initialize data for updating
  Future<void> _initializeData() async {
    if (widget.isEditing && widget.updatingData != null) {
      setState(() {
        _isEditing = true;
        _dateController.text = widget.updatingData!['date'];
        _selectedDivision = divisions.fold(null, (previousValue, item) {
          if (item.id == widget.updatingData!['divisionId']) {
            return item;
          } else {
            return previousValue;
          }
        });
        _selectedTankCode = tanks.fold(null, (previousValue, item) {
          if (item.id == widget.updatingData!['tankId']) {
            return item;
          } else {
            return previousValue;
          }
        });
        _larvaeCountController.text =
            widget.updatingData!['larvaeCount'].toString();
        _countMultiplierController.text =
            widget.updatingData!['countMultiplier'].toString();
        _totalCountController.text =
            widget.updatingData!['totalMortality'].toString();
        _notesController.text = widget.updatingData!['note'];
      });
    } else {
      setState(() {
        _isEditing = false;
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

        if (departments
            .any((department) => department.departmentName == 'Hatchery')) {
          _selectedDepartment = departments.firstWhere(
            (department) => department.departmentName == 'Hatchery',
          );
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
                child: Text('Error in fetching departments: $e'),
              ),
            ],
          );
        },
      );
    }
  }

  // Get divisions
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
              ),
            ],
          );
        },
      );
    }
  }

  // Get tanks
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

  //select date
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

  // Function to calculate and set total count
  void _calculateTotalCount() {
    double larvaeCount = double.tryParse(_larvaeCountController.text) ?? 0;
    double countMultiplier =
        double.tryParse(_countMultiplierController.text) ?? 1;
    double totalCount = larvaeCount * countMultiplier;

    setState(() {
      _totalCountController.text = totalCount.toString();
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
                } else if (purpose == 'Update') {
                  _updateForm();
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

  //Submit form
  void _submitForm() async {
    HatcheryMortalityService hatcheryMortalityService =
        HatcheryMortalityService();

    String date = _dateController.text;
    String employee_code = UserId!;
    int department_id = _selectedDepartment!.id!;
    int division_id = _selectedDivision!.id!;
    int tank_id = _selectedTankCode!.id!;
    String larvae_count = _larvaeCountController.text;
    String count_multiplier = _countMultiplierController.text;
    String total_mortality_count = _totalCountController.text;
    String notes = _notesController.text;

    Map<String, dynamic> requestData = {
      'date': date,
      'employee_code': employee_code,
      'department_id': department_id,
      'division_id': division_id,
      'tank_id': tank_id,
      'larvae_count': larvae_count,
      'count_multiplier': count_multiplier,
      'total_mortality_count': total_mortality_count,
      'notes': notes
    };

    try {
      var response =
          await hatcheryMortalityService.createMortality(requestData);
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
                  child: const Text('Mortality created successfully'),
                ),
              ],
            );
          },
        );

        _clearForm();
      } else {
        throw 'Failed to add mortality data';
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
                child: Text(e.toString()),
              )
            ],
          );
        },
      );
    }
  }

  //update form
  void _updateForm() async {
    int id = widget.updatingData!['id'];
    Map<String, dynamic> requestData = {
      'date': _dateController.text,
      'employee_code': UserId,
      'department_id': _selectedDepartment!.id,
      'division_id': _selectedDivision!.id,
      'tank_id': _selectedTankCode!.id,
      'larvae_count': _larvaeCountController.text,
      'count_multiplier': _countMultiplierController.text,
      'total_mortality_count': _totalCountController.text,
      'notes': _notesController.text
    };

    try {
      await HatcheryMortalityService().updateMortality(requestData, id);
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
                  child: const Text('Mortality updated successfully'),
                ),
              ],
            );
          });
      setState(() {
        _isEditing = false;
      });

      _clearForm();
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
                  child: Text(e.toString()),
                )
              ],
            );
          });
    }
  }

  //clear form
  void _clearForm() {
    _dateController.clear();
    _selectedDivision = null;
    _selectedTankCode = null;
    _larvaeCountController.clear();
    _countMultiplierController.clear();
    _totalCountController.clear();
    _notesController.clear();
  }

  //cancel update
  void _cancelUpdate() {
    setState(() {
      _isEditing = false;
    });
    _clearForm();
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
          'Activity/Hatchery-Mortality',
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            //User Id
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'User Id : ${UserId}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            //View and Add Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _isEditing
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        onPressed: _cancelUpdate,
                        child: const Wrap(
                          children: [
                            Text(
                              "Add Hatchery Mortality Record",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.add, color: Colors.white)
                          ],
                        ),
                      )
                    : ElevatedButton(
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
                                return HatcheryMortalityView();
                              },
                            ),
                          );
                        },
                        child: const Wrap(
                          children: [
                            Text(
                              "View Hatchery Mortality Records",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.remove_red_eye_outlined,
                                color: Colors.white)
                          ],
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 10),

            //Date and Department Row
            Row(
              children: [
                //Date
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

                //Department
                Expanded(
                  child: DropdownButtonFormField<Department>(
                    value: departments.firstWhere(
                      (department) => department.departmentName == "Hatchery",
                      orElse: () =>
                          departments[0], // Fallback to first if no match
                    ),
                    onChanged: (Department? newValue) {
                      // Only allow changing if the selected value is not null and matches Hatchery
                      if (newValue?.departmentName == "Hatchery") {
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
                            "Hatchery", // Disable if not Hatchery
                        child: Text(
                          department.departmentName,
                          style: TextStyle(
                            color: department.departmentName == "Hatchery"
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
                      if (value == null || value.departmentName != "Hatchery") {
                        return 'Please select Hatchery department';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            //Division and Tank Code Row
            Row(
              children: [
                //Division
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
                        border: OutlineInputBorder(), labelText: 'Division'),
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
                )
              ],
            ),
            SizedBox(height: 10),

            // Larvae Count, Count Multiplier and Total count Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: // Larva Count
                      TextFormField(
                    controller: _larvaeCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Larvae Count'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Larvae Count';
                      }
                      return null;
                    },
                  ),
                ),
                Text(' x ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: TextFormField(
                    controller: _countMultiplierController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Count Multiplier'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Count Multiplier';
                      }
                      return null;
                    },
                  ),
                ),
                Text(' = ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: //total count
                      TextFormField(
                    controller: _totalCountController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Total Count'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Total Count';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
            //label
            Row(
              children: [
                Expanded(
                  child: Text('Count in Spoons'),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text('Count per Spoon'),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text('Total Count'),
                ),
              ],
            ),
            SizedBox(height: 10),

            //notes
            TextFormField(
              controller: _notesController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Notes'),
            ),
            SizedBox(height: 10),

            // Submit Button
            _isEditing
                ? Row(
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
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  )
                : Row(
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
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  )
          ]),
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
          child: Column(children: [
            //User Id
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User Id : ${UserId}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            //View and Add Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isEditing
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        onPressed: () {
                          _cancelUpdate();
                        },
                        child: const Wrap(
                          children: [
                            Text(
                              "Add Hatchery Mortality Record",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.add, color: Colors.white)
                          ],
                        ),
                      )
                    : ElevatedButton(
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
                                return HatcheryMortalityView();
                              },
                            ),
                          );
                        },
                        child: const Wrap(
                          children: [
                            Text(
                              "View Hatchery Mortality Records",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.remove_red_eye_outlined,
                                color: Colors.white)
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

            //Department
            DropdownButtonFormField<Department>(
              value: departments.firstWhere(
                (department) => department.departmentName == "Hatchery",
                orElse: () => departments[0], // Fallback to first if no match
              ),
              onChanged: (Department? newValue) {
                // Only allow changing if the selected value is not null and matches Hatchery
                if (newValue?.departmentName == "Hatchery") {
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
                      "Hatchery", // Disable if not Hatchery
                  child: Text(
                    department.departmentName,
                    style: TextStyle(
                      color: department.departmentName == "Hatchery"
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
                if (value == null || value.departmentName != "Hatchery") {
                  return 'Please select Hatchery department';
                }
                return null;
              },
            ),
            SizedBox(height: 10),

            //Division
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

            // Larvae Count and Count Multiplier
            Row(
              children: [
                Expanded(
                  child: // Larva Count
                      TextFormField(
                    controller: _larvaeCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Larvae Count'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Larvae Count';
                      }
                      return null;
                    },
                  ),
                ),
                Text(' x ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: TextFormField(
                    controller: _countMultiplierController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Count Multiplier'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Count Multiplier';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
            //label
            Row(
              children: [
                Expanded(
                  child: Text('Count in Spoons'),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text('Count per Spoon'),
                ),
              ],
            ),
            SizedBox(height: 10),

            //total count
            TextFormField(
              controller: _totalCountController,
              readOnly: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Total Count'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Total Count';
                }
                return null;
              },
            ),
            SizedBox(height: 10),

            //notes
            TextFormField(
              controller: _notesController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Notes'),
            ),
            SizedBox(height: 10),

            // Submit and Update Button
            _isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _showConfirmationDialog(purpose: "Update");
                            }
                          },
                          child: const Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onPressed: () {
                          _cancelUpdate();
                        },
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white)),
                      ))
                    ],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showConfirmationDialog(purpose: "Submit");
                      }
                    },
                    child: const Text('Submit',
                        style: TextStyle(color: Colors.white)),
                  ),
          ]),
        ),
      ),
    );
  }
}
