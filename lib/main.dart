import 'package:flutter/material.dart';
import 'package:gk_aqua/Index_Screen.dart';
import 'package:gk_aqua/screens/BroodStockIndex_Screen.dart';
import 'package:gk_aqua/screens/BroodingTanks_Screen.dart';

//importing pages
import 'package:gk_aqua/screens/MalePrawnEntry_Screen.dart';
import 'package:gk_aqua/screens/FemalePrawnEntry_Screren.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.blue),
        ),
      ),
      home: IndexScreen(),
      routes: {
        'AddMP': (context) {
          return MalePrawnScreen();
        },
        'AddFP': (context) {
          return FemalePrawnScreen();
        },
        'BroodstockIndex': (context) {
          return BroodstockindexScreen();
        },
        'BroodingTanks': (context) {
          return BroodingtanksScreen();
        },
      },
    );
  }
}
