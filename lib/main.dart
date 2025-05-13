import 'package:flutter/material.dart';
import 'package:hrms_project/servicr.dart'; // Make sure this file exists

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  EmployeeApp(), // Replace with actual widget class in servicr.dart
    );
  }
}
