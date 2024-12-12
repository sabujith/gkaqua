import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/screens/activities/LarvaeCollectionViewScreen.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/division_services.dart';
import 'package:gk_aqua/services/larvaeCollection_services.dart';
import 'package:gk_aqua/services/tank_services.dart';

class LarvaeCollection extends StatelessWidget {
  const LarvaeCollection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LarvaeCollectionActivityScreen(),
    );
  }
}

class LarvaeCollectionActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? larvaeData;
  final bool isEditing;

  const LarvaeCollectionActivityScreen(
      {super.key, this.larvaeData, this.isEditing = false});

  @override
  State<LarvaeCollectionActivityScreen> createState() =>
      _LarvaeCollectionActivityScreenState();
}

class _LarvaeCollectionActivityScreenState
    extends State<LarvaeCollectionActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  final TextEditingController _dateController = TextEditingController();
  Department? _selectedHatching1Department;
  DivisionModel? _selectedHatching1Division;
  TankModel? _selectedHatching1Tank;
  final TextEditingController _hatching1BatchController =
      TextEditingController();
  final TextEditingController _hatching1LarvaeCount = TextEditingController();

  Department? _selectedHatching2Department;
  DivisionModel? _selectedHatching2Division;
  TankModel? _selectedHatching2Tank;
  final TextEditingController _hatching2BatchController =
      TextEditingController();
  final TextEditingController _hatching2LarvaeCount = TextEditingController();

  Department? _selectedTargetDepartment;
  DivisionModel? _selectedTargetDivision;
  TankModel? _selectedTargetTank;
  final TextEditingController _targetBatchController = TextEditingController();
  final TextEditingController _targetLarvaeCount = TextEditingController();

  final TextEditingController _countController = TextEditingController();
  final TextEditingController _countMuliplierController =
      TextEditingController();
  final TextEditingController _totalCountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Department> hatching1Departments = [];
  List<Department> hatching2Departments = [];
  List<Department> targetDepartments = [];

  List<DivisionModel> hatching1Divisions = [];
  List<DivisionModel> hatching2Divisions = [];
  List<DivisionModel> targetDivisions = [];

  List<TankModel> hatching1Tanks = [];
  List<TankModel> hatching2Tanks = [];
  List<TankModel> targetTanks = [];

  bool _isLoading = false;
  bool isEditing = false;

  initState() {
    super.initState();
    _getUserDetails();
    _fetchData();
    // Add listeners to the text fields to calculate the total count on input change
    _countController.addListener(_calculateTotalCount);
    _countMuliplierController.addListener(_calculateTotalCount);

    _hatching1LarvaeCount.addListener(_calculateTargetCount);
    _hatching2LarvaeCount.addListener(_calculateTargetCount);
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await _getUserDetails();
    await _getDepartments();
    await _getDivisions();
    await _getTanks();
    await _initializeData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      if (widget.isEditing && widget.larvaeData != null) {
        isEditing = true;
        _dateController.text = widget.larvaeData!['date'];
        _selectedHatching1Department =
            hatching1Departments.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['hatching1_department_id']) {
            return element;
          }
          return previousValue;
        });
        _selectedHatching1Division =
            hatching1Divisions.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['hatching1_division_id']) {
            return element;
          }
          return previousValue;
        });
        _selectedHatching1Tank =
            hatching1Tanks.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['hatching1_tank_id']) {
            return element;
          }
          return previousValue;
        });
        _hatching1BatchController.text = widget.larvaeData!['hatching1_batch'];
        _selectedHatching2Department =
            hatching2Departments.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['hatching2_department_id']) {
            return element;
          }
          return previousValue;
        });
        _selectedHatching2Division =
            hatching2Divisions.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['hatching2_division_id']) {
            return element;
          }
          return previousValue;
        });
        _selectedHatching2Tank =
            hatching2Tanks.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['hatching2_tank_id']) {
            return element;
          }
          return previousValue;
        });
        _hatching2BatchController.text = widget.larvaeData!['hatching2_batch'];
        _selectedTargetDepartment =
            targetDepartments.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['target_department_id']) {
            return element;
          }
          return previousValue;
        });
        _selectedTargetDivision =
            targetDivisions.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['target_division_id']) {
            return element;
          }
          return previousValue;
        });
        _selectedTargetTank = targetTanks.fold(null, (previousValue, element) {
          if (element.id == widget.larvaeData!['target_tank_id']) {
            return element;
          }
          return previousValue;
        });
        _targetBatchController.text = widget.larvaeData!['target_batch'];
        _countController.text = widget.larvaeData!['count'].toString();
        _countMuliplierController.text =
            widget.larvaeData!['count_multiplier'].toString();
        _totalCountController.text =
            widget.larvaeData!['total_count'].toString();
        _noteController.text = widget.larvaeData!['notes'] ?? '';
      } else {
        isEditing = false;
      }
    });
  }

  //Get user Details
  Future<void> _getUserDetails() async {
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
        hatching1Departments = List.from(fetchedDepartments);
        ;
        hatching2Departments = List.from(fetchedDepartments);
        ;
        targetDepartments = List.from(fetchedDepartments);
        ;
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
  Future<void> _getDivisions({int? departmentId, String? divName}) async {
    DivisionServices divisionServices = DivisionServices();
    try {
      if (departmentId == null && divName == null) {
        // Fetch all divisions when no department ID or divisions list is provided
        List<DivisionModel> fetchedDivisions =
            await divisionServices.fetchDivisions();
        setState(() {
          hatching1Divisions = fetchedDivisions;
          hatching2Divisions = fetchedDivisions;
          targetDivisions = fetchedDivisions;
        });
      } else if (departmentId != null) {
        // Fetch divisions by department ID
        List<DivisionModel> fetchedDivision = await divisionServices
            .fetchDivisionsByDepartmentId(id: departmentId);
        setState(() {
          if (divName == "div1") {
            hatching1Divisions = fetchedDivision;
          } else if (divName == "div2") {
            hatching2Divisions = fetchedDivision;
          } else if (divName == "target") {
            targetDivisions = fetchedDivision;
          }
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
          });
    }
    departmentId = null;
    divName = null;
  }

  // Get tanks
  Future<void> _getTanks({int? divisionId, String? tankName}) async {
    TankService tankServices = TankService();
    try {
      if (divisionId == null && tankName == null) {
        // Fetch all tanks when no division ID or tanks list is provided
        List<TankModel> fetchedTanks = await tankServices.fetchTanks();
        setState(() {
          hatching1Tanks = fetchedTanks;
          hatching2Tanks = fetchedTanks;
          targetTanks = fetchedTanks;
        });
      } else if (divisionId != null) {
        // Fetch tanks by division ID
        List<TankModel> fetchedTanks =
            await tankServices.fetchTanksByDivisionId(id: divisionId);
        setState(() {
          if (tankName == "tank1") {
            hatching1Tanks = fetchedTanks;
          } else if (tankName == "tank2") {
            hatching2Tanks = fetchedTanks;
          } else if (tankName == "target") {
            targetTanks = fetchedTanks;
          }
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
                  child: Text('Error in fetching tanks: $e'),
                ),
              ],
            );
          });
    }
    divisionId = null;
    tankName = null;
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
    int larvaeCount = int.tryParse(_countController.text) ?? 0;
    int countMultiplier = int.tryParse(_countMuliplierController.text) ?? 1;
    int totalCount = larvaeCount * countMultiplier;

    setState(() {
      _totalCountController.text = totalCount.toString();
    });
  }

  // Function to add Tank 1 count and Tank 2 count to get Target count
  void _calculateTargetCount() {
    int tank1Count = int.tryParse(_hatching1LarvaeCount.text) ?? 0;
    int tank2Count = int.tryParse(_hatching2LarvaeCount.text) ?? 0;
    int targetCount = tank1Count + tank2Count;

    setState(() {
      _targetLarvaeCount.text = targetCount.toString();
      _countController.text = targetCount.toString();
    });
  }

  //Submit form
  Future<void> _submitForm() async {
    LarvaeCollectionService larvaeCollectionService = LarvaeCollectionService();

    if (_formKey.currentState!.validate()) {
      //converting three count into int
      int larvaCount = int.parse(_countController.text) ?? 0;
      int countMultiplier = int.parse(_countMuliplierController.text) ?? 0;
      int totalCount = int.parse(_totalCountController.text) ?? 0;

      String? employee_code = _userId;
      String? date = _dateController.text;

      int? hatching1_department_id = _selectedHatching1Department!.id;
      int? hatching1_division_id = _selectedHatching1Division!.id;
      int? hatching1_tank_id = _selectedHatching1Tank!.id;
      String? hatching1_batch_id = _hatching1BatchController.text;

      int? hatching2_department_id = _selectedHatching2Department!.id;
      int? hatching2_division_id = _selectedHatching2Division!.id;
      int? hatching2_tank_id = _selectedHatching2Tank!.id;
      String? hatching2_batch_id = _hatching2BatchController.text;

      int? target_department_id = _selectedTargetDepartment!.id;
      int? target_division_id = _selectedTargetDivision!.id;
      int? target_tank_id = _selectedTargetTank!.id;
      String? target_batch_id = _targetBatchController.text;

      int? count = larvaCount;
      int? count_multiplier = countMultiplier;
      int? total_count = totalCount;
      String? notes = _noteController.text;

      Map<String, dynamic> requestData = {
        'employee_code': employee_code,
        'date': date,
        'hatching1_department_id': hatching1_department_id,
        'hatching1_division_id': hatching1_division_id,
        'hatching1_tank_id': hatching1_tank_id,
        'hatching1_batch': hatching1_batch_id,
        'hatching2_department_id': hatching2_department_id,
        'hatching2_division_id': hatching2_division_id,
        'hatching2_tank_id': hatching2_tank_id,
        'hatching2_batch': hatching2_batch_id,
        'target_department_id': target_department_id,
        'target_division_id': target_division_id,
        'target_tank_id': target_tank_id,
        'target_batch': target_batch_id,
        'count': count,
        'count_multiplier': count_multiplier,
        'total_count': total_count,
        'notes': notes,
      };

      try {
        var response =
            await larvaeCollectionService.createLarvaeCollection(requestData);

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Larvae Collection added successfully!'),
            ),
          );

          _clearForm();
        } else {
          throw 'Failed to add larvae collection.';
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
                  child: Text('Error in adding larvae collection: $e'),
                ),
              ],
            );
          },
        );
      }
    }
  }

//confirmation dialog
  void _showConfirmationDialog({required String purpose, int? index}) {
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
                  _updateLarvaeCollection();
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

  //update
  void _updateLarvaeCollection() async {
    int? id = widget.larvaeData!['id'];
    String? date = _dateController.text;
    String? employee_code = _userId;
    int? hatching1Departments = _selectedHatching1Department!.id;
    int? hatching1Divisions = _selectedHatching1Division!.id;
    int? hatching1Tanks = _selectedHatching1Tank!.id;
    String? hatching1Batch = _hatching1BatchController.text;
    int? hatching2Departments = _selectedHatching2Department!.id;
    int? hatching2Divisions = _selectedHatching2Division!.id;
    int? hatching2Tanks = _selectedHatching2Tank!.id;
    String? hatching2Batch = _hatching2BatchController.text;
    int? targetDepartments = _selectedTargetDepartment!.id;
    int? targetDivisions = _selectedTargetDivision!.id;
    int? targetTanks = _selectedTargetTank!.id;
    String? targetBatch = _targetBatchController.text;
    int? count = int.parse(_countController.text);
    int? countMultiplier = int.parse(_countMuliplierController.text);
    int? totalCount = int.parse(_totalCountController.text);
    String? notes = _noteController.text;

    Map<String, dynamic> requestData = {
      'id': id,
      'employee_code': employee_code,
      'date': date,
      'hatching1_department_id': hatching1Departments,
      'hatching1_division_id': hatching1Divisions,
      'hatching1_tank_id': hatching1Tanks,
      'hatching1_batch': hatching1Batch,
      'hatching2_department_id': hatching2Departments,
      'hatching2_division_id': hatching2Divisions,
      'hatching2_tank_id': hatching2Tanks,
      'hatching2_batch': hatching2Batch,
      'target_department_id': targetDepartments,
      'target_division_id': targetDivisions,
      'target_tank_id': targetTanks,
      'target_batch': targetBatch,
      'count': count,
      'count_multiplier': countMultiplier,
      'total_count': totalCount,
      'notes': notes,
    };

    try {
      var response = await LarvaeCollectionService()
          .updateLarvaeCollectionTank(requestData, id!);

      if (response.statusCode == 200) {
        setState(() {
          isEditing = false;
        });
        _clearForm();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Larvae Collection updated successfully!'),
          ),
        );
      } else {
        throw 'Failed to update larvae collection.';
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
                child: Text('Error in updating larvae collection: $e'),
              ),
            ],
          );
        },
      );
    }
  }

  //cancel update
  void _cancelUpdate() {
    setState(() {
      isEditing = false;
    });
    _clearForm();
  }

  //clear form
  void _clearForm() {
    _dateController.clear();
    _selectedHatching1Department = null;
    _selectedHatching1Division = null;
    _selectedHatching1Tank = null;
    _hatching1BatchController.clear();
    _selectedHatching2Department = null;
    _selectedHatching2Division = null;
    _selectedHatching2Tank = null;
    _hatching2BatchController.clear();
    _selectedTargetDepartment = null;
    _selectedTargetDivision = null;
    _selectedTargetTank = null;
    _targetBatchController.clear();
    _countController.clear();
    _countMuliplierController.clear();
    _totalCountController.clear();
    _noteController.clear();
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
          'Activity/Larvae Collection',
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
              if (constraints.maxWidth > 1200) {
                return _desktopView();
              } else if (constraints.maxWidth > 600) {
                return _tabletView();
              } else {
                return _mobileView();
              }
            }),
    );
  }

  Widget _desktopView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //user id Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('User Id: $_userId',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(height: 10),

              //Navigation Button
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
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                            });
                            _clearForm();
                          },
                          child: const Wrap(
                            children: [
                              Text(
                                "Add Larvae Collection",
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
                                  return LarvaeCollectionView();
                                },
                              ),
                            );
                          },
                          child: const Wrap(
                            children: [
                              Text(
                                "View Larvae Collection Details",
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
              SizedBox(height: 10),

              //Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter date';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateController),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: SizedBox(width: 10),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              //Hatching 1, Hatching 2 and Target Row
              Row(
                children: [
                  //Hatching 1 Details container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Hatching Tank 1 Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          //Department 1 Dropdown
                          DropdownButtonFormField<Department>(
                            value: _selectedHatching1Department,
                            onChanged: (Department? newValue) {
                              setState(() {
                                _selectedHatching1Department = newValue;
                                _selectedHatching1Division = null;
                                _selectedHatching1Tank = null;
                              });
                              _getDivisions(
                                  departmentId: newValue?.id, divName: "div1");
                            },
                            items: hatching1Departments
                                .map<DropdownMenuItem<Department>>(
                                    (Department department) {
                              return DropdownMenuItem<Department>(
                                value: department,
                                child: Text(department.departmentName),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Hatching 1 Department',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a department';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          //Division 1 Dropdown
                          DropdownButtonFormField<DivisionModel>(
                            value: hatching1Divisions
                                    .contains(_selectedHatching1Department)
                                ? _selectedHatching1Division
                                : null,
                            onChanged: (DivisionModel? newValue) {
                              setState(() {
                                _selectedHatching1Division = newValue;
                                _selectedHatching1Tank = null;
                                _getTanks(
                                    divisionId: newValue?.id,
                                    tankName: "tank1");
                              });
                            },
                            items: hatching1Divisions
                                .map<DropdownMenuItem<DivisionModel>>(
                                    (DivisionModel division) {
                              return DropdownMenuItem<DivisionModel>(
                                value: division,
                                child: Text(division.division_name),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Hatching 1 Division',
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

                          //Tank 1 Dropdown
                          DropdownButtonFormField<TankModel>(
                            value: hatching1Tanks
                                    .contains(_selectedHatching1Division)
                                ? _selectedHatching1Tank
                                : null,
                            onChanged: (TankModel? newValue) {
                              setState(() {
                                _selectedHatching1Tank = newValue;
                              });
                            },
                            items: hatching1Tanks
                                .map<DropdownMenuItem<TankModel>>(
                                    (TankModel tank) {
                              return DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_name ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a tank';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Hatching 1 Tank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Hatching 1 Batch
                          TextFormField(
                            controller: _hatching1BatchController,
                            decoration: const InputDecoration(
                              labelText: 'Hatching 1 Batch',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a batch';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          //Larvae 1 Quantity
                          TextFormField(
                            controller: _hatching1LarvaeCount,
                            decoration: const InputDecoration(
                              labelText: 'Tank 1 Larvae Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  //Hatching 2 Details container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Hatching Tank 2 Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          //Department 2 Dropdown
                          DropdownButtonFormField<Department>(
                            value: _selectedHatching2Department,
                            onChanged: (Department? newValue) {
                              setState(() {
                                _selectedHatching2Department = newValue;
                                _selectedHatching2Division = null;
                                _getDivisions(
                                    departmentId: newValue?.id,
                                    divName: "div2");
                              });
                            },
                            items: hatching2Departments
                                .map<DropdownMenuItem<Department>>(
                                    (Department department) {
                              return DropdownMenuItem<Department>(
                                value: department,
                                child: Text(department.departmentName),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a department';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Hatching 2 Department',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Division 2 Dropdown
                          DropdownButtonFormField<DivisionModel>(
                            value: hatching2Divisions
                                    .contains(_selectedHatching2Division)
                                ? _selectedHatching2Division
                                : null,
                            onChanged: (DivisionModel? newValue) {
                              setState(() {
                                _selectedHatching2Division = newValue;
                                _selectedHatching2Tank = null;
                                _getTanks(
                                    divisionId: newValue?.id,
                                    tankName: "tank2");
                              });
                            },
                            items: hatching2Divisions
                                .map<DropdownMenuItem<DivisionModel>>(
                                    (DivisionModel division) {
                              return DropdownMenuItem<DivisionModel>(
                                value: division,
                                child: Text(division.division_name),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a division';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Hatching 2 Division',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Tank 2 Dropdown
                          DropdownButtonFormField<TankModel>(
                            value:
                                hatching2Tanks.contains(_selectedHatching2Tank)
                                    ? _selectedHatching2Tank
                                    : null,
                            onChanged: (TankModel? newValue) {
                              setState(() {
                                _selectedHatching2Tank = newValue;
                              });
                            },
                            items: hatching2Tanks
                                .map<DropdownMenuItem<TankModel>>(
                                    (TankModel tank) {
                              return DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_name ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a tank';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Hatching 2 Tank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Hatching 2 Batch
                          TextFormField(
                            controller: _hatching2BatchController,
                            decoration: const InputDecoration(
                              labelText: 'Hatching 2 Batch',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a batch';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          //Larvae 1 Quantity
                          TextFormField(
                            controller: _hatching2LarvaeCount,
                            decoration: const InputDecoration(
                              labelText: 'Tank 2 Larvae Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  //Target Details container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Target Tank Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          //Target Department Dropdown
                          DropdownButtonFormField<Department>(
                            value: _selectedTargetDepartment,
                            onChanged: (Department? newValue) {
                              setState(() {
                                _selectedTargetDepartment = newValue;
                                _selectedTargetDivision = null;
                                _getDivisions(
                                    departmentId: newValue?.id,
                                    divName: "target");
                              });
                            },
                            items: targetDepartments
                                .map<DropdownMenuItem<Department>>(
                                    (Department department) {
                              return DropdownMenuItem<Department>(
                                value: department,
                                child: Text(department.departmentName),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a department';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Target Department',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Target Division Dropdown
                          DropdownButtonFormField<DivisionModel>(
                            value: targetDivisions
                                    .contains(_selectedTargetDivision)
                                ? _selectedTargetDivision
                                : null,
                            onChanged: (DivisionModel? newValue) {
                              setState(() {
                                _selectedTargetDivision = newValue;
                                _selectedTargetTank = null;
                                _getTanks(
                                    divisionId: newValue?.id,
                                    tankName: "target");
                              });
                            },
                            items: targetDivisions
                                .map<DropdownMenuItem<DivisionModel>>(
                                    (DivisionModel division) {
                              return DropdownMenuItem<DivisionModel>(
                                value: division,
                                child: Text(division.division_name),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a division';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Target Division',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Target Tank Dropdown
                          DropdownButtonFormField<TankModel>(
                            value: targetTanks.contains(_selectedTargetTank)
                                ? _selectedTargetTank
                                : null,
                            onChanged: (TankModel? newValue) {
                              setState(() {
                                _selectedTargetTank = newValue;
                              });
                            },
                            items: targetTanks.map<DropdownMenuItem<TankModel>>(
                                (TankModel tank) {
                              return DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_name ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a tank';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Target Tank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          //Target Batch
                          TextFormField(
                            controller: _targetBatchController,
                            decoration: const InputDecoration(
                              labelText: 'Target Batch',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a batch';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Target Tank Larvae
                          TextFormField(
                            readOnly: true,
                            controller: _targetLarvaeCount,
                            decoration: const InputDecoration(
                              labelText: 'Total Larvae Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Larvae Count, Count Multiplier and Total count Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: // Larva Count
                        TextFormField(
                      readOnly: true,
                      controller: _countController,
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
                      controller: _countMuliplierController,
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
                          border: OutlineInputBorder(),
                          labelText: 'Total Count'),
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
              const Row(
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
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //submit button
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
                            minimumSize: const Size(200, 50),
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
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabletView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //user id Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('User Id: $_userId',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(height: 10),

              //Date
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter date';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateController),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: const SizedBox(width: 10),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              //Hatching 1 Details container
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Hatching Tank 1 Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    //Department 1 and Division 1 Row
                    Row(children: [
                      //Department 1 Dropdown
                      Expanded(
                        child: DropdownButtonFormField<Department>(
                          value: _selectedHatching1Department,
                          onChanged: (Department? newValue) {
                            setState(() {
                              _selectedHatching1Department = newValue;
                              _selectedHatching1Division = null;
                              _selectedHatching1Tank = null;
                            });
                            _getDivisions(
                                departmentId: newValue?.id, divName: "div1");
                          },
                          items: hatching1Departments
                              .map<DropdownMenuItem<Department>>(
                                  (Department department) {
                            return DropdownMenuItem<Department>(
                              value: department,
                              child: Text(department.departmentName),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Hatching 1 Department',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a department';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      //Division 1 Dropdown
                      Expanded(
                        child: DropdownButtonFormField<DivisionModel>(
                          value: hatching1Divisions
                                  .contains(_selectedHatching1Department)
                              ? _selectedHatching1Division
                              : null,
                          onChanged: (DivisionModel? newValue) {
                            setState(() {
                              _selectedHatching1Division = newValue;
                              _selectedHatching1Tank = null;
                              _getTanks(
                                  divisionId: newValue?.id, tankName: "tank1");
                            });
                          },
                          items: hatching1Divisions
                              .map<DropdownMenuItem<DivisionModel>>(
                                  (DivisionModel division) {
                            return DropdownMenuItem<DivisionModel>(
                              value: division,
                              child: Text(division.division_name),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Hatching 1 Division',
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
                    ]),
                    const SizedBox(height: 10),

                    //Tank 1 and Batch 1 Row
                    Row(
                      children: [
                        //Tank 1 Dropdown
                        Expanded(
                          child: DropdownButtonFormField<TankModel>(
                            value: hatching1Tanks
                                    .contains(_selectedHatching1Division)
                                ? _selectedHatching1Tank
                                : null,
                            onChanged: (TankModel? newValue) {
                              setState(() {
                                _selectedHatching1Tank = newValue;
                              });
                            },
                            items: hatching1Tanks
                                .map<DropdownMenuItem<TankModel>>(
                                    (TankModel tank) {
                              return DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_name ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a tank';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Hatching 1 Tank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        //Hatching 1 Batch
                        Expanded(
                          child: TextFormField(
                            controller: _hatching1BatchController,
                            decoration: const InputDecoration(
                              labelText: 'Hatching 1 Batch',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a batch';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    //Larvae 1 Quantity
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hatching1LarvaeCount,
                            decoration: const InputDecoration(
                              labelText: 'Tank 1 Larvae Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              //Hatching 2 Details container
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Hatching Tank 2 Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    //Department 2 and Division 2 Row
                    Row(children: [
                      //Department 2 Dropdown
                      Expanded(
                        child: DropdownButtonFormField<Department>(
                          value: _selectedHatching2Department,
                          onChanged: (Department? newValue) {
                            setState(() {
                              _selectedHatching2Department = newValue;
                              _selectedHatching2Division = null;
                              _getDivisions(
                                  departmentId: newValue?.id, divName: "div2");
                            });
                          },
                          items: hatching2Departments
                              .map<DropdownMenuItem<Department>>(
                                  (Department department) {
                            return DropdownMenuItem<Department>(
                              value: department,
                              child: Text(department.departmentName),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a department';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Hatching 2 Department',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      //Division 2 Dropdown
                      Expanded(
                        child: DropdownButtonFormField<DivisionModel>(
                          value: hatching2Divisions
                                  .contains(_selectedHatching2Division)
                              ? _selectedHatching2Division
                              : null,
                          onChanged: (DivisionModel? newValue) {
                            setState(() {
                              _selectedHatching2Division = newValue;
                              _selectedHatching2Tank = null;
                              _getTanks(
                                  divisionId: newValue?.id, tankName: "tank2");
                            });
                          },
                          items: hatching2Divisions
                              .map<DropdownMenuItem<DivisionModel>>(
                                  (DivisionModel division) {
                            return DropdownMenuItem<DivisionModel>(
                              value: division,
                              child: Text(division.division_name),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a division';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Hatching 2 Division',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),

                    //Tank 2 and Batch 2 Row
                    Row(
                      children: [
                        //Tank 2 Dropdown
                        Expanded(
                          child: DropdownButtonFormField<TankModel>(
                            value:
                                hatching2Tanks.contains(_selectedHatching2Tank)
                                    ? _selectedHatching2Tank
                                    : null,
                            onChanged: (TankModel? newValue) {
                              setState(() {
                                _selectedHatching2Tank = newValue;
                              });
                            },
                            items: hatching2Tanks
                                .map<DropdownMenuItem<TankModel>>(
                                    (TankModel tank) {
                              return DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_name ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a tank';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Hatching 2 Tank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        //Hatching 2 Batch
                        Expanded(
                          child: TextFormField(
                            controller: _hatching2BatchController,
                            decoration: const InputDecoration(
                              labelText: 'Hatching 2 Batch',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a batch';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    //Larvae 2 Quantity
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hatching2LarvaeCount,
                            decoration: const InputDecoration(
                              labelText: 'Tank 2 Larvae Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),

              //Target Details container
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Target Tank Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    //Target Department and Target Division Row
                    Row(
                      children: [
                        //Target Department Dropdown
                        Expanded(
                          child: DropdownButtonFormField<Department>(
                            value: _selectedTargetDepartment,
                            onChanged: (Department? newValue) {
                              setState(() {
                                _selectedTargetDepartment = newValue;
                                _selectedTargetDivision = null;
                                _getDivisions(
                                    departmentId: newValue?.id,
                                    divName: "target");
                              });
                            },
                            items: targetDepartments
                                .map<DropdownMenuItem<Department>>(
                                    (Department department) {
                              return DropdownMenuItem<Department>(
                                value: department,
                                child: Text(department.departmentName),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a department';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Target Department',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        //Target Division Dropdown
                        Expanded(
                          child: DropdownButtonFormField<DivisionModel>(
                            value: targetDivisions
                                    .contains(_selectedTargetDivision)
                                ? _selectedTargetDivision
                                : null,
                            onChanged: (DivisionModel? newValue) {
                              setState(() {
                                _selectedTargetDivision = newValue;
                                _selectedTargetTank = null;
                                _getTanks(
                                    divisionId: newValue?.id,
                                    tankName: "target");
                              });
                            },
                            items: targetDivisions
                                .map<DropdownMenuItem<DivisionModel>>(
                                    (DivisionModel division) {
                              return DropdownMenuItem<DivisionModel>(
                                value: division,
                                child: Text(division.division_name),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a division';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Target Division',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    //Target Tank and Batch Row
                    Row(
                      children: [
                        //Target Tank Dropdown
                        Expanded(
                          child: DropdownButtonFormField<TankModel>(
                            value: targetTanks.contains(_selectedTargetTank)
                                ? _selectedTargetTank
                                : null,
                            onChanged: (TankModel? newValue) {
                              setState(() {
                                _selectedTargetTank = newValue;
                              });
                            },
                            items: targetTanks.map<DropdownMenuItem<TankModel>>(
                                (TankModel tank) {
                              return DropdownMenuItem<TankModel>(
                                value: tank,
                                child: Text(tank.tank_name ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a tank';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Target Tank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        //Target Batch
                        Expanded(
                          child: TextFormField(
                            controller: _targetBatchController,
                            decoration: const InputDecoration(
                              labelText: 'Target Batch',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a batch';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Target Tank Larvae
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _targetLarvaeCount,
                            decoration: const InputDecoration(
                              labelText: 'Total Larvae Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
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
              const SizedBox(height: 10),

              // Larvae Count, Count Multiplier and Total count Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: // Larva Count
                        TextFormField(
                      controller: _countController,
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
                      controller: _countMuliplierController,
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
                          border: OutlineInputBorder(),
                          labelText: 'Total Count'),
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
              const Row(
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
              SizedBox(height: 20),

              //notes
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //submit button
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //user id Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('User Id: $_userId',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(height: 10),

              //Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () => _selectDate(context, _dateController),
              ),
              const SizedBox(height: 20),

              //Hatching 1 Details container
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Hatching Tank 1 Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    //Department 1 Dropdown
                    DropdownButtonFormField<Department>(
                      value: _selectedHatching1Department,
                      onChanged: (Department? newValue) {
                        setState(() {
                          _selectedHatching1Department = newValue;
                          _selectedHatching1Division = null;
                          _selectedHatching1Tank = null;
                        });
                        _getDivisions(
                            departmentId: newValue?.id, divName: "div1");
                      },
                      items: hatching1Departments
                          .map<DropdownMenuItem<Department>>(
                              (Department department) {
                        return DropdownMenuItem<Department>(
                          value: department,
                          child: Text(department.departmentName),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Hatching 1 Department',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    //Division 1 Dropdown
                    DropdownButtonFormField<DivisionModel>(
                      value: hatching1Divisions
                              .contains(_selectedHatching1Department)
                          ? _selectedHatching1Division
                          : null,
                      onChanged: (DivisionModel? newValue) {
                        setState(() {
                          _selectedHatching1Division = newValue;
                          _selectedHatching1Tank = null;
                          _getTanks(
                              divisionId: newValue?.id, tankName: "tank1");
                        });
                      },
                      items: hatching1Divisions
                          .map<DropdownMenuItem<DivisionModel>>(
                              (DivisionModel division) {
                        return DropdownMenuItem<DivisionModel>(
                          value: division,
                          child: Text(division.division_name),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Hatching 1 Division',
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

                    //Tank 1 Dropdown
                    DropdownButtonFormField<TankModel>(
                      value: hatching1Tanks.contains(_selectedHatching1Division)
                          ? _selectedHatching1Tank
                          : null,
                      onChanged: (TankModel? newValue) {
                        setState(() {
                          _selectedHatching1Tank = newValue;
                        });
                      },
                      items: hatching1Tanks
                          .map<DropdownMenuItem<TankModel>>((TankModel tank) {
                        return DropdownMenuItem<TankModel>(
                          value: tank,
                          child: Text(tank.tank_name ?? ''),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a tank';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Hatching 1 Tank',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Hatching 1 Batch
                    TextFormField(
                      controller: _hatching1BatchController,
                      decoration: const InputDecoration(
                        labelText: 'Hatching 1 Batch',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a batch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    //Larvae 1 Quantity
                    TextFormField(
                      controller: _hatching1LarvaeCount,
                      decoration: const InputDecoration(
                        labelText: 'Tank 1 Larvae Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              //Hatching 2 Details container
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Hatching Tank 2 Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    //Department 2 Dropdown
                    DropdownButtonFormField<Department>(
                      value: _selectedHatching2Department,
                      onChanged: (Department? newValue) {
                        setState(() {
                          _selectedHatching2Department = newValue;
                          _selectedHatching2Division = null;
                          _getDivisions(
                              departmentId: newValue?.id, divName: "div2");
                        });
                      },
                      items: hatching2Departments
                          .map<DropdownMenuItem<Department>>(
                              (Department department) {
                        return DropdownMenuItem<Department>(
                          value: department,
                          child: Text(department.departmentName),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Hatching 2 Department',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Division 2 Dropdown
                    DropdownButtonFormField<DivisionModel>(
                      value: hatching2Divisions
                              .contains(_selectedHatching2Division)
                          ? _selectedHatching2Division
                          : null,
                      onChanged: (DivisionModel? newValue) {
                        setState(() {
                          _selectedHatching2Division = newValue;
                          _selectedHatching2Tank = null;
                          _getTanks(
                              divisionId: newValue?.id, tankName: "tank2");
                        });
                      },
                      items: hatching2Divisions
                          .map<DropdownMenuItem<DivisionModel>>(
                              (DivisionModel division) {
                        return DropdownMenuItem<DivisionModel>(
                          value: division,
                          child: Text(division.division_name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a division';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Hatching 2 Division',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Tank 2 Dropdown
                    DropdownButtonFormField<TankModel>(
                      value: hatching2Tanks.contains(_selectedHatching2Tank)
                          ? _selectedHatching2Tank
                          : null,
                      onChanged: (TankModel? newValue) {
                        setState(() {
                          _selectedHatching2Tank = newValue;
                        });
                      },
                      items: hatching2Tanks
                          .map<DropdownMenuItem<TankModel>>((TankModel tank) {
                        return DropdownMenuItem<TankModel>(
                          value: tank,
                          child: Text(tank.tank_name ?? ''),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a tank';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Hatching 2 Tank',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Hatching 2 Batch
                    TextFormField(
                      controller: _hatching2BatchController,
                      decoration: const InputDecoration(
                        labelText: 'Hatching 2 Batch',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a batch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    //Larvae 2 Quantity
                    TextFormField(
                      controller: _hatching2LarvaeCount,
                      decoration: const InputDecoration(
                        labelText: 'Tank 2 Larvae Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              //Target Details container
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Target Tank Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    //Target Department Dropdown
                    DropdownButtonFormField<Department>(
                      value: _selectedTargetDepartment,
                      onChanged: (Department? newValue) {
                        setState(() {
                          _selectedTargetDepartment = newValue;
                          _selectedTargetDivision = null;
                          _getDivisions(
                              departmentId: newValue?.id, divName: "target");
                        });
                      },
                      items: targetDepartments
                          .map<DropdownMenuItem<Department>>(
                              (Department department) {
                        return DropdownMenuItem<Department>(
                          value: department,
                          child: Text(department.departmentName),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Target Department',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Target Division Dropdown
                    DropdownButtonFormField<DivisionModel>(
                      value: targetDivisions.contains(_selectedTargetDivision)
                          ? _selectedTargetDivision
                          : null,
                      onChanged: (DivisionModel? newValue) {
                        setState(() {
                          _selectedTargetDivision = newValue;
                          _selectedTargetTank = null;
                          _getTanks(
                              divisionId: newValue?.id, tankName: "target");
                        });
                      },
                      items: targetDivisions
                          .map<DropdownMenuItem<DivisionModel>>(
                              (DivisionModel division) {
                        return DropdownMenuItem<DivisionModel>(
                          value: division,
                          child: Text(division.division_name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a division';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Target Division',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Target Tank Dropdown
                    DropdownButtonFormField<TankModel>(
                      value: targetTanks.contains(_selectedTargetTank)
                          ? _selectedTargetTank
                          : null,
                      onChanged: (TankModel? newValue) {
                        setState(() {
                          _selectedTargetTank = newValue;
                        });
                      },
                      items: targetTanks
                          .map<DropdownMenuItem<TankModel>>((TankModel tank) {
                        return DropdownMenuItem<TankModel>(
                          value: tank,
                          child: Text(tank.tank_name ?? ''),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a tank';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Target Tank',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Target Batch
                    TextFormField(
                      controller: _targetBatchController,
                      decoration: const InputDecoration(
                        labelText: 'Target Batch',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a batch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Target Tank Larvae
                    TextFormField(
                      readOnly: true,
                      controller: _targetLarvaeCount,
                      decoration: const InputDecoration(
                        labelText: 'Total Larvae Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Larvae Count and Count Multiplier
              Row(
                children: [
                  // Larva Count
                  Expanded(
                    child: TextFormField(
                      controller: _countController,
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
                  // Count Multiplier
                  Expanded(
                    child: TextFormField(
                      controller: _countMuliplierController,
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
              const Row(
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
              SizedBox(height: 20),

              //notes
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              //submit button
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
