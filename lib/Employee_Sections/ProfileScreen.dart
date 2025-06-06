import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final String employeeId;

  const ProfileScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('employees').doc(employeeId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Employee data not found'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'My Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Profile Picture and Basic Info
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            data['profileUrl'] ?? 'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          data['name'] ?? 'N/A',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['designation'] ?? 'N/A',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Chip(
                          backgroundColor: Colors.blue[50],
                          label: Text(
                            data['employeeId'] ?? 'EMP-ID',
                            style: TextStyle(color: Colors.blue[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Personal Details
                  _buildSectionHeader('Personal Details'),
                  _buildDetailItem(Icons.person, 'Full Name', data['name']),
                  _buildDetailItem(Icons.email, 'Email', data['email']),
                  _buildDetailItem(Icons.phone, 'Phone', data['phone']),
                  _buildDetailItem(Icons.cake, 'Date of Birth', data['dob']),

                  SizedBox(height: 24),

                  // Company Details
                  _buildSectionHeader('Company Details'),
                  _buildDetailItem(Icons.business, 'Department', data['department']),
                  _buildDetailItem(Icons.work, 'Designation', data['designation']),
                  _buildDetailItem(Icons.event, 'Join Date', data['joinDate']),
                  _buildDetailItem(Icons.access_time, 'Work Hours', data['workHours']),

                  SizedBox(height: 24),

                  // Emergency Contact
                  _buildSectionHeader('Emergency Contact'),
                  _buildDetailItem(Icons.contact_emergency, 'Name', data['emergencyContactName']),
                  _buildDetailItem(Icons.group, 'Relation', data['emergencyContactRelation']),
                  _buildDetailItem(Icons.phone, 'Phone', data['emergencyContactPhone']),
                ],
              ),
            );
          },
        ),
      ),

      // Edit Profile Floating Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Edit Profile Screen if needed
        },
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, dynamic value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(label, style: TextStyle(color: Colors.grey[600])),
      subtitle: Text(value ?? 'N/A', style: TextStyle(fontSize: 16)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
