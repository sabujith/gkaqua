import 'package:flutter/material.dart';

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
                  child: Text('Brooding Tanks'))
            ],
          ),
        ),
      ),
    );
  }
}
