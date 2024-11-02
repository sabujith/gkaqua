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

  String? _userId;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    getBroodstockMortalityList();
    getUserDetails();
  }

  //get user details
  Future<void> getUserDetails() async {
    // var user = await ApiDepartment.getUserDetails();
    setState(() {
      _userId = "User 123";
      _isAdmin = true;
    });
  }

  //Get all Broodstock Mortality Details
  Future<void> getBroodstockMortalityList() async {
    BroodstockMortalityService broodstockMortalityService =
        BroodstockMortalityService();

    try {
      var response = await broodstockMortalityService.getAllMortality();
      setState(() {
        broodstockMortalityList = response;
      });
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
                  _deleteMortality(index!);
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

  //delete broodstock mortality
  Future<void> _deleteMortality(int index) async {
    final Map<String, dynamic> selectedMortality =
        broodstockMortalityList[index];

    int? mortalityId = selectedMortality['id'];

    setState(() {
      broodstockMortalityList.removeAt(index);
    });

    try {
      BroodstockMortalityService broodstockMortalityService =
          BroodstockMortalityService();

      await broodstockMortalityService.deleteMortality(mortalityId!);
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
                  child: Text('Broodstock Mortality deleted successfully!'),
                ),
              ],
            );
          });

      getBroodstockMortalityList();
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
        broodstockMortalityList.insert(index, selectedMortality);
      });
    }
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
          'Activity/Broodstock-Mortality View',
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
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //User id Row
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('User Id : ${_userId}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
              SizedBox(height: 10),

              //Broodstock Mortality List
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: broodstockMortalityList.length,
                  itemBuilder: (context, index) {
                    final item = broodstockMortalityList[index];
                    return Card(
                      child: ListTile(
                        onTap: () {
                          // show Mortality details as a dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text('Date : ${item['date']}'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      // Using ListBody for structured and scrollable content
                                      children: [
                                        Text(
                                            'Employee Code : ${item['employee_code']}'),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Department : ${item['department']['department_name']}',
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Division : ${item['division']['division_name']}'),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Tank : ${item['tank']['tank_name']}'),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Male Prawns mortality count : ${item['male_prawn_count']}'),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Female Prawns mortality count : ${item['female_prawn_count']}'),
                                        const SizedBox(height: 5),
                                        Text('Notes : ${item['notes']}'),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  ));
                            },
                          );
                        },
                        title: Text('Date : ${item['date']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Male mortality count : ${item['male_prawn_count']}'),
                            Text(
                                'Female mortality count : ${item['female_prawn_count']}'),
                          ],
                        ),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              final departmentData = item['department'];
                              final Department department =
                                  Department.fromJson(departmentData);

                              final divisionData = item['division'];
                              final DivisionModel division =
                                  DivisionModel.fromJson(divisionData);

                              final tankData = item['tank'];
                              final TankModel tank =
                                  TankModel.fromJson(tankData);

                              final Map<String, dynamic> updatingData = {
                                'id': item['id'],
                                'date': item['date'],
                                'divisionId': division.id,
                                // 'departmentId': department.id,
                                'tankId': tank.id,
                                'malePrawn': item['male_prawn_count'],
                                'femalePrawn': item['female_prawn_count'],
                                'notes': item['notes']
                              };

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return BroodstockMortalityActivityScreen(
                                    broodstockMortalityData: updatingData,
                                    isEditing: true,
                                  );
                                },
                              ));
                            },
                          ),
                          _isAdmin!
                              ? IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(
                                        purpose: "Delete", index: index);
                                  },
                                  icon: const Icon(Icons.delete))
                              : const SizedBox(width: 0)
                        ]),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
