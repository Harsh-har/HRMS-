import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Employee_Sections/UserTimesheetScreen.dart';
import 'emp_managment.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  @override
  _EmployeeListPageState createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Stream<QuerySnapshot> getEmployeesStream() {
    return FirebaseFirestore.instance.collection('employees').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterEmployees(
      List<QueryDocumentSnapshot> employees, String query) {
    if (query.isEmpty) return employees;

    return employees.where((employee) {
      final data = employee.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? '';
      final designation = data['designation']?.toString().toLowerCase() ?? '';
      final id = data['employeeId']?.toString().toLowerCase() ?? '';
      final email = data['email']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          designation.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee List"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeForm(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        tooltip: "Add Employee",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search by name, ID, email or designation",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getEmployeesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final filteredEmployees =
                _filterEmployees(snapshot.data!.docs, _searchQuery);

                if (filteredEmployees.isEmpty) {
                  return Center(child: Text("No matching employees found."));
                }

                return ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final data = filteredEmployees[index].data()
                    as Map<String, dynamic>;

                    return Card(
                      margin:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                          NetworkImage(data['profileImage'] ?? ''),
                        ),
                        title: Text(data['name'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${data['employeeId'] ?? 'N/A'}'),
                            Text('Email: ${data['email'] ?? 'N/A'}'),
                            Text(data['designation'] ?? 'No Designation'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserTimesheetScreen(
                                employeeData: {
                                  'name': data['name'],
                                  'employeeId': data['employeeId'],
                                  'email': data['email'],
                                  'profileImage': data['profileImage'],
                                  'designation': data['designation'],
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
