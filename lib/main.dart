import 'package:flutter/material.dart';
import 'package:gk_aqua/Index_Screen.dart';
import 'package:gk_aqua/screens/BroodStockIndex_Screen.dart';

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
        }
      },
    );
  }
}
