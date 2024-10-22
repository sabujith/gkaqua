import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gk_aqua/services/api_department.dart';
import '../../models/department.dart'; // Adjust the path as necessary

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        backgroundColor: Colors.blue,
      ),
      body: const DepartmentForm(),
    );
  }
}

class DepartmentForm extends StatefulWidget {
  const DepartmentForm({super.key});

  @override
  State<DepartmentForm> createState() => _DepartmentFormState();
}

class _DepartmentFormState extends State<DepartmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _departmentCodeController = TextEditingController();
  final _departmentNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _isAdmin = true;
  bool _isEditing = false; // Tracks whether we are in edit mode
  Department? _editingDepartment; // The department being edited

  List<Department> departments = []; // List to store department objects

  @override
  void initState() {
    super.initState();
    _fetchDepartments(); // Fetch initial department data
  }

  Future<void> _fetchDepartments() async {
    DepartmentService departmentService = DepartmentService();

    try {
      // Call the API service to fetch departments
      List<Department> fetchedDepartments =
          await departmentService.fetchDepartments();

      // Update the state with the fetched departments
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
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Error fetching departments: $e'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _departmentCodeController.dispose();
    _departmentNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    DepartmentService departmentService = DepartmentService();
    if (_formKey.currentState!.validate()) {
      String departmentCode = _departmentCodeController.text;
      String departmentName = _departmentNameController.text;
      String note = _notesController.text;
      String startDate = _startDateController.text;
      String endDate = _endDateController.text;

      // Prepare data to be sent
      Map<String, String> requestData = {
        'department_code': departmentCode,
        'department_name': departmentName,
        'note': note,
        'start_date': startDate,
        'end_date': endDate,
      };

      try {
        var response = await departmentService
            .createDepartment(requestData); // Call the API service

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
                    child: const Text('Department created successfully!'),
                  ),
                ],
              );
            },
          );
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

      // Clear the form fields after submission
      _departmentCodeController.clear();
      _departmentNameController.clear();
      _notesController.clear();
      _startDateController.clear();
      _endDateController.clear();
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
        controller.text =
            "${picked.toLocal()}".split(' ')[0]; // Format the date
      });
    }
  }

  // Edit department
  void _editDepartment(Department department) {
    setState(() {
      _isEditing = true; // Set edit mode to true
      _editingDepartment = department; // Store the department being edited
      _departmentCodeController.text = department.departmentCode;
      _departmentNameController.text = department.departmentName;
      _notesController.text = department.notes ?? '';
      _startDateController.text = department.startDate ?? '';
      _endDateController.text = department.endDate ?? '';
    });
  }

  // Cancel edit
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingDepartment = null;
      _clearForm();
    });
  }

  // Update department
  void _updateForm() async {
    if (_formKey.currentState!.validate()) {
      String departmentCode = _departmentCodeController.text;
      String departmentName = _departmentNameController.text;
      String note = _notesController.text;
      String startDate = _startDateController.text;
      String endDate = _endDateController.text;

      if (_editingDepartment != null) {
        _editingDepartment!.departmentCode = departmentCode;
        _editingDepartment!.departmentName = departmentName;
        _editingDepartment!.notes = note;
        _editingDepartment!.startDate = startDate;
        _editingDepartment!.endDate = endDate;

        try {
          await DepartmentService().updateDepartment(_editingDepartment!);

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
                    child: const Text('Department updated successfully!'),
                  ),
                ],
              );
            },
          );
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
                    child: Text('Error updating department: $error'),
                  ),
                ],
              );
            },
          );
        }

        setState(() {
          _isEditing = false;
          _editingDepartment = null;
        });

        _clearForm();
      }
    }
  }

  //Clear the form
  void _clearForm() {
    _departmentCodeController.clear();
    _departmentNameController.clear();
    _notesController.clear();
    _startDateController.clear();
    _endDateController.clear();
  }

  // Delete department
  void _deleteDepartment(int index) async {
    final Department originalDepartment =
        departments[index]; // Save original department
    final departmentId = originalDepartment.id;

    // Remove department from the local list
    setState(() {
      departments.removeAt(index);
    });

    try {
      await DepartmentService().deleteDepartment(departmentId);

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
                child: const Text('Department deleted successfully!'),
              ),
            ],
          );
        },
      );
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
        departments.insert(index, originalDepartment);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Department Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _departmentCodeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a department code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Department Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _departmentNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a department name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _notesController,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Start Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _startDateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a start date';
                    }
                    return null;
                  },
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _selectDate(context, _startDateController);
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'End Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _endDateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an end date';
                    }
                    return null;
                  },
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _selectDate(context, _endDateController);
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isEditing ? _updateForm : _submitForm,
                  child:
                      Text(_isEditing ? 'Update Department' : 'Add Department'),
                ),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _cancelEdit,
                    child: const Text('Cancel Edit'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                    title: Text(departments[index].departmentName),
                    subtitle: Text(departments[index].departmentCode),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteDepartment(index);
                          },
                        ),
                        IconButton(
                            onPressed: () {
                              _editDepartment(departments[index]);
                            },
                            icon: Icon(Icons.edit))
                      ],
                    )),
              );
            },
          ),
        ],
      ),
    );
  }
}
