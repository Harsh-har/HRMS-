import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrms_project/Admin_Sections/EmployeeDetailsView.dart';
import 'package:hrms_project/Admin_Sections/role_permission.dart';

import 'emp_managment.dart'; // Assuming this is where EmployeeForm is

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  @override
  _EmployeeListPageState createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Stream<QuerySnapshot> getEmployeesStream() {
    return FirebaseFirestore.instance.collection('employees').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterEmployees(List<QueryDocumentSnapshot> employees, String query) {
    if (query.isEmpty) return employees;

    return employees.where((employee) {
      final data = employee.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? '';
      final department = data['department']?.toString().toLowerCase() ?? '';
      final id = data['employeeId']?.toString().toLowerCase() ?? '';
      final email = data['email']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          department.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee List"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeForm()));
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
                prefixIcon: const Icon(Icons.search),
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
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredEmployees = _filterEmployees(snapshot.data!.docs, _searchQuery);

                if (filteredEmployees.isEmpty) {
                  return const Center(child: Text("No matching employees found."));
                }

                return ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final doc = filteredEmployees[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            data['profileImage']?.toString().isNotEmpty == true
                                ? data['profileImage']
                                : 'https://randomuser.me/api/portraits/men/1.jpg',
                          ),
                        ),
                        title: Text(data['name'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${data['employeeId'] ?? 'N/A'}'),
                            Text('Email: ${data['email'] ?? 'N/A'}'),
                            Text('Department: ${data['department'] ?? 'No department'}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'view_details') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Employeedetailsview(
                                    employeeId: data['employeeId'], // 🔄 PASS ONLY ID
                                  ),
                                ),
                              );
                            } else if (value == 'manage_permissions') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RolesPermissionsScreen(
                                    role: data['role'] ?? 'HR', // 🔄 Pass current role
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view_details',
                              child: Text('View Details'),
                            ),
                            const PopupMenuItem(
                              value: 'manage_permissions',
                              child: Text('Manage Role Permissions'),
                            ),
                          ],
                        ),
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
