import 'package:flutter/material.dart';

import 'package:gk_aqua/activities/Feeding_Screen.dart';
import 'package:gk_aqua/activities/HatcheryMortality_Screen.dart';
import 'package:gk_aqua/activities/ResponsiveFeeding_Screen.dart';
import 'package:gk_aqua/activities/WaterQualityCheck_Screen.dart';
import 'package:gk_aqua/masters/prawnStatus_Screen.dart';
import 'package:gk_aqua/modals/Mortality_Modal.dart';
import 'package:gk_aqua/modals/UpdatePrawnStatus_Modal.dart';
import 'package:gk_aqua/modals/UpdateTankStatus_Modal.dart';
import 'package:gk_aqua/screens/activities/BroodstockMortalityActivityScreen.dart';
import 'package:gk_aqua/screens/activities/HatcheryMortalityActivityScreen.dart';
import 'package:gk_aqua/screens/masters/department.dart';
import 'package:gk_aqua/screens/masters/employeeAddMasterScreen.dart';
import 'package:gk_aqua/screens/masters/unitMasterScreen.dart';
import 'package:gk_aqua/screens/masters/waterParametersMasterScreen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {},
        ),
        title: Text('GK AQUA Index'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('BroodstockIndex');
                  },
                  child: Text('BroodStock Index')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('AddMP');
                  },
                  child: Text('MP')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('AddFP');
                  },
                  child: Text('NFP')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('BroodingTanks');
                  },
                  child: Text('Brooding Tanks')),
              ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return const UpdateTankStatusModal(); // Call the modal
                      },
                    );
                  },
                  child: Text('Update tank status')),
              ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return const MortalityModal(); // Call the modal
                      },
                    );
                  },
                  child: Text('Mortality')),
              ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return const UpdateprawnstatusModal();
                        });
                  },
                  child: Text('Update Prawn Status')),
              const Row(
                children: [
                  Text(
                    "Responsive Masters",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PrawnstatusScreen();
                            }));
                          },
                          child: Text("Prawn Status")),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                children: [
                  Text(
                    "Activities",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return FeedingScreen();
                            }));
                          },
                          child: Text('Feeding')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return WaterQualityCheckScreen();
                            }));
                          },
                          child: Text('Water Quality Check')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    HatcheryMortalityScreen()));
                          },
                          child: Text("Hatchery Mortality")),
                      // ElevatedButton(
                      //     onPressed: () {
                      //       Navigator.of(context)
                      //           .push(MaterialPageRoute(builder: (context) {
                      //         return BuyBackScreen();
                      //       }));
                      //     },
                      //     child: Text("Buy Back"))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                children: [
                  Text(
                    "Responsive Activities",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Feeding();
                            }));
                          },
                          child: Text('Feeding')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Masters with API",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DepartmentScreen(),
                            ));
                          },
                          child: Text('Department')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return unitMasterScreen();
                          }));
                        },
                        child: Text("Units"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return Waterparameters();
                          }));
                        },
                        child: Text("Water Parameters"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return EmployeeAdd();
                            }));
                          },
                          child: Text("Employee Add")),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Activities with API",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BroodstockMortality(),
                            ));
                          },
                          child: Text('Broodstock Mortality')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return HatcheryMortality();
                            },
                          ));
                        },
                        child: Text('Hatchery Mortality'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
