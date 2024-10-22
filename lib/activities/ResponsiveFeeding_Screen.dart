import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';

class Feeding extends StatelessWidget {
  const Feeding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveFeedingScreen(),
    );
  }
}

class ResponsiveFeedingScreen extends StatefulWidget {
  const ResponsiveFeedingScreen({super.key});

  @override
  State<ResponsiveFeedingScreen> createState() =>
      _ResponsiveFeedingScreenState();
}

class _ResponsiveFeedingScreenState extends State<ResponsiveFeedingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? UserId;
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedDivision;
  String? _selectedTank;
  String? _selectedFeedType;
  String? _selectedUnit;
  String? _selectedExpiryDate;

  List<String> departments = [];
  List<String> divisions = [];
  List<String> tanks = [];
  List<String> feedTypes = [];

  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
    _getDepartments();
    _getDivisions();
    _getTanks();
    _getFeedTypes();
    _isLoading = false;
  }

  //to get user details
  void _getUserDetails() {
    setState(() {
      UserId = "123";
    });
  }

  //to get departments
  void _getDepartments() {
    setState(() {
      departments = [
        'Hatchery',
        'Broodstock',
        'Feeding',
      ];
    });
  }

  //to get divisions
  void _getDivisions() {
    setState(() {
      divisions = [
        'Div1',
        'Div2',
        'Div3',
      ];
    });
  }

  //to get tanks
  void _getTanks() {
    setState(() {
      tanks = [
        'Tank1',
        'Tank2',
        'Tank3',
      ];
    });
  }

  //to get feed details
  void _getFeedTypes() {
    setState(() {
      feedTypes = [
        'Feed1',
        'Feed2',
        'Feed3',
      ];

      _selectedUnit = 'mg';
      _selectedExpiryDate = '2022-01-01';
    });
  }

  //to select date
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  //submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // show the submitted data on a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Submitted data: ${_dateController.text}, ${_timeController.text}, $_selectedDepartment, $_selectedDivision, $_selectedTank, $_selectedFeedType, ${_quantityController.text}, $_selectedUnit, $_selectedExpiryDate'),
        ),
      );

      // clear the form
      _clearForm();
    }
  }

  //clear form
  void _clearForm() {
    setState(() {
      _dateController.clear();
      _timeController.clear();
      _selectedDepartment = null;
      _selectedDivision = null;
      _selectedTank = null;
      _selectedFeedType = null;
      _quantityController.clear();
      _selectedUnit = null;
      _selectedExpiryDate = null;
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
          'Activity/Feeding',
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
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // User ID Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'User Id : ${UserId}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context, _dateController),
                decoration: const InputDecoration(
                    labelText: 'Feeding Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Time
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text('Feeding Time ',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Radio(
                    value: 'Morning',
                    groupValue: _timeController.text,
                    onChanged: (value) {
                      setState(() {
                        _timeController.text = value as String;
                      });
                    },
                  ),
                  const Text('Morning'),
                  Radio(
                    value: 'Noon',
                    groupValue: _timeController.text,
                    onChanged: (value) {
                      setState(() {
                        _timeController.text = value as String;
                      });
                    },
                  ),
                  const Text('Noon'),
                  Radio(
                    value: 'Evening',
                    groupValue: _timeController.text,
                    onChanged: (value) {
                      setState(() {
                        _timeController.text = value as String;
                      });
                    },
                  ),
                  const Text('Evening'),
                  Radio(
                    value: 'Night',
                    groupValue: _timeController.text,
                    onChanged: (value) {
                      setState(() {
                        _timeController.text = value as String;
                      });
                    },
                  ),
                  const Text('Night'),
                ],
              ),
              SizedBox(height: 10),

              //Department
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value!;
                  });
                },
                items: departments
                    .map((department) => DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Division
              DropdownButtonFormField<String>(
                value: _selectedDivision,
                onChanged: (value) {
                  setState(() {
                    _selectedDivision = value!;
                  });
                },
                items: divisions
                    .map((division) => DropdownMenuItem(
                          value: division,
                          child: Text(division),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Division',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a division';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Tank Code
              DropdownButtonFormField<String>(
                value: _selectedTank,
                onChanged: (value) {
                  setState(() {
                    _selectedTank = value!;
                  });
                },
                items: tanks
                    .map((tankCode) => DropdownMenuItem(
                          value: tankCode,
                          child: Text(tankCode),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Tank',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a tank code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              //Feeding Details
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feed Details',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        //Feed Type
                        DropdownButtonFormField<String>(
                          value: _selectedFeedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedFeedType = value!;
                            });
                          },
                          items: feedTypes
                              .map((feedType) => DropdownMenuItem(
                                    value: feedType,
                                    child: Text(feedType),
                                  ))
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: 'Feed Type',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a feed type';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        //Feed Quantity
                        TextFormField(
                          controller: _quantityController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Select the Quantity";
                            } else
                              return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Quantity",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  'Unit : ${_selectedUnit}'),
                              Text(
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                  'Expiry Date : ${_selectedExpiryDate}')
                            ])
                      ])),
              SizedBox(height: 10),

              //Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                child: Text(
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
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // User ID Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Desktop User Id : ${UserId}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),

              //Date and Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Date
                  Expanded(
                    flex: 1,
                    child: // Date
                        TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateController),
                      decoration: const InputDecoration(
                          labelText: 'Feeding Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(width: 10),

                  //Time
                  Expanded(
                    flex: 2,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          ' Time :',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Radio(
                          value: 'Morning',
                          groupValue: _timeController.text,
                          onChanged: (value) {
                            setState(() {
                              _timeController.text = value as String;
                            });
                          },
                        ),
                        const Text('Morning'),
                        Radio(
                          value: 'Noon',
                          groupValue: _timeController.text,
                          onChanged: (value) {
                            setState(() {
                              _timeController.text = value as String;
                            });
                          },
                        ),
                        const Text('Noon'),
                        Radio(
                          value: 'Evening',
                          groupValue: _timeController.text,
                          onChanged: (value) {
                            setState(() {
                              _timeController.text = value as String;
                            });
                          },
                        ),
                        const Text('Evening'),
                        Radio(
                          value: 'Night',
                          groupValue: _timeController.text,
                          onChanged: (value) {
                            setState(() {
                              _timeController.text = value as String;
                            });
                          },
                        ),
                        const Text('Night'),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),

              //Department, Division, Tank Code Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Department
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                        });
                      },
                      items: departments
                          .map((department) => DropdownMenuItem(
                                value: department,
                                child: Text(department),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),

                  //Division
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDivision,
                      onChanged: (value) {
                        setState(() {
                          _selectedDivision = value!;
                        });
                      },
                      items: divisions
                          .map((division) => DropdownMenuItem(
                                value: division,
                                child: Text(division),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Division',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a division';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),

                  //Tank Code
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTank,
                      onChanged: (value) {
                        setState(() {
                          _selectedTank = value!;
                        });
                      },
                      items: tanks
                          .map((tankCode) => DropdownMenuItem(
                                value: tankCode,
                                child: Text(tankCode),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Tank',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a tank code';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 10),

              //Feeding Details
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feed Details',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Feed Type
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedFeedType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedFeedType = value!;
                                    });
                                  },
                                  items: feedTypes
                                      .map((feedType) => DropdownMenuItem(
                                            value: feedType,
                                            child: Text(feedType),
                                          ))
                                      .toList(),
                                  decoration: const InputDecoration(
                                    labelText: 'Feed Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a feed type';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              //Feed Quantity
                              Expanded(
                                child: TextFormField(
                                  controller: _quantityController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Select the Quantity";
                                    } else
                                      return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Quantity",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  'Unit : ${_selectedUnit}'),
                              Text(
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                  'Expiry Date : ${_selectedExpiryDate}')
                            ])
                      ])),
              SizedBox(height: 10),

              //Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      }
                    },
                    child: Text(
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
