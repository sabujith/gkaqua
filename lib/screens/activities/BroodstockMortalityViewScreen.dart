import 'package:flutter/material.dart';
import 'package:gk_aqua/models/broodstockMortality.dart';
import 'package:gk_aqua/models/department.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/screens/activities/BroodstockMortalityActivityScreen.dart';
import 'package:gk_aqua/services/broodstockMortalityServices.dart';

class BroodstockMortalityView extends StatelessWidget {
  const BroodstockMortalityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BroodstockMortalityViewScreen(),
    );
  }
}

class BroodstockMortalityViewScreen extends StatefulWidget {
  const BroodstockMortalityViewScreen({super.key});

  @override
  State<BroodstockMortalityViewScreen> createState() =>
      _BroodstockMortalityViewScreenState();
}

class _BroodstockMortalityViewScreenState
    extends State<BroodstockMortalityViewScreen> {
  List<dynamic> broodstockMortalityList = [];
  List<dynamic> filteredMortalityList = [];
  String? _userId;
  bool? _isAdmin;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getBroodstockMortalityList();
    getUserDetails();
    _searchController.addListener(_filterMortalityList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getUserDetails() async {
    setState(() {
      _userId = "User 123";
      _isAdmin = true;
    });
  }

  Future<void> getBroodstockMortalityList() async {
    BroodstockMortalityService broodstockMortalityService =
        BroodstockMortalityService();

    try {
      var response = await broodstockMortalityService.getAllMortality();
      setState(() {
        broodstockMortalityList = response;
        filteredMortalityList = response; // Initialize filtered list
      });
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void _filterMortalityList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredMortalityList = broodstockMortalityList.where((item) {
        final date = item['date']?.toLowerCase() ?? '';
        final employeeCode = item['employee_code']?.toLowerCase() ?? '';
        return date.contains(query) || employeeCode.contains(query);
      }).toList();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Broodstock Mortality View'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Search Bar
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
          // Data Table
          broodstockMortalityList.isEmpty
              ? const Center(child: Text('No Data Available'))
              : Center(
                  child: SizedBox(
                    width: 1500,
                    child: PaginatedDataTable(
                      header: Text('User ID: $_userId'),
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
                      source: _BroodstockMortalityDataSource(
                        context: context,
                        mortalityList: filteredMortalityList,
                        isAdmin: _isAdmin ?? false,
                        deleteMortality: _deleteMortality,
                      ),
                      rowsPerPage: 5,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _deleteMortality(int index) async {
    // Add delete logic here
  }
}

class _BroodstockMortalityDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> mortalityList;
  final bool isAdmin;
  final Function(int) deleteMortality;

  _BroodstockMortalityDataSource({
    required this.context,
    required this.mortalityList,
    required this.isAdmin,
    required this.deleteMortality,
  });

  @override
  DataRow getRow(int index) {
    if (index >= mortalityList.length) return const DataRow(cells: []);
    final item = mortalityList[index];
    return DataRow(cells: [
      DataCell(Text(item['date'] ?? '')),
      DataCell(Text(item['employee_code'] ?? '')),
      DataCell(Text(item['department']['department_name'] ?? '')),
      DataCell(Text(item['division']['division_name'] ?? '')),
      DataCell(Text(item['tank']['tank_name'] ?? '')),
      DataCell(Text('${item['male_prawn_count']}')),
      DataCell(Text('${item['female_prawn_count']}')),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Handle edit action
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteMortality(index),
            ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => mortalityList.length;

  @override
  int get selectedRowCount => 0;
}
