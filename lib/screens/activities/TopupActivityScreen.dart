import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/screens/activities/TopupViewScreen.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/broodstockMortalityServices.dart';
import 'package:gk_aqua/services/division_services.dart';
import 'package:gk_aqua/services/tank_services.dart';
import 'package:gk_aqua/services/topup_services.dart';

class ActivityTopup extends StatelessWidget {
  const ActivityTopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TopupActivityScreen(),
    );
  }
}

class TopupActivityScreen extends StatefulWidget {
  final Map<String, dynamic> topupUpdateData;
  final bool isEditing;

  const TopupActivityScreen(
      {super.key, this.topupUpdateData = const {}, this.isEditing = false});

  @override
  State<TopupActivityScreen> createState() => _TopupActivityScreenState();
}

class _TopupActivityScreenState extends State<TopupActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  final TextEditingController _dateController = TextEditingController();
  Department? _selectedDepartment;
  DivisionModel? _selectedDivision;
  TankModel? _selectedTank;
  final TextEditingController _weekStartController = TextEditingController();
  final TextEditingController _weekEndController = TextEditingController();
  final TextEditingController _malePrawnMortalityCountController =
      TextEditingController();
  final TextEditingController _femalePrawnMortalityCountController =
      TextEditingController();
  final TextEditingController _malePrawnTopupCountController =
      TextEditingController();
  final TextEditingController _femalePrawnTopupCountController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Department> departments = [];
  List<DivisionModel> divisions = [];
  List<TankModel> tanks = [];

  bool _isLoading = false;
  // bool _isCheckingMortalityCount = false;
  // bool _isFormSubmit = false;
  bool _isAdmin = true;
  bool isEditing = false;

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
    await _initializeData();
    setState(() {
      _isLoading = false;
    });
  }

  //Initialize data for editing
  Future<void> _initializeData() async {
    if (widget.isEditing && widget.topupUpdateData != null) {
      setState(() {
        isEditing = true;
        _dateController.text = widget.topupUpdateData['date'];
        _selectedDepartment = departments.fold(null, (previousValue, element) {
          if (element.id == widget.topupUpdateData['departmentId']) {
            return element;
          }
          return previousValue;
        });
        _selectedDivision = divisions.fold(null, (previousValue, element) {
          if (element.id == widget.topupUpdateData['divisionId']) {
            return element;
          }
          return previousValue;
        });
        _selectedTank = tanks.fold(null, (previousValue, element) {
          if (element.id == widget.topupUpdateData['tankId']) {
            return element;
          }
          return previousValue;
        });
        _weekStartController.text = widget.topupUpdateData['weekStart'];
        _weekEndController.text = widget.topupUpdateData['weekEnd'];
        _malePrawnMortalityCountController.text =
            widget.topupUpdateData['malePrawnMortalityCount'].toString();
        _femalePrawnMortalityCountController.text =
            widget.topupUpdateData['femalePrawnMortalityCount'].toString();
        _malePrawnTopupCountController.text =
            widget.topupUpdateData['malePrawnTopupCount'].toString();
        _femalePrawnTopupCountController.text =
            widget.topupUpdateData['femalePrawnTopupCount'].toString();
        _notesController.text = widget.topupUpdateData['notes'];
      });
    }
  }

  // get user details
  void _getUserDetails() async {
    setState(() {
      _userId = "user123";
    });
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
      bool isDivisionUnavailable =
          e.toString().contains('No Divisions found under this Department');
      if (isDivisionUnavailable) {
        setState(() {
          divisions = [];
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title:
                Text(isDivisionUnavailable ? 'Division Unavailable' : 'Error'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(e.toString()),
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

  //Find Mortality Count
  void _findMortalityCount() async {
    BroodstockMortalityService broodstockMortalityService =
        BroodstockMortalityService();

    if (_selectedDepartment == null ||
        _selectedDivision == null ||
        _selectedTank == null ||
        _weekStartController.text.isEmpty ||
        _weekEndController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Alert'),
            content: const Text(
                'Make sure that you have selected Department, Division, Tank, Week Start and Week End'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      try {
        Map<String, dynamic> responseData =
            await broodstockMortalityService.fetchMortalities(
                departmentId: _selectedDepartment!.id,
                divisionId: _selectedDivision!.id,
                tankId: _selectedTank!.id,
                dateFrom: _weekStartController.text,
                dateTo: _weekEndController.text) as Map<String, dynamic>;

        if (responseData['total_male_prawn_count'] == null ||
            responseData['total_female_prawn_count'] == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Validation Alert'),
                content: const Text(
                    'No Mortality reported at this time. Therefore setting the Mortality Count to 0'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          setState(() {
            _malePrawnMortalityCountController.text = 0.toString();
            _femalePrawnMortalityCountController.text = 0.toString();
          });
        } else {
          setState(() {
            _malePrawnMortalityCountController.text =
                responseData['total_male_prawn_count'].toString();
            _femalePrawnMortalityCountController.text =
                responseData['total_female_prawn_count'].toString();
          });
        }
      } catch (e) {
        print(e);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
            );
          },
        );
      }
    }
  }

  //Submit
  void _submitForm() async {
    TopupService topupService = TopupService();

    if (_formKey.currentState!.validate()) {
      String date = _dateController.text;
      String employee_code = _userId.toString();
      int department_id = _selectedDepartment!.id;
      int? division_id = _selectedDivision!.id;
      int? tank_id = _selectedTank!.id;
      String week_start = _weekStartController.text;
      String week_end = _weekEndController.text;
      String male_prawn_mortality_count =
          _malePrawnMortalityCountController.text;
      String female_prawn_mortality_count =
          _femalePrawnMortalityCountController.text;
      String male_prawn_topup_count = _malePrawnTopupCountController.text;
      String female_prawn_topup_count = _femalePrawnTopupCountController.text;
      String? note = _notesController.text;

      Map<String, dynamic> requestData = {
        'date': date,
        'employee_code': employee_code,
        'department_id': department_id,
        'division_id': division_id,
        'tank_id': tank_id,
        'week_start': week_start,
        'week_end': week_end,
        'male_prawn_mortality_count': male_prawn_mortality_count,
        'female_prawn_mortality_count': female_prawn_mortality_count,
        'male_prawn_topup_count': male_prawn_topup_count,
        'female_prawn_topup_count': female_prawn_topup_count,
        'notes': note
      };

      try {
        var responce = await topupService.createTopup(requestData);

        if (responce.statusCode == 201) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text('Success'),
                content: Text('Topup submitted successfully'),
              );
            },
          );

          _clearForm();
        } else
          throw 'Failed to create topup';
      } catch (e) {
        print('Error in Screen Code : $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
            );
          },
        );
      }
    }
  }

  //Update Topup
  void _updateTopup() async {
    int id = widget.topupUpdateData['id'];
    String date = _dateController.text;
    String employee_code = _userId!;
    int department_id = _selectedDepartment!.id;
    int? division_id = _selectedDivision!.id;
    int? tank_id = _selectedTank!.id;
    String week_start = _weekStartController.text;
    String week_end = _weekEndController.text;
    String male_prawn_mortality_count = _malePrawnMortalityCountController.text;
    String female_prawn_mortality_count =
        _femalePrawnMortalityCountController.text;
    String male_prawn_topup_count = _malePrawnTopupCountController.text;
    String female_prawn_topup_count = _femalePrawnTopupCountController.text;
    String? notes = _notesController.text;

    Map<String, dynamic> requestData = {
      'date': date,
      'employee_code': employee_code,
      'department_id': department_id,
      'division_id': division_id,
      'tank_id': tank_id,
      'week_start': week_start,
      'week_end': week_end,
      'male_prawn_mortality_count': male_prawn_mortality_count,
      'female_prawn_mortality_count': female_prawn_mortality_count,
      'male_prawn_topup_count': male_prawn_topup_count,
      'female_prawn_topup_count': female_prawn_topup_count,
      'notes': notes
    };

    try {
      TopupService topupService = TopupService();

      var responce = await topupService.updateTopup(id, requestData);
      if (responce.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Updated'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Topup updated successfully'),
                )
              ],
            );
          },
        );
        setState(() {
          isEditing = false;
        });
        _clearForm();
      } else
        throw 'Failed to update topup';
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

  //cancel Update
  void _cancelUpdate() {
    setState(() {
      isEditing = false;
    });

    _clearForm();
  }

  //clear form
  void _clearForm() {
    setState(() {
      _dateController.clear();
      _selectedDepartment = null;
      _selectedDivision = null;
      _selectedTank = null;
      _weekStartController.clear();
      _weekEndController.clear();
      _malePrawnMortalityCountController.clear();
      _femalePrawnMortalityCountController.clear();
      _malePrawnTopupCountController.clear();
      _femalePrawnTopupCountController.clear();
      _notesController.clear();
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
                  _updateTopup();
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
          'Activity/Topup',
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

              //View Collection Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isEditing
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
                                "Add New Topup",
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
                                  return TopupView();
                                },
                              ),
                            );
                          },
                          child: const Wrap(
                            children: [
                              Text(
                                "View Topup Details",
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

              //Week Start Date
              TextFormField(
                controller: _weekStartController,
                readOnly: true,
                onTap: () => _selectDate(context, _weekStartController),
                decoration: const InputDecoration(
                    labelText: 'Week Start Date',
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

              //Week End Date
              TextFormField(
                controller: _weekEndController,
                readOnly: true,
                onTap: () => _selectDate(context, _weekEndController),
                decoration: const InputDecoration(
                    labelText: 'Week End Date',
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

              //Find Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: () {
                      _findMortalityCount();
                    },
                    child: Text('Find', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Mortality count container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Mortality Count:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              controller: _malePrawnMortalityCountController,
                              decoration: const InputDecoration(
                                labelText: 'Male Prawn Count',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              controller: _femalePrawnMortalityCountController,
                              decoration: const InputDecoration(
                                labelText: 'Female Prawn Count',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              //Topup Container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Topup Count:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _femalePrawnTopupCountController,
                            decoration: const InputDecoration(
                              labelText: 'Female Prawm Count',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _malePrawnTopupCountController,
                            decoration: const InputDecoration(
                              labelText: 'Male Prawn Count',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        )
                      ])
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              //notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //Update Button
              isEditing
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
                              _showConfirmationDialog(purpose: "Update");
                            },
                            child: Text(
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
              //User Id
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

              //View Collection Button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  isEditing
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          onPressed: _cancelUpdate,
                          child: Wrap(
                            children: [
                              Text(
                                "Add New Topup",
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
                                  return TopupView();
                                },
                              ),
                            );
                          },
                          child: Wrap(
                            children: [
                              Text(
                                "View Topup",
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
              Row(children: [
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
                )
              ]),
              SizedBox(height: 10),

              //Divison and Tank Row
              Row(children: [
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
              ]),
              SizedBox(height: 10),

              //Week Start and End Row
              Row(
                children: [
                  //Week Start Date
                  Expanded(
                    child: TextFormField(
                      controller: _weekStartController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _weekStartController),
                      decoration: const InputDecoration(
                          labelText: 'Week Start Date',
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

                  //Week End Date
                  Expanded(
                    child: TextFormField(
                      controller: _weekEndController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _weekEndController),
                      decoration: const InputDecoration(
                          labelText: 'Week End Date',
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
                ],
              ),
              SizedBox(height: 10),

              //Find Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: () {
                      _findMortalityCount();
                    },
                    child: Text('Find', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Mortality count container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Mortality Count:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              controller: _malePrawnMortalityCountController,
                              decoration: const InputDecoration(
                                labelText: 'Male Prawn Count',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              controller: _femalePrawnMortalityCountController,
                              decoration: const InputDecoration(
                                labelText: 'Female Prawn Count',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              //Topup Container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Topup Count:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _femalePrawnTopupCountController,
                            decoration: const InputDecoration(
                              labelText: 'Female Prawm Count',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _malePrawnTopupCountController,
                            decoration: const InputDecoration(
                              labelText: 'Male Prawn Count',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        )
                      ])
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              //notes
              TextFormField(
                controller: _notesController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //Update Button
              isEditing
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
            ],
          ),
        ),
      ),
    );
  }
}
