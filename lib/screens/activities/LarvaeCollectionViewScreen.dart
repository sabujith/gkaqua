import 'package:flutter/material.dart';
import 'package:gk_aqua/screens/activities/LarvaeCollectionActivityScreen.dart';
import 'package:gk_aqua/services/larvaeCollection_services.dart';

class LarvaeCollectionView extends StatelessWidget {
  const LarvaeCollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LarvaeCollectionViewScreen(),
    );
  }
}

class LarvaeCollectionViewScreen extends StatefulWidget {
  const LarvaeCollectionViewScreen({super.key});

  @override
  State<LarvaeCollectionViewScreen> createState() =>
      _LarvaeCollectionViewScreenState();
}

class _LarvaeCollectionViewScreenState
    extends State<LarvaeCollectionViewScreen> {
  List<dynamic> larvaeDetails = [];
  List<dynamic> filteredDetails = [];
  String? _userId = 'user 123';
  bool? _isLoading = false;
  bool isAdmin = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterDetails);
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchLarvaeDetails();
    await _getUserDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserDetails() async {
    setState(() {
      _userId = 'user 123';
      isAdmin = true;
    });
  }

  Future<void> _fetchLarvaeDetails() async {
    LarvaeCollectionService larvaeCollectionService = LarvaeCollectionService();
    try {
      List<dynamic> fetchedLarvaeDetails =
          await larvaeCollectionService.fetchLarvaeCollectionTanks();
      setState(() {
        larvaeDetails = fetchedLarvaeDetails;
        filteredDetails = fetchedLarvaeDetails;
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

  void _filterDetails() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      filteredDetails = larvaeDetails.where((larvae) {
        return larvae['employee_code']
                .toString()
                .toLowerCase()
                .contains(searchQuery) ||
            larvae['date'].toString().toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteLarvaeCollection(int index) async {
    final larvae = filteredDetails[index];
    int? larvaeCollectionId = larvae['id'];

    setState(() {
      larvaeDetails.remove(larvae);
      filteredDetails.removeAt(index);
    });

    try {
      LarvaeCollectionService larvaeCollectionService =
          LarvaeCollectionService();

      await larvaeCollectionService
          .deleteLarvaeCollectionTank(larvaeCollectionId!);
      _fetchLarvaeDetails();
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Activity/Larvae Collection',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading!
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

                // PaginatedDataTable
                larvaeDetails.isEmpty
                    ? const Center(child: Text('No Data Available'))
                    : Center(
                        child: SizedBox(
                          width: 1500,
                          child: PaginatedDataTable(
                            header: Center(
                              child: Text('User ID: $_userId'),
                            ),
                            columns: const [
                              DataColumn(label: Text('Employee Code')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Actions')),
                            ],
                            source: _LarvaeDataSource(
                              context: context,
                              larvaeDetails: filteredDetails,
                              isAdmin: isAdmin,
                              deleteLarvaeCollection: _deleteLarvaeCollection,
                            ),
                            rowsPerPage: 5,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}

class _LarvaeDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> larvaeDetails;
  final bool isAdmin;
  final Function(int) deleteLarvaeCollection;

  _LarvaeDataSource({
    required this.context,
    required this.larvaeDetails,
    required this.isAdmin,
    required this.deleteLarvaeCollection,
  });

  @override
  DataRow getRow(int index) {
    if (index >= larvaeDetails.length) return const DataRow(cells: []);
    final larvae = larvaeDetails[index];

    return DataRow(
      cells: [
        DataCell(Text(larvae['employee_code'])),
        DataCell(Text(larvae['date'])),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  final updatingData = {
                    "id": larvae['id'],
                    "date": larvae['date'],
                    // Add other relevant fields here
                  };
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LarvaeCollectionActivityScreen(
                        larvaeData: updatingData,
                        isEditing: true,
                      ),
                    ),
                  );
                },
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteLarvaeCollection(index),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => larvaeDetails.length;

  @override
  int get selectedRowCount => 0;
}
