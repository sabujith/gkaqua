import 'package:flutter/material.dart';
import 'package:gk_aqua/activities/Feeding_Screen.dart';
import 'package:gk_aqua/activities/WaterQualityCheck_Screen.dart';
import 'package:gk_aqua/masters/prawnStatus_Screen.dart';
import 'package:gk_aqua/modals/Mortality_Modal.dart';
import 'package:gk_aqua/modals/UpdatePrawnStatus_Modal.dart';
import 'package:gk_aqua/modals/UpdateTankStatus_Modal.dart';

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
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return PrawnstatusScreen();
                    }));
                  },
                  child: Text('Masters - Prawn Status')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return FeedingScreen();
                    }));
                  },
                  child: Text('Activity - Feeding')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return WaterQualityCheckScreen();
                    }));
                  },
                  child: Text('Activity - Water Quality Check'))
            ],
          ),
        ),
      ),
    );
  }
}
