import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/employee.dart';
import 'package:gk_aqua/screens/masters/employeeAddMasterScreen.dart';
import 'package:gk_aqua/services/employee_services.dart';

class EmployeeView extends StatelessWidget {
  const EmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmployeeViewMasterScreen(),
    );
  }
}

class EmployeeViewMasterScreen extends StatefulWidget {
  const EmployeeViewMasterScreen({super.key});

  @override
  State<EmployeeViewMasterScreen> createState() =>
      _EmployeeViewMasterScreenState();
}

class _EmployeeViewMasterScreenState extends State<EmployeeViewMasterScreen> {
  List<dynamic> EmployeesDet = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchEmployees();
  }

  //get all employees details
  Future<void> _fetchEmployees() async {
    EmployeeServices employeeServices = EmployeeServices();
    try {
      List<dynamic> employees = await employeeServices.fetchEmployees();
      setState(() {
        EmployeesDet = employees;
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

  //delete employee
  Future<void> _deleteEmployee(int index) async {
    final Map<String, dynamic> selectedEmployee = EmployeesDet[index];
    print(selectedEmployee);
    int? employeeId = selectedEmployee['id'];
    setState(() {
      EmployeesDet.removeAt(index);
    });

    try {
      await EmployeeServices().deleteEmployee(employeeId!);

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
                  child: Text('Employee deleted successfully!'),
                ),
              ],
            );
          });

      _fetchEmployees();
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

      setState(() {
        EmployeesDet.insert(index, selectedEmployee);
      });
    }
  }

  //edit employee
  Future<void> _editEmployee(int index) async {
    final Map<String, dynamic> selectedEmployee = EmployeesDet[index];
    print(selectedEmployee['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        shadowColor: Colors.blue,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Master/Emp. View',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Center(
              child: Text(
                'View Employee',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: EmployeesDet.length,
              itemBuilder: (context, index) {
                final employee = EmployeesDet[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      // show employee details as a dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Name : ${employee['name']}'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                // Using ListBody for structured and scrollable content
                                children: [
                                  Text(
                                      'Employee Id : ${employee['employee_code']}'),
                                  SizedBox(height: 5),
                                  Text(
                                    'MyCAd/Passport No : ${employee['mycad_or_passport_no']}',
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                      'Department : ${employee['department']['department_name']}'),
                                  SizedBox(height: 5),
                                  Text('Mobile : ${employee['mobile']}'),
                                  SizedBox(height: 5),
                                  Text('Address : ${employee['address']}'),
                                  SizedBox(height: 5),
                                  Text(
                                      'Blood Group : ${employee['blood_group']}'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    title: Text(employee['name']),
                    subtitle: Text(employee['employee_code']),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          final departmentData = employee['department'];
                          final Department department =
                              Department.fromJson(departmentData);
                          // edit functionality
                          // _editEmployee(index);
                          final Map<String, dynamic> updatingData = {
                            'id': employee['id'],
                            'employee_code': employee['employee_code'],
                            'name': employee['name'],
                            'document_type': employee['document_type'],
                            'mycad_or_passport_no':
                                employee['mycad_or_passport_no'],
                            'department': department.id,
                            'mobile': employee['mobile'],
                            'address': employee['address'],
                            'blood_group': employee['blood_group'],
                            'notes': employee['notes'],
                            'start_date': employee['start_date'],
                            'end_date': employee['end_date'],
                          };
                          // print(updatingData);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return EmployeeAdd(
                                  employeeData:
                                      updatingData, // Pass the employee data
                                  isEditing: true, // Set editing mode
                                );
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // delete functionality
                          _deleteEmployee(index);
                        },
                      ),
                    ]),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
