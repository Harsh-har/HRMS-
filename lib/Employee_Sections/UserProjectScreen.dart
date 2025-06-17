import 'package:flutter/material.dart';

class UserProjectScreen extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const UserProjectScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    final name = employeeData['name'] ?? 'Employee';

    return Scaffold(
      appBar: AppBar(
        title: Text("$name's Projects"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text("Project list for $name", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
