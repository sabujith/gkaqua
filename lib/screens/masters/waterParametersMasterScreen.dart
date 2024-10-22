import 'package:flutter/material.dart';
import 'package:gk_aqua/models/unit_model.dart';
import 'package:gk_aqua/models/waterParameter.dart';
import 'package:gk_aqua/services/unit_services.dart';
import 'package:gk_aqua/services/waterParameter_services.dart';

class Waterparameters extends StatelessWidget {
  const Waterparameters({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Waterparametersform(),
    );
  }
}

class Waterparametersform extends StatefulWidget {
  const Waterparametersform({super.key});

  @override
  State<Waterparametersform> createState() => _WaterparametersformState();
}

class _WaterparametersformState extends State<Waterparametersform> {
  final _formKey = GlobalKey<FormState>();
  waterParameterModel?
      _selectedWaterparameter; //to store selected water parameter for editing or deletion
  List<waterParameterModel> _waterparameters = [];
  final _parameterController = TextEditingController();
  final _parameterCodeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isadmin = true; //to check if the user is an admin or not
  bool _isEditing = false; //to check if the form is in edit mode or not
  UnitModel? _selectedUnit;
  final List<UnitModel> _units = []; //to store units for dropdown

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchWaterparameters();
    _getUnits(context);
  }

  @override
  void dispose() {
    _parameterController.dispose();
    _noteController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

//to fetch water parameters from DB
  Future<void> _fetchWaterparameters() async {
    WaterparameterServices waterparameterServices = WaterparameterServices();

    try {
      List<waterParameterModel> fetchedWaterparameters =
          await waterparameterServices.fetchWaterParameters();

      setState(() {
        _waterparameters = fetchedWaterparameters;
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

//to submit water parameters to DB
  Future<void> _submitForm() async {
    WaterparameterServices waterparameterServices = WaterparameterServices();

    if (_formKey.currentState!.validate()) {
      String waterparameter = _parameterController.text;
      String parameterCode = _parameterCodeController.text;
      int unit_id = _selectedUnit?.id ?? 0;
      String note = _noteController.text;
      String startdate = _startDateController.text;
      String enddate = _endDateController.text;

      Map<String, dynamic> requestData = {
        'parameter_name': waterparameter,
        'parameter_code': parameterCode,
        'unit_id': unit_id,
        'notes': note,
        'start_date': startdate,
        'end_date': enddate
      };
      try {
        var response =
            await waterparameterServices.createWaterParameter(requestData);

        if (response.statusCode == 201) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: const Text('Success'),
                  children: <Widget>[
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Water Parameter added successfully!'),
                    ),
                  ],
                );
              });
          _fetchWaterparameters();
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(title: const Text('Error'), children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                        'Failed to add Water Parameter! Try again later.'),
                  )
                ]);
              });
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(title: const Text('Error'), children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Error :  ${e.toString()}'),
                )
              ]);
            });
      }

      //to clear the fields
      _clearForm();
    }
  }

//to clear the fields
  void _clearForm() {
    _parameterController.clear();
    _parameterCodeController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _noteController.clear();
    setState(() {
      _selectedUnit = null;
    });
  }

//to select field for editing
  void _editWaterparameter(waterParameterModel waterparameter) {
    setState(() {
      _isEditing = true;
      _selectedWaterparameter = waterparameter;
      _parameterController.text = waterparameter.parameter_name!;
      _parameterCodeController.text = waterparameter.parameter_code!;
      _startDateController.text = waterparameter.start_date!;
      _endDateController.text = waterparameter.end_date!;
      _noteController.text = waterparameter.notes!;
      _selectedUnit = _units.firstWhere(
          (unit) => unit.id == waterparameter.unit_id,
          orElse: () => 0 as UnitModel);
    });
  }

//to cancel editing
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedWaterparameter = null;
    });
    _clearForm();
  }

//to update form
  Future<void> _updateForm() async {
    if (_formKey.currentState!.validate()) {
      String waterparameter = _parameterController.text;
      String parameterCode = _parameterCodeController.text;
      int unit_id = _selectedUnit?.id ?? 0;
      String note = _noteController.text;
      String startdate = _startDateController.text;
      String enddate = _endDateController.text;

      if (_selectedWaterparameter != null) {
        _selectedWaterparameter!.parameter_name = waterparameter;
        _selectedWaterparameter!.parameter_code = parameterCode;
        _selectedWaterparameter!.unit_id = unit_id;
        _selectedWaterparameter!.notes = note;
        _selectedWaterparameter!.start_date = startdate;
        _selectedWaterparameter!.end_date = enddate;

        try {
          await WaterparameterServices()
              .updateWaterParameter(_selectedWaterparameter!);
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
                      child:
                          const Text('Water Parameter updated successfully!'),
                    ),
                  ],
                );
              });
          _fetchWaterparameters();
        } catch (e) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(title: const Text('Error'), children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                        'Failed to update Water Parameter :  ${e.toString()}'),
                  )
                ]);
              });
        }
        setState(() {
          _selectedWaterparameter = null;
          _clearForm();
        });
      }
    }
  }

  Future<void> _deleteWaterParameter(int index) async {
    final waterParameterModel _selectedWaterparameter = _waterparameters[index];
    int? waterParameterId = _selectedWaterparameter.id;

    //Remove waterParameter from current list
    setState(() {
      _waterparameters.removeAt(index);
    });

    try {
      await WaterparameterServices().deleteWaterParameter(waterParameterId!);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text("Success"),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                  child: const Text("Water Parameter Deleted Successfully"),
                )
              ],
            );
          });
      _fetchWaterparameters();
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text("Error"),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Failed to delete Water Parameter'),
                )
              ],
            );
          });

      setState(() {
        _waterparameters.insert(index, _selectedWaterparameter);
      });
    }
  }

//to get units for dropdown
  Future<void> _getUnits(BuildContext context) async {
    UnitService unitService = UnitService();

    try {
      List<UnitModel> units = await unitService.fetchUnits();
      setState(() {
        _units.addAll(units);
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
        },
      );
    }
  }

//to select date for start date
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
            'Departments',
          ),
          backgroundColor: Colors.blue,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _desktopView();
          } else {
            return _mobileView();
          }
        }));
  }

  Widget _mobileView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Center(
                  child: Text(
                'WATER PARAMETERS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
              // Text(
              //   'Water Parameters',
              //   textAlign: TextAlign.left,
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),
              TextFormField(
                controller: _parameterController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter water parameter';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Water Parameters',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _parameterCodeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter water parameter code';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Water Parameter Code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<UnitModel>(
                value: _selectedUnit,
                items: _units.map((UnitModel unit) {
                  return DropdownMenuItem<UnitModel>(
                    value: unit,
                    child: Text(unit.unit_name), // Display unit_name
                  );
                }).toList(),
                onChanged: (UnitModel? newValue) {
                  setState(() {
                    _selectedUnit = newValue; // Update the selected unit
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Units',
                  border: OutlineInputBorder(),
                  hintText: 'Select Unit',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a unit';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

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

                const SizedBox(height: 10),

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
                                  borderRadius: BorderRadius.circular(5),
                                )),
                            onPressed: () {
                              _updateForm();
                            },
                            child: Text(
                              "Update",
                              style: TextStyle(color: Colors.white),
                            ),
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
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                )))
                      ],
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _waterparameters.length,
                itemBuilder: (context, index) {
                  final waterParameter = _waterparameters[index];
                  return Card(
                    child: ListTile(
                      title: Text(waterParameter.parameter_name!),
                      subtitle: Text(waterParameter.parameter_code!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editWaterparameter(waterParameter);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteWaterParameter(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Text(
                  'WATER PARAMETERS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _parameterController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter water parameter';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            labelText: 'Water Parameters',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _parameterCodeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter water parameter code';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Water Parameter Code',
                        border: OutlineInputBorder(),
                      ),
                    )),
                    // SizedBox(
                    //   width: 5,
                    // ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<UnitModel>(
                        value: _selectedUnit,
                        items: _units.map((UnitModel unit) {
                          return DropdownMenuItem<UnitModel>(
                            value: unit,
                            child: Text(unit.unit_name), // Display unit_name
                          );
                        }).toList(),
                        onChanged: (UnitModel? newValue) {
                          setState(() {
                            _selectedUnit =
                                newValue; // Update the selected unit
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select Unit',
                            labelText: 'Units'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a unit';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 1,
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
                          onTap: () =>
                              _selectDate(context, _startDateController),
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
                  itemCount: _waterparameters.length,
                  itemBuilder: (context, index) {
                    final waterParameter = _waterparameters[index];
                    return Card(
                      child: ListTile(
                        title: Text(waterParameter.parameter_name!),
                        subtitle: Text(waterParameter.parameter_code!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editWaterparameter(waterParameter);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteWaterParameter(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            )),
      ),
    );
  }
}
