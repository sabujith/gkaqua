import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/screens/masters/employeeViewMasterScreen.dart';
import 'package:gk_aqua/services/api_department.dart';
import 'package:gk_aqua/services/employee_services.dart';

class Employee extends StatelessWidget {
  const Employee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmployeeAdd(),
    );
  }
}

class EmployeeAdd extends StatefulWidget {
  final Map<String, dynamic>? employeeData; // Employee details passed
  final bool isEditing; // Flag to indicate whether it's edit mode

  const EmployeeAdd({super.key, this.employeeData, this.isEditing = false});

  @override
  State<EmployeeAdd> createState() => _EmployeeAddState();
}

class _EmployeeAddState extends State<EmployeeAdd> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _employeeNameController = TextEditingController();
  String? _selectedDocType;
  final _mycad_or_passport_noController = TextEditingController();
  Department? _selectedDept;
  final _employeeMobileController = TextEditingController();
  final _employeeAddressController = TextEditingController();
  String? _selectedBloodGrp;
  final _noteController = TextEditingController();
  final _startdateController = TextEditingController();
  final _enddateController = TextEditingController();

  List<Department> _dept = [];
  final List<String> _bloodgrp = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  final List<String> _documentType = ['MyCAD', 'Passport'];
  bool _isadmin = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeData(); // New async method for initialization
  }

  Future<void> _initializeData() async {
    await _getDepartments(); // Wait for departments to be fetched
    setState(() {
      if (widget.isEditing && widget.employeeData != null) {
        isEditing = true;
        _employeeIdController.text = widget.employeeData!['employee_code'];
        _employeeNameController.text = widget.employeeData!['name'];
        _employeeMobileController.text = widget.employeeData!['mobile'];
        _employeeAddressController.text = widget.employeeData!['address'];
        _mycad_or_passport_noController.text =
            widget.employeeData!['mycad_or_passport_no'];
        _selectedDocType = widget.employeeData!['document_type'];

        //check if _dept have similiar data with widget.employeeData['department']
        _selectedDept = _dept.fold(null, (previousValue, element) {
          if (element.id == widget.employeeData!['department']) {
            return element;
          }
          return previousValue;
        });

        _selectedBloodGrp = widget.employeeData!['blood_group'];
        _noteController.text = widget.employeeData!['notes'];
        _startdateController.text = widget.employeeData!['start_date'];
        _enddateController.text = widget.employeeData!['end_date'];
      } else {
        isEditing = false;
      }
    });
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _employeeMobileController.dispose();
    _employeeAddressController.dispose();
    _mycad_or_passport_noController.dispose();
    _startdateController.dispose();
    _enddateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

// Function to get the departments from the API
  Future<void> _getDepartments() async {
    DepartmentService departmentService = DepartmentService();

    try {
      List<Department> fetchedDepartments =
          await departmentService.fetchDepartments();
      setState(() {
        _dept = fetchedDepartments;
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text("Error"),
              children: [
                Text(e.toString()),
              ],
            );
          });
    }
  }

// Function to select the date
  Future<void> _selectDate(
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

// Function to submit the form
  Future<void> _submitform() async {
    EmployeeServices employeeServices = EmployeeServices();
    if (_formKey.currentState!.validate()) {
      // Get the values from the form
      String employeeId = _employeeIdController.text;
      String employeeName = _employeeNameController.text;
      String documentType = _selectedDocType ?? '';
      String mycad_or_passport_no = _mycad_or_passport_noController.text;
      String dept = _selectedDept!.id.toString();
      String employeeMobile = _employeeMobileController.text;
      String employeeAddress = _employeeAddressController.text;
      String bloodGrp = _selectedBloodGrp ?? '';
      String note = _noteController.text;
      String startdate = _startdateController.text;
      String enddate = _enddateController.text;

      Map<String, dynamic> requestData = {
        'employee_code': employeeId,
        'name': employeeName,
        'mobile': employeeMobile,
        'address': employeeAddress,
        'document_type': documentType,
        'mycad_or_passport_no': mycad_or_passport_no,
        'department_id': dept,
        'blood_group': bloodGrp,
        'notes': note,
        'start_date': startdate,
        'end_date': enddate
      };

      try {
        var response = await employeeServices.createEmployee(requestData);

        // print('response.statusCode ${response.statusCode}');
        // print('response.body ${response.body}');

        if (response.statusCode == 201) {
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
                      child: const Text('New Employee added successfully!'),
                    ),
                  ],
                );
              });

          _clearForm();
        } else {
          // print('error in else case : ${response.body}');
          throw 'Failed to create employee';
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
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Something went wrong \n$e'),
                  ),
                ],
              );
            });
      }
    }
  }

  //function to update the employee
  void _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      // Get the values from the form
      int id = widget.employeeData!['id'];
      String employeeId = _employeeIdController.text;
      String employeeName = _employeeNameController.text;
      String documentType = _selectedDocType ?? '';
      String mycad_or_passport_no = _mycad_or_passport_noController.text;
      int dept = _selectedDept!.id;
      String employeeMobile = _employeeMobileController.text;
      String employeeAddress = _employeeAddressController.text;
      String bloodGrp = _selectedBloodGrp ?? '';
      String note = _noteController.text;
      String startdate = _startdateController.text;
      String enddate = _enddateController.text;

      Map<String, dynamic> requestData = {
        'employee_code': employeeId,
        'name': employeeName,
        'mobile': employeeMobile,
        'address': employeeAddress,
        'document_type': documentType,
        'mycad_or_passport_no': mycad_or_passport_no,
        'department_id': dept,
        'blood_group': bloodGrp,
        'notes': note,
        'start_date': startdate,
        'end_date': enddate
      };

      try {
        await EmployeeServices().updateEmployee(requestData, id);
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
                    child: const Text('Employee updated successfully!'),
                  ),
                ],
              );
            });
        isEditing = false;
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
        // _cancelUpdate();
        // isEditing = false;
      }
    }
  }

  //funciton to Cancel the updation
  Future<void> _cancelUpdate() async {
    setState(() {
      isEditing = false;
    });
    _clearForm();
  }

  //clear form fields
  void _clearForm() {
    // Clear the form after submission
    _employeeIdController.clear();
    _employeeNameController.clear();
    _employeeMobileController.clear();
    _employeeAddressController.clear();
    _mycad_or_passport_noController.clear();
    _startdateController.clear();
    _enddateController.clear();
    _noteController.clear();
    setState(() {
      _selectedDept = null;
      _selectedBloodGrp = null;
      _selectedDocType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Update Employee' : 'Add Employee',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(
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

  Widget _mobileView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                          child: Wrap(
                            children: [
                              Text(
                                "Add Employee",
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
                                  return EmployeeViewMasterScreen();
                                },
                              ),
                            );
                          },
                          child: Wrap(
                            children: [
                              Text(
                                "View Employees",
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
              // const Text('MASTERS/EMPLOYEE-ADD',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Employee Code',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              // SizedBox(

              //   height: 10),
              TextFormField(
                controller: _employeeIdController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Employee Id';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Employee Code'),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Employee Name',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),
              TextFormField(
                controller: _employeeNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Employee Name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Employee Name'),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Department',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedDocType,
                items: _documentType.map((String documentType) {
                  return DropdownMenuItem<String>(
                    value: documentType,
                    child: Text(documentType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDocType = newValue;
                  });
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Document Type'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a document';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _mycad_or_passport_noController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mycad or Passport No.'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an MyCAD or Passport No.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              DropdownButtonFormField<Department>(
                value: _selectedDept,
                items: _dept.map((Department dept) {
                  return DropdownMenuItem<Department>(
                    value: dept,
                    child: Text(dept.departmentName),
                  );
                }).toList(),
                onChanged: (Department? newValue) {
                  setState(() {
                    _selectedDept = newValue;
                  });
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Department'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select the department';
                  }
                  return null;
                },
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Mob',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),
              TextFormField(
                controller: _employeeMobileController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mobile number';
                  } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Mob'),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Address',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),
              TextFormField(
                controller: _employeeAddressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Address'),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Blood Grp',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBloodGrp,
                items: _bloodgrp.map((String grp) {
                  return DropdownMenuItem<String>(
                    value: grp,
                    child: Text(grp),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGrp = newValue;
                  });
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Blood Group'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select the blood group';
                  }
                  return null;
                },
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'MyCad/Passport No',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),

              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: const Text(
              //     'Note',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),

              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Note'),
              ),
              SizedBox(height: 10),

              if (_isadmin) ...[
                //Conditionally show date fields if user is an admin
                // Padding(
                //   padding: const EdgeInsets.all(10),
                //   child: const Text('Start Date',
                //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // ),
                TextFormField(
                  controller: _startdateController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _startdateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      labelText: 'Start Date'),
                ),
                SizedBox(height: 10),
                // Padding(
                //   padding: const EdgeInsets.all(10),
                //   child: const Text('End Date',
                //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // ),
                TextFormField(
                  controller: _enddateController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _enddateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a End date';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      labelText: 'End Date'),
                ),
              ],

              SizedBox(height: 10),
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
                            onPressed: _updateEmployee,
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
                      onPressed: _submitform,
                      child: const Text('Save',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                                  "Add Employee",
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
                                    return EmployeeViewMasterScreen();
                                  },
                                ),
                              );
                            },
                            child: Wrap(
                              children: [
                                Text(
                                  "View Employees",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _employeeIdController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an Employee Id';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Employee Code'),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _employeeNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an Employee Name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Employee Name'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDocType,
                        items: _documentType.map((String documentType) {
                          return DropdownMenuItem<String>(
                            value: documentType,
                            child: Text(documentType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDocType = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Document Type'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a document';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _mycad_or_passport_noController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Mycad or Passport No.'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an MyCAD or Passport No.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Department>(
                        value: _selectedDept,
                        items: _dept.map((Department dept) {
                          return DropdownMenuItem<Department>(
                            value: dept,
                            child: Text(dept.departmentName),
                          );
                        }).toList(),
                        onChanged: (Department? newValue) {
                          setState(() {
                            _selectedDept = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Department'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select the department';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _employeeMobileController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mobile number';
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Mob'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _employeeAddressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Address'),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBloodGrp,
                        items: _bloodgrp.map((String grp) {
                          return DropdownMenuItem<String>(
                            value: grp,
                            child: Text(grp),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBloodGrp = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Blood Group'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select the blood group';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        maxLines: null, // Allow unlimited lines
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Note',
                          constraints: BoxConstraints(
                            minHeight:
                                50.0, // Adjust this to match TextFormField height
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_isadmin) ...[
                      Expanded(
                        child: TextFormField(
                          controller: _startdateController,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _startdateController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a start date';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                              labelText: 'Start Date'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _enddateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, _enddateController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a End date';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                              labelText: 'End Date'),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 20),
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
                            onPressed: _updateEmployee,
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
                            onPressed: _submitform,
                            child: const Text('Submit',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      )
              ],
            )),
      ),
    );
  }
}
