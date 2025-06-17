import 'package:flutter/material.dart';

class UserPerformanceScreen extends StatelessWidget {
  final String employeeName;

  const UserPerformanceScreen({super.key, required this.employeeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Performance Review")),
      body: Center(
        child: Text("Performance data for $employeeName coming soon!"),
      ),
    );
  }
}
