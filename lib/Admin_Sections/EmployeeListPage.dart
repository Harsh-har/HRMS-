import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return FirebaseFirestore.instance.collection('employees').limit(10).snapshots();
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
      return name.contains(query.toLowerCase()) || designation.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee List"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeeForm()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
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
                hintText: "Search by name or designation",
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

                final filteredEmployees = _filterEmployees(snapshot.data!.docs, _searchQuery);

                if (filteredEmployees.isEmpty) {
                  return Center(child: Text("No matching employees found."));
                }

                return ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final data = filteredEmployees[index].data() as Map<String, dynamic>;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['profileImage'] ?? ''),
                      ),
                      title: Text(data['name'] ?? 'No Name'),
                      subtitle: Text(data['designation'] ?? 'No Designation'),
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
