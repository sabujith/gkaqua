import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
// import 'package:gk_aqua/models/employee.dart';
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
  List<dynamic> employeesDet = [];
  List<dynamic> filteredEmployees = [];
  String? _userId;
  bool? _isAdmin;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterEmployees);
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await _fetchEmployees(context);
    await _getUserDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserDetails() async {
    setState(() {
      _userId = "User 123";
      _isAdmin = true;
    });
  }

  Future<void> _fetchEmployees(BuildContext context) async {
    EmployeeServices employeeServices = EmployeeServices();
    try {
      List<dynamic> employees = await employeeServices.fetchEmployees();
      if (mounted) {
        setState(() {
          employeesDet = employees;
          filteredEmployees = employeesDet;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _filterEmployees() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredEmployees = employeesDet
          .where((employee) =>
              employee['name'].toLowerCase().contains(query) ||
              employee['employee_code'].toLowerCase().contains(query) ||
              employee['department']['department_name']
                  .toLowerCase()
                  .contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          //back one screen
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Employee View'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 20),
                //search bar
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //data table
                employeesDet.length == 0
                    ? Center(child: Text('No Employee Data'))
                    : Center(
                        child: SizedBox(
                          width: 1500,
                          child: PaginatedDataTable(
                            header: Center(child: Text('User ID: $_userId')),
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Code')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Actions')),
                            ],
                            source: _EmployeeDataSource(
                              context: context,
                              employees: filteredEmployees,
                              isAdmin: _isAdmin ?? false,
                              deleteEmployee: _deleteEmployee,
                            ),
                            rowsPerPage: 5,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  Future<void> _deleteEmployee(int index) async {
    if (index < 0 || index >= filteredEmployees.length) {
      return; // Prevent invalid indices
    }

    final Map<String, dynamic> employee = filteredEmployees[index];
    int? employeeId = employee['id'];

    try {
      EmployeeServices employeeServices = EmployeeServices();
      await employeeServices.deleteEmployee(employeeId!);

      setState(() {
        filteredEmployees.removeAt(index);
        employeesDet.remove(employee);
      });

      _fetchEmployees(context);
    } catch (e) {
      _showErrorDialog(e.toString());

      setState(() {
        filteredEmployees = List.from(employeesDet);
      });
    }
  }
}

class _EmployeeDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> employees;
  final bool isAdmin;
  final Function(int) deleteEmployee;

  _EmployeeDataSource({
    required this.context,
    required this.employees,
    required this.isAdmin,
    required this.deleteEmployee,
  });

  @override
  DataRow getRow(int index) {
    if (index >= employees.length) return const DataRow(cells: []);
    final employee = employees[index];
    return DataRow(cells: [
      DataCell(Text(employee['name'])),
      DataCell(Text(employee['employee_code'])),
      DataCell(Text(employee['department']['department_name'])),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final departmentData = employee['department'];
              final Department department = Department.fromJson(departmentData);
              final updatingData = {
                'id': employee['id'],
                'employee_code': employee['employee_code'],
                'name': employee['name'],
                'document_type': employee['document_type'],
                'mycad_or_passport_no': employee['mycad_or_passport_no'],
                'department': department.id,
                'mobile': employee['mobile'],
                'address': employee['address'],
                'blood_group': employee['blood_group'],
                'notes': employee['notes'],
                'start_date': employee['start_date'],
                'end_date': employee['end_date'],
              };
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EmployeeAdd(
                    employeeData: updatingData,
                    isEditing: true,
                  ),
                ),
              );
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteEmployee(index),
            ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => employees.length;

  @override
  int get selectedRowCount => 0;
}
