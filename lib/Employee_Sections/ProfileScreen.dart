import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const ProfileScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    // Use null-aware operators so if some data is missing, no crash ho
    final profileUrl = employeeData['profileUrl'] ??
        "https://randomuser.me/api/portraits/men/1.jpg";
    final name = employeeData['name'] ?? 'No Name Provided';
    final designation = employeeData['designation'] ?? 'No Designation';
    final empId = employeeData['employeeId'] ?? 'N/A';
    final department = employeeData['department'] ?? 'N/A';
    final email = employeeData['email'] ?? 'N/A';
    final phone = employeeData['phone'] ?? 'N/A';
    final dob = employeeData['dob'] ?? 'N/A';
    final joinDate = employeeData['joinDate'] ?? 'N/A';
    final workHours = employeeData['workHours'] ?? 'N/A';
    final emergencyContactName = employeeData['emergencyContactName'] ?? 'N/A';
    final emergencyContactRelation = employeeData['emergencyContactRelation'] ?? 'N/A';
    final emergencyContactPhone = employeeData['emergencyContactPhone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blue[600],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profileUrl),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  designation,
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                ),
              ),
              Center(
                child: Chip(
                  backgroundColor: Colors.blue[50],
                  label: Text(
                    empId,
                    style: TextStyle(color: Colors.blue[800], fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 32),

              _buildSectionHeader('Personal Details'),
              _buildDetailItem(Icons.person, 'Full Name', name),
              _buildDetailItem(Icons.email, 'Email', email),
              _buildDetailItem(Icons.phone, 'Phone', phone),
              _buildDetailItem(Icons.cake, 'Date of Birth', dob),
              SizedBox(height: 24),

              _buildSectionHeader('Company Details'),
              _buildDetailItem(Icons.business, 'Department', department),
              _buildDetailItem(Icons.work, 'Designation', designation),
              _buildDetailItem(Icons.event, 'Join Date', joinDate),
              _buildDetailItem(Icons.access_time, 'Work Hours', workHours),
              SizedBox(height: 24),

              _buildSectionHeader('Emergency Contact'),
              _buildDetailItem(Icons.contact_emergency, 'Name', emergencyContactName),
              _buildDetailItem(Icons.person, 'Relation', emergencyContactRelation),
              _buildDetailItem(Icons.phone, 'Phone', emergencyContactPhone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(label, style: TextStyle(color: Colors.grey[600])),
      subtitle: Text(value, style: TextStyle(fontSize: 16)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
