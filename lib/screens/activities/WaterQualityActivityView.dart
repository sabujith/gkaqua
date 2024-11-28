import 'package:flutter/material.dart';
import 'package:gk_aqua/models/waterQuality.dart';
import 'package:gk_aqua/screens/activities/WaterQualityActivityScreen.dart';
import 'package:gk_aqua/screens/activities/WaterQualityActivityUpdateScreen.dart';
import 'package:gk_aqua/services/waterQuality_services.dart';

class WaterQualityActivityView extends StatelessWidget {
  const WaterQualityActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WaterQualityActivityViewScreen(),
    );
  }
}

class WaterQualityActivityViewScreen extends StatefulWidget {
  const WaterQualityActivityViewScreen({super.key});

  @override
  State<WaterQualityActivityViewScreen> createState() =>
      _WaterQualityActivityViewScreenState();
}

class _WaterQualityActivityViewScreenState
    extends State<WaterQualityActivityViewScreen> {
  List<dynamic> waterQualityList = [];
  List<dynamic> filteredWaterQualityList = [];
  String? _userId;
  bool? _isAdmin;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchWaterQualityDetails();
    await _fetchUserDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _userId = "User 123";
      _isAdmin = true;
    });
  }

  Future<void> _fetchWaterQualityDetails() async {
    WaterqualityServices waterqualityServices = WaterqualityServices();
    try {
      List<dynamic> fetchedWaterQualityDetails =
          await waterqualityServices.fetchWaterQualityChecks();
      setState(() {
        waterQualityList = fetchedWaterQualityDetails;
        filteredWaterQualityList = waterQualityList;
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _filterResults() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredWaterQualityList = waterQualityList.where((item) {
        String checkDate = item['check_date']?.toLowerCase() ?? '';
        String employeeCode = item['employee_code']?.toLowerCase() ?? '';
        String departmentName =
            item['department']['department_name']?.toLowerCase() ?? '';
        String divisionName =
            item['division']['division_name']?.toLowerCase() ?? '';
        String tankName = item['tank']['tank_name']?.toLowerCase() ?? '';
        return checkDate.contains(query) ||
            employeeCode.contains(query) ||
            departmentName.contains(query) ||
            divisionName.contains(query) ||
            tankName.contains(query);
      }).toList();
    });
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
                if (purpose == 'Delete') {
                  _deleteWaterQuality(index!);
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

  //delete water quality
  Future<void> _deleteWaterQuality(int index) async {
    final Map<String, dynamic> selectedWaterQuality = waterQualityList[index];

    int? waterQualityId = selectedWaterQuality['id'];

    setState(() {
      waterQualityList.removeAt(index);
    });

    try {
      WaterqualityServices waterqualityServices = WaterqualityServices();

      await waterqualityServices.deleteWaterQualityCheck(waterQualityId!);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Deleted'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Water Quality deleted successfully!'),
                ),
              ],
            );
          });

      _fetchWaterQualityDetails();
    } catch (error) {
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
                  child: Text(error.toString()),
                )
              ],
            );
          });

      setState(() {
        waterQualityList.insert(index, selectedWaterQuality);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Activity/Water Quality Check',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Search bar
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
                  const SizedBox(height: 10),

                  //Datatable
                  waterQualityList.length == 0
                      ? Center(child: Text('No Data Found'))
                      : Center(
                          child: SizedBox(
                            width: 1500,
                            child: PaginatedDataTable(
                              header: Center(
                                  child: const Text('Water Quality List')),
                              columns: const [
                                DataColumn(label: Text('Check Date')),
                                DataColumn(label: Text('Employee Code')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Division')),
                                DataColumn(label: Text('Tank')),
                                DataColumn(label: Text('Actions')),
                              ],
                              source: WaterQualityDataSource(
                                data: filteredWaterQualityList,
                                context: context,
                                isAdmin: _isAdmin ?? false,
                                refreshData: _fetchWaterQualityDetails,
                              ),
                              rowsPerPage: _rowsPerPage,
                              onRowsPerPageChanged: (rowsPerPage) {
                                setState(() {
                                  _rowsPerPage = rowsPerPage!;
                                });
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

class WaterQualityDataSource extends DataTableSource {
  final List<dynamic> data;
  final BuildContext context;
  final bool isAdmin;
  final Future<void> Function() refreshData;

  WaterQualityDataSource({
    required this.data,
    required this.context,
    required this.isAdmin,
    required this.refreshData,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    return DataRow(cells: [
      DataCell(Text(item['check_date'] ?? 'N/A')),
      DataCell(Text(item['employee_code'] ?? 'N/A')),
      DataCell(Text(item['department']['department_name'] ?? 'N/A')),
      DataCell(Text(item['division']['division_name'] ?? 'N/A')),
      DataCell(Text(item['tank']['tank_name'] ?? 'N/A')),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final Map<String, dynamic> updatedData = {
                "id": item['id'],
                "check_date": item['check_date'],
                "employee_code": item['employee_code'],
                "department_id": item['department_id'],
                "division_id": item['division_id'],
                "tank_id": item['tank_id'],
                "water_parameter_id": item['water_parameter_id'],
                "input_value": item['input_value'],
                "notes": item['notes'],
              };
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return WaterQualityActivityUpdateScreen(
                      WaterQualityData: updatedData);
                },
              ));
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Implement delete logic here
                // _showDeleteConfirmationDialog("Delete", index);
              },
            ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
