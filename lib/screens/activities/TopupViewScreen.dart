import 'package:flutter/material.dart';
import 'package:gk_aqua/services/topup_services.dart';

class TopupView extends StatelessWidget {
  const TopupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TopupViewScreen(),
    );
  }
}

class TopupViewScreen extends StatefulWidget {
  TopupViewScreen({super.key});

  @override
  State<TopupViewScreen> createState() => _TopupViewScreenState();
}

class _TopupViewScreenState extends State<TopupViewScreen> {
  String? _userId;
  List<Map<String, dynamic>> topupList = [];

  bool _isAdmin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  //fetch datas
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

  //Get user details
  Future<void> _getUserDetails() async {
    setState(() {
      _userId = "user123";
      _isAdmin = true;
    });
  }

  // Get all topups
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
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Delete topup
  Future<void> _deleteTopup(int index) async {
    final Map<String, dynamic> selectedTopup = topupList[index];
    int? topupId = selectedTopup['id'];

    setState(() {
      topupList.removeAt(index);
    });

    try {
      TopupService topupService = TopupService();
      await topupService.deleteTopup(topupId!);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Deleted'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Topup deleted successfully!'),
                )
              ],
            );
          });

      getTopupList();
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Something went wrong'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(e.toString()),
                )
              ],
            );
          });

      setState(() {
        topupList.insert(index, selectedTopup);
      });
    }
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
                  _deleteTopup(index!);
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
          'Activity/Topup View',
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
          : topupList.isEmpty
              ? const Center(child: Text('No topups'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text('User ID: $_userId',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topupList.length,
                        itemBuilder: (context, index) {
                          final topup = topupList[index];
                          return Card(
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text(
                                            'Topup Date : ${topup['date']}'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            // Using ListBody for structured and scrollable content
                                            children: [
                                              Text(
                                                  'Employee Code : ${topup['employee_code']}'),
                                              SizedBox(height: 5),
                                              Text(
                                                'Topup Department : ${topup['department']['department_name']}',
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                  'Topup Divison : ${topup['division']['division_name']}'),
                                              SizedBox(height: 5),
                                              Text(
                                                  'Topup Tank : ${topup['tank']['tank_name']}'),
                                              const SizedBox(height: 5),
                                              Text(
                                                  'Male Mortality Count : ${topup['male_prawn_mortality_count']}'),
                                              const SizedBox(height: 5),
                                              Text(
                                                  'Female Mortality Count : ${topup['female_prawn_mortality_count']}'),
                                              const SizedBox(height: 5),
                                              Text(
                                                  'Male Topup Count : ${topup['male_prawn_topup_count']}'),
                                              const SizedBox(height: 5),
                                              Text(
                                                  'Female Topup Count : ${topup['female_prawn_topup_count']}'),
                                              SizedBox(height: 5),
                                              Text('Notes : ${topup['notes']}'),
                                            ],
                                          ),
                                        ));
                                  },
                                );
                              },
                              title: Text(
                                'Date: ${topup['date'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      'Male Prawn Topup: ${topup['male_prawn_topup_count'] ?? 'N/A'}'),
                                  Text(
                                      'Female Prawn Topup: ${topup['male_prawn_topup_count'] ?? 'N/A'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Edit
                                    },
                                  ),
                                  _isAdmin
                                      ? IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            // delete
                                            _showConfirmationDialog(
                                                purpose: "Delete",
                                                index: index);
                                          },
                                        )
                                      : const SizedBox(width: 0)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
