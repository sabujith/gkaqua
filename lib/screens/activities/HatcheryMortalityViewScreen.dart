import 'package:flutter/material.dart';
import 'package:gk_aqua/models/division.dart';
import 'package:gk_aqua/models/tank.dart';
import 'package:gk_aqua/screens/activities/HatcheryMortalityActivityScreen.dart';
import 'package:gk_aqua/services/hatcheryMortalityServices.dart';

class HatcheryMortalityView extends StatelessWidget {
  const HatcheryMortalityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HatcheryMortalityViewScreen(),
    );
  }
}

class HatcheryMortalityViewScreen extends StatefulWidget {
  const HatcheryMortalityViewScreen({super.key});

  @override
  State<HatcheryMortalityViewScreen> createState() =>
      _HatcheryMortalityViewScreenState();
}

class _HatcheryMortalityViewScreenState
    extends State<HatcheryMortalityViewScreen> {
  List<dynamic> hatcheryMortalityList = [];
  List<dynamic> filteredMortalityList = [];
  String? _userId;
  bool? _isAdmin;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    getAllHatcheryMortality();
  }

  Future<void> _getUserDetails() async {
    setState(() {
      _userId = "User 123";
      _isAdmin = true;
    });
  }

  Future<void> getAllHatcheryMortality() async {
    HatcheryMortalityService hatcheryMortalityService =
        HatcheryMortalityService();

    try {
      List<dynamic> fetchedDetails =
          await hatcheryMortalityService.getAllMortality();
      setState(() {
        hatcheryMortalityList = fetchedDetails;
        filteredMortalityList = fetchedDetails; // Initialize filtered list
      });
    } catch (e) {
      _showErrorDialog(e.toString());
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

  void _deleteMortality(int index) async {
    final mortality = filteredMortalityList[index];
    int? mortalityId = mortality['id'];
    setState(() {
      hatcheryMortalityList.remove(mortality);
      filteredMortalityList.removeAt(index);
    });

    try {
      await HatcheryMortalityService().deleteMortality(mortalityId!);
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _filterMortalityList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMortalityList = hatcheryMortalityList;
      } else {
        filteredMortalityList = hatcheryMortalityList
            .where((mortality) =>
                mortality['date']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                mortality['employee_code']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                mortality['department']['department_name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                mortality['division']['division_name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                mortality['tank']['tank_name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Hatchery Mortality View'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('User ID: $_userId',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by date, employee code, etc.',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) => _filterMortalityList(query),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: filteredMortalityList.isEmpty
                ? const Center(child: Text("No Data Available"))
                : Center(
                    child: SizedBox(
                      width: 1500,
                      child: PaginatedDataTable(
                        header: const Text('Hatchery Mortality Data'),
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Employee Code')),
                          DataColumn(label: Text('Department')),
                          DataColumn(label: Text('Division')),
                          DataColumn(label: Text('Tank')),
                          DataColumn(label: Text('Mortality Count')),
                          DataColumn(label: Text('Actions')),
                        ],
                        source: _MortalityDataSource(
                          context: context,
                          mortalityList: filteredMortalityList,
                          isAdmin: _isAdmin ?? false,
                          deleteMortality: _deleteMortality,
                        ),
                        rowsPerPage: 5,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MortalityDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> mortalityList;
  final bool isAdmin;
  final Function(int) deleteMortality;

  _MortalityDataSource({
    required this.context,
    required this.mortalityList,
    required this.isAdmin,
    required this.deleteMortality,
  });

  @override
  DataRow getRow(int index) {
    if (index >= mortalityList.length) return const DataRow(cells: []);
    final mortality = mortalityList[index];
    return DataRow(cells: [
      DataCell(Text(mortality['date'])),
      DataCell(Text(mortality['employee_code'])),
      DataCell(Text(mortality['department']['department_name'])),
      DataCell(Text(mortality['division']['division_name'])),
      DataCell(Text(mortality['tank']['tank_name'])),
      DataCell(Text(mortality['total_mortality_count'].toString())),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final divisionData = mortality['division'];
              final DivisionModel division =
                  DivisionModel.fromJson(divisionData);

              final tankData = mortality['tank'];
              final TankModel tank = TankModel.fromJson(tankData);

              final Map<String, dynamic> updatedData = {
                'id': mortality['id'],
                'date': mortality['date'],
                'divisionId': division.id,
                'tankId': tank.id,
                'larvaeCount': mortality['larvae_count'],
                'countMultiplier': mortality['count_multiplier'],
                'totalMortality': mortality['total_mortality_count'],
                'note': mortality['notes'],
              };

              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HatcheryMortalityActivityScreen(
                  updatingData: updatedData,
                  isEditing: true,
                ),
              ));
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
