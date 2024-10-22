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
  final _unitController = TextEditingController();
  final _unitCodeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _noteController = TextEditingController();
  final _endDateController = TextEditingController();
  final _isadmin = true;
  bool _isEditing = false;

  UnitModel? selectedUnit;

  Map<String, String>? editingUnit;
  List<UnitModel> unitList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    UnitService unitService = UnitService();

    try {
      List<UnitModel> fetchedUnits = await unitService.fetchUnits();
      print(fetchedUnits);

      setState(() {
        unitList = fetchedUnits;
      });
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

    if (_formKey.currentState!.validate()) {
      String unitName = _unitController.text;
      String unitCode = _unitCodeController.text;
      String note = _noteController.text;
      String startdate = _startDateController.text;
      String enddate = _endDateController.text;

      // setState(() {
      //   unitLis({
      //     'unit_code': unitCode,
      //     'unit_name': unitName,
      //     'notes': note,
      //     'start_date': startdate,
      //     'end_date': enddate,
      //   });
      // });

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
  }

  void _editUnit(UnitModel unit) {
    setState(() {
      _isEditing = true;
      selectedUnit = unit;
      _unitController.text = unit.unit_name;
      _unitCodeController.text = unit.unit_code;
      _noteController.text = unit.notes!;
      _startDateController.text = unit.start_date!;
      _endDateController.text = unit.end_date!;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      selectedUnit = null;
      _clearForm();
    });
  }

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

  /// Mobile view of the unit master screen.
  ///
  /// Shows a form with unit code, unit, notes, start date and end date fields.
  /// Allows the user to select start and end dates from a calendar.
  /// Validates the form and saves the data when the user presses the save button.
  /// If the user is not an admin, the start and end date fields are not shown.
  ///
  Widget _mobileView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //  Text('Unit Code',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),

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

              const SizedBox(
                height: 10,
              ),

              if (_isadmin) ...[
                //Text('Start Date',style: TextStyle(fontWeight: FontWeight.bold),),

                TextFormField(
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

                const SizedBox(
                  height: 10,
                ),

                //Text('End Date',style: TextStyle(fontWeight: FontWeight.bold),),
                TextFormField(
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
              ],
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
                              _updateForm();
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
                        onPressed: _submitForm,
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unitList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                        title: Text(unitList[index].unit_name),
                        subtitle: Text(unitList[index].unit_code),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteUnit(index);
                              },
                            ),
                            IconButton(
                                onPressed: () {
                                  _editUnit(unitList[index]);
                                },
                                icon: Icon(Icons.edit))
                          ],
                        )),
                  );
                },
              )
              // SingleChildScrollView(child: _buildDataTable())
            ],
          ),
        ),
      ),
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
              Row(
                children: [
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
                  SizedBox(
                    width: 5,
                  ),
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
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        constraints: BoxConstraints(minHeight: 50),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (_isadmin) ...[
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
                ],
              ),
              SizedBox(
                height: 10,
              ),
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
                            _updateForm();
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
                          onPressed: _submitForm,
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unitList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                        title: Text(unitList[index].unit_name),
                        subtitle: Text(unitList[index].unit_code),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteUnit(index);
                              },
                            ),
                            IconButton(
                                onPressed: () {
                                  _editUnit(unitList[index]);
                                },
                                icon: Icon(Icons.edit))
                          ],
                        )),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildDataTable() {
  //   if (unitList.isEmpty) {
  //     return Center(child: Text('No Data available'));
  //   }
  //   return Center(
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: DataTable(
  //           border: TableBorder.all(),
  //           columns: [
  //             DataColumn(
  //                 label: Text(
  //               'Unit Code',
  //               overflow: TextOverflow.ellipsis,
  //             )),
  //             DataColumn(label: Text('Unit')),
  //             DataColumn(label: Text('Start Date')),
  //             DataColumn(label: Text('End Date')),
  //             DataColumn(label: Text('Actions')),
  //           ],
  //           rows: unitList.map(
  //             (unit) {
  //               return DataRow(cells: [
  //                 DataCell(Text(unit['Unit Code']!)),
  //                 DataCell(Text(unit['Unit']!)),
  //                 DataCell(Text(unit['Start Date']!)),
  //                 DataCell(Text(unit['End Date']!)),
  //                 DataCell(
  //                   Row(
  //                     children: [
  //                       IconButton(
  //                         color: Colors.blue,
  //                         icon: Icon(Icons.edit),
  //                         onPressed: () {
  //                           _editUnit(unit);
  //                         },
  //                       ),
  //                       IconButton(
  //                         color: Colors.red,
  //                         icon: Icon(Icons.delete),
  //                         onPressed: () {
  //                           _deleteUnit(unit);
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ]);
  //             },
  //           ).toList(),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
