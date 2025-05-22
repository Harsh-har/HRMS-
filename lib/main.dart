import 'package:flutter/material.dart';
import 'package:hrms_project/Admin_Sections/splashscreen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // or HomeScreen()
    );
  }
}
