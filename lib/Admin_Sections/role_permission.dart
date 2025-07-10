import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RolesPermissionsScreen extends StatefulWidget {
  final String role; // 🆕 Pass Role from previous screen

  const RolesPermissionsScreen({Key? key, required this.role}) : super(key: key);

  @override
  _RolesPermissionsScreenState createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  Map<String, bool> permissions = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    setState(() {
      isLoading = true;
    });

    final doc = await FirebaseFirestore.instance
        .collection('roles_permissions')
        .doc(widget.role)
        .get();

    if (doc.exists) {
      setState(() {
        permissions = Map<String, bool>.from(doc.data()!);
        isLoading = false;
      });
    } else {
      setState(() {
        // 🆕 Updated Modules List
        permissions = {
          'attendance': false,
          'leave_requests': false,
          'holiday_calendar': false,
          'time_sheet': false,
          'employee_details': false,
          'projects': false,
        };
        isLoading = false;
      });
    }
  }

  Future<void> savePermissions() async {
    await FirebaseFirestore.instance
        .collection('roles_permissions')
        .doc(widget.role)
        .set(permissions);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Permissions updated for ${widget.role}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions for ${widget.role}'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: permissions.keys.map((module) {
                return SwitchListTile(
                  title: Text(
                    module.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: permissions[module]!,
                  onChanged: (value) {
                    setState(() {
                      permissions[module] = value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: savePermissions,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
