import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mating_tank_form.dart'; 
import 'mating_tank.dart';// Ensure this path matches your project structure
import 'homeform.dart';
import 'locationform.dart';
import 'pondform.dart';
import 'feedingform.dart';
import 'statusform.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: MatingForm(),
        // home: MatingTankForm()  
        //  home: HomeForm(),   
          // home: MatingTankForm(),  
      // home: LocationForm(), 
      //  home: PondForm(),
      home: FeedForm(),
      // home: StatusForm,
        // home: StatusForm(),
    );
  }
}

