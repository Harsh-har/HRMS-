import 'package:flutter/material.dart';
import 'package:hrms_project/login.dart';
import 'package:hrms_project/servicr.dart';
import 'package:hrms_project/splashscreen.dart';

import 'homescreen.dart'; // Make sure this file exists

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  SplashScreen()
    );
  }
}