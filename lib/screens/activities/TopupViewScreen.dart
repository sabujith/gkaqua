import 'package:flutter/material.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/screens/activities/TopupActivityScreen.dart';
import 'package:gk_aqua/services/topup_services.dart';

class TopupView extends StatelessWidget {
  const TopupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TopupViewScreen(),
    );
  }
}

class TopupViewScreen extends StatefulWidget {
  const TopupViewScreen({super.key});

  @override
  State<TopupViewScreen> createState() => _TopupViewScreenState();
}

class _TopupViewScreenState extends State<TopupViewScreen> {
  String? _userId;
  List<Map<String, dynamic>> topupList = [];
  List<Map<String, dynamic>> filteredTopupList = [];

  bool _isAdmin = true;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await getTopupList();
    await _getUserDetails();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserDetails() async {
    setState(() {
      _userId = "user123";
      _isAdmin = true;
    });
  }

  Future<void> getTopupList() async {
    TopupService topupService = TopupService();
    setState(() {
      _isLoading = true;
    });
    try {
      List<Map<String, dynamic>> fetchedTopupList =
          await topupService.getAllTopups();
      setState(() {
        topupList = fetchedTopupList;
        filteredTopupList = fetchedTopupList;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _deleteTopup(int index) async {
    final Map<String, dynamic> selectedTopup = filteredTopupList[index];
    int? topupId = selectedTopup['id'];

    setState(() {
      topupList.remove(selectedTopup);
      filteredTopupList.removeAt(index);
    });

    try {
      TopupService topupService = TopupService();
      await topupService.deleteTopup(topupId!);

      _showSuccessDialog('Topup deleted successfully!');
    } catch (e) {
      _showErrorDialog(e.toString());
      setState(() {
        topupList.add(selectedTopup);
        filteredTopupList = List.from(topupList);
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      filteredTopupList = topupList
          .where((topup) =>
              topup['date'].toLowerCase().contains(_searchQuery) ||
              topup['employee_code'].toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Topup View'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateSearchQuery,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredTopupList.isEmpty
                      ? const Center(child: Text('No data available'))
                      : Center(
                          child: SizedBox(
                            width: 1500,
                            child: PaginatedDataTable(
                              header: const Text('Topup Data'),
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Employee Code')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Division')),
                                DataColumn(label: Text('Tank')),
                                DataColumn(label: Text('Male Count')),
                                DataColumn(label: Text('Female Count')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rowsPerPage: 5,
                              source: _TopupDataSource(
                                context: context,
                                topupList: filteredTopupList,
                                isAdmin: _isAdmin,
                                deleteTopup: _deleteTopup,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _TopupDataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> topupList;
  final bool isAdmin;
  final Function(int) deleteTopup;

  _TopupDataSource({
    required this.context,
    required this.topupList,
    required this.isAdmin,
    required this.deleteTopup,
  });

  @override
  DataRow getRow(int index) {
    if (index >= topupList.length) return const DataRow(cells: []);
    final topup = topupList[index];
    return DataRow(cells: [
      DataCell(Text(topup['date'] ?? 'N/A')),
      DataCell(Text(topup['employee_code'] ?? 'N/A')),
      DataCell(Text(topup['department']['department_name'] ?? 'N/A')),
      DataCell(Text(topup['division']['division_name'] ?? 'N/A')),
      DataCell(Text(topup['tank']['tank_name'] ?? 'N/A')),
      DataCell(Text(topup['male_prawn_topup_count'].toString())),
      DataCell(Text(topup['female_prawn_topup_count'].toString())),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Edit action
                final department = Department.fromJson(topup['department']);
                final division = DivisionModel.fromJson(topup['division']);
                final tank = TankModel.fromJson(topup['tank']);
                final Map<String, dynamic> updatedData = {
                  'id': topup['id'],
                  'date': topup['date'],
                  'departmentId': department.id,
                  'divisionId': division.id,
                  'tankId': tank.id,
                  'maleCount': topup['male_prawn_topup_count'],
                  'femaleCount': topup['female_prawn_topup_count'],
                  'notes': topup['notes'],
                };
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TopupActivityScreen(
                      topupUpdateData: updatedData,
                      isEditing: true,
                    ),
                  ),
                );
              },
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteTopup(index),
              ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => topupList.length;

  @override
  int get selectedRowCount => 0;
}
