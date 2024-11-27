import 'package:flutter/material.dart';
import 'package:gk_aqua/models/unit_model.dart';
import 'package:gk_aqua/services/unit_services.dart';

class Unitpage extends StatelessWidget {
  const Unitpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const unitMasterScreen(),
    );
  }
}

class unitMasterScreen extends StatefulWidget {
  const unitMasterScreen({super.key});

  @override
  State<unitMasterScreen> createState() => _unitMasterScreenState();
}

class _unitMasterScreenState extends State<unitMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  final _unitController = TextEditingController();
  final _unitCodeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _noteController = TextEditingController();
  final _endDateController = TextEditingController();
  final searchController = TextEditingController();
  final _isadmin = false;
  bool _isEditing = false;
  bool _isLoading = false;

  UnitModel? selectedUnit;

  Map<String, String>? editingUnit;
  List<UnitModel> unitList = [];
  List<UnitModel> filteredUnits = [];

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
    await _fetchUnits();
    await _getUserDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserDetails() async {
    // final userId = await getUserId();
    setState(() {
      _userId = "User 123";
      filteredUnits = unitList;
      searchController.addListener(_onSearchChanged);
    });
  }

  void _onSearchChanged() {
    _filteredUnits(searchController.text);
  }

  void _filteredUnits(String query) {
    final filtered = unitList.where((unit) {
      // print(
      //     'unit Name: ${unit.unit_name}, Unit Code: ${unit.unit_code}, Notes: ${unit.notes}, Start Date: ${unit.start_date}, End Date: ${unit.end_date}');
      return unit.unit_name.toLowerCase().contains(query.toLowerCase()) ||
          unit.unit_code.toLowerCase().contains(query.toLowerCase()) ||
          // unit.notes!.toLowerCase()!.contains(query.toLowerCase()) ||
          unit.start_date!.toLowerCase().contains(query.toLowerCase()) ||
          unit.end_date!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUnits = filtered;
    });
  }

  Future<void> _fetchUnits() async {
    UnitService unitService = UnitService();

    try {
      List<UnitModel> fetchedUnits = await unitService.fetchUnits();

      setState(() {
        unitList = fetchedUnits;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(e.toString()),
      //   ),
      // );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Error'),
              children: <Widget>[
                Text(e.toString()),
              ],
            );
          });
    }
  }

  @override
  void dispose() {
    _unitController.dispose();
    _unitCodeController.dispose();
    _noteController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();

    super.dispose();
  }

  Future<void> _submitForm() async {
    UnitService unitService = UnitService();

    String unitName = _unitController.text;
    String unitCode = _unitCodeController.text;
    String note = _noteController.text;
    String startdate = _startDateController.text;
    String enddate = _endDateController.text;

    Map<String, String> requestData = {
      'unit_code': unitCode,
      'unit_name': unitName,
      'notes': note,
      'start_date': startdate,
      'end_date': enddate,
    };

    try {
      var response =
          await unitService.createUnit(requestData); // Call the API service

      if (response.statusCode == 201) {
        // Successful API response
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
                  child: const Text('Unit created successfully!'),
                ),
              ],
            );
          },
        );
        _fetchUnits();
      } else {
        // Error in API response
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
                  child: Text(
                      'Failed to create department. Status code: ${response.statusCode}\nError: ${response.body}'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
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
                child: Text('Error occurred: $error'),
              ),
            ],
          );
        },
      );
    }

    _unitController.clear();
    _unitCodeController.clear();
    _noteController.clear();
    _startDateController.clear();
    _endDateController.clear();
  }

  void _editUnit(UnitModel unit) {
    setState(() {
      _isEditing = true;
      selectedUnit = unit;
      _unitController.text = unit.unit_name;
      _unitCodeController.text = unit.unit_code;
      _noteController.text = unit.notes ?? '';
      _startDateController.text = unit.start_date!;
      _endDateController.text = unit.end_date!;
    });
  }

  // Cancel editing
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      selectedUnit = null;
      _clearForm();
    });
  }

  //Clear form
  void _clearForm() {
    _unitController.clear();
    _unitCodeController.clear();
    _noteController.clear();
    _startDateController.clear();
    _endDateController.clear();
  }

  void _updateForm() async {
    if (_formKey.currentState!.validate()) {
      String unitName = _unitController.text;
      String unitCode = _unitCodeController.text;
      String note = _noteController.text;
      String startdate = _startDateController.text;
      String enddate = _endDateController.text;

      if (selectedUnit != null) {
        selectedUnit!.unit_name = unitName;
        selectedUnit!.unit_code = unitCode;
        selectedUnit!.notes = note;
        selectedUnit!.start_date = startdate;
        selectedUnit!.end_date = enddate;

        try {
          await UnitService().updateUnit(selectedUnit!);

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
                    child: const Text('Unit updated successfully!'),
                  ),
                ],
              );
            },
          );
          _fetchUnits();
        } catch (error) {
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
                    child: Text('Failed to update Unit: $error'),
                  ),
                ],
              );
            },
          );
        }
        setState(() {
          _isEditing = false;
          selectedUnit = null;
          _clearForm();
        });
      }
    }
  }

  Future<void> _deleteUnit(int index) async {
    final UnitModel selectedUnit = unitList[index]; // Save original department
    int departmentId = selectedUnit.id;

    // Remove department from the local list
    setState(() {
      unitList.removeAt(index);
    });

    try {
      await UnitService().deleteUnit(departmentId);

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
                child: const Text('Unit deleted successfully!'),
              ),
            ],
          );
        },
      );
      _fetchUnits();
    } catch (error) {
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
                child: Text('Failed to delete department: $error'),
              ),
            ],
          );
        },
      );

      setState(() {
        unitList.insert(index, selectedUnit);
      });
    }
  }

  //confirmation dialog
  void _showConfirmationDialog({required String purpose, int? id}) {
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
                } else if (purpose == 'Delete') {
                  _deleteUnit(id!);
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
        controller.text = "${picked.toLocal()}".split(' ')[0];
        // Format the date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MASTERS / UNITS',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _desktopView();
        } else {
          return _mobileView();
        }
      }),
    );
  }

  Widget _desktopView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //user id row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('User Id : ${_userId}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),

              //Unit Code, Unit Name, Notes Row
              Row(
                children: [
                  //Unit Code
                  Expanded(
                    child: TextFormField(
                      controller: _unitCodeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Unit Code';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Unit Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  //Unit Name
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Unit Name';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Unit Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  //Notes
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        constraints: BoxConstraints(minHeight: 50),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              //Start Date, End Date Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly:
                          true, // Make it read-only to prevent keyboard opening
                      onTap: () => _selectDate(context, _startDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Select Start Date';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month)),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly:
                            true, // Make it read-only to prevent keyboard opening
                        onTap: () => _selectDate(context, _endDateController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select end Date';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_month)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              _isEditing
                  ? Row(
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
                            _showConfirmationDialog(purpose: "Update");
                          },
                          child: Text("Update",
                              style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onPressed: () {
                            _cancelEdit();
                          },
                          child: Text("Cancel",
                              style: TextStyle(color: Colors.white)),
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
                              _showConfirmationDialog(purpose: "Submit");
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 10),

              //Search Bar
              SizedBox(
                width: 200,
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              unitList.length == 0
                  ? Center(child: Text("No Unit Data Available"))
                  : //Data Table
                  SizedBox(
                      width: 1500,
                      child: PaginatedDataTable(
                        header: Center(
                          child: Text('Units List'),
                        ),
                        columns: const [
                          DataColumn(label: Text('Unit Name')),
                          DataColumn(label: Text('Unit Code')),
                          DataColumn(label: Text('Notes')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
                          DataColumn(label: Text('Actions')),
                        ],
                        source: UnitDataSource(
                          units: filteredUnits,
                          isadmin: _isadmin ?? false,
                          onEdit: _editUnit,
                          onDelete: (index) {
                            _showConfirmationDialog(
                                purpose: "Delete", id: index);
                          },
                        ),
                        rowsPerPage: 3,
                      ),
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
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('User Id : ${_userId}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
              SizedBox(height: 10),

              TextFormField(
                controller: _unitCodeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Unit Code';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Unit Code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              //   Text('Unit',textAlign: TextAlign.left,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              TextFormField(
                controller: _unitController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Unit Name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Unit Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              //Text('Notes'),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: 'Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              //Text('Start Date',style: TextStyle(fontWeight: FontWeight.bold),),
              TextFormField(
                controller: _startDateController,
                readOnly: true, // Make it read-only to prevent keyboard opening
                onTap: () => _selectDate(context, _startDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Select Start Date';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month)),
              ),

              const SizedBox(height: 10),

              //Text('End Date',style: TextStyle(fontWeight: FontWeight.bold),),
              TextFormField(
                controller: _endDateController,
                readOnly: true, // Make it read-only to prevent keyboard opening
                onTap: () => _selectDate(context, _endDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Select end Date';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month)),
              ),
              const SizedBox(
                height: 10,
              ),

              _isEditing
                  ? Row(
                      children: [
                        Expanded(
                          flex: 1,
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
                            child: Text("Update",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            onPressed: () {
                              _cancelEdit();
                            },
                            child: Text("Cancel",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  : Center(
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
                            _showConfirmationDialog(purpose: "Submit");
                          }
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

              SizedBox(height: 10),
              //Search Bar
              SizedBox(
                width: 200,
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              unitList.length == 0
                  ? Center(child: Text("No Unit Data Available"))
                  : //Data Table
                  SizedBox(
                      width: 1500,
                      child: PaginatedDataTable(
                        header: Center(
                          child: Text('Units List'),
                        ),
                        columns: const [
                          DataColumn(label: Text('Unit Name')),
                          DataColumn(label: Text('Unit Code')),
                          DataColumn(label: Text('Notes')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
                          DataColumn(label: Text('Actions')),
                        ],
                        source: UnitDataSource(
                          units: filteredUnits,
                          isadmin: _isadmin ?? false,
                          onEdit: _editUnit,
                          onDelete: (index) {
                            _showConfirmationDialog(
                                purpose: "Delete", id: index);
                          },
                        ),
                        rowsPerPage: 3,
                      ),
                    ), // SingleChildScrollView(child: _buildDataTable())
            ],
          ),
        ),
      ),
    );
  }
}

class UnitDataSource extends DataTableSource {
  final List<UnitModel> units;
  final bool isadmin;
  final void Function(UnitModel) onEdit;
  final void Function(int) onDelete;

  UnitDataSource({
    required this.units,
    required this.isadmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    final unit = units[index];
    // print("Unit: $unit");

    return DataRow(cells: [
      DataCell(Text(unit.unit_name, overflow: TextOverflow.ellipsis)),
      DataCell(Text(unit.unit_code, overflow: TextOverflow.ellipsis)),
      DataCell(Text(unit.notes ?? '', overflow: TextOverflow.ellipsis)),
      DataCell(Text(unit.start_date ?? '', overflow: TextOverflow.ellipsis)),
      DataCell(Text(unit.end_date ?? '', overflow: TextOverflow.ellipsis)),
      DataCell(
        Row(
          children: [
            IconButton(
                onPressed: () {
                  onEdit(unit);
                },
                icon: Icon(Icons.edit)),
            isadmin
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      onDelete(index);
                    },
                  )
                : const SizedBox(width: 0),
          ],
        ),
      )
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => units.length;

  @override
  int get selectedRowCount => 0;
}
