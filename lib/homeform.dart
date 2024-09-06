import 'package:flutter/material.dart';

class HomeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // BROODSTOCK Button
            ElevatedButton(
              onPressed: () {
                // Add navigation or functionality for BROODSTOCK
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text('BROODSTOCK'),
            ),
            SizedBox(height: 20),
            // HATCHERY Button
            ElevatedButton(
              onPressed: () {
                // Add navigation or functionality for HATCHERY
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text('HATCHERY'),
            ),
            SizedBox(height: 20),
            // FEED STOCK Button
            ElevatedButton(
              onPressed: () {
                // Add navigation or functionality for FEED STOCK
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text('FEED STOCK'),
            ),
          ],
        ),
      ),
    );
  }
}
