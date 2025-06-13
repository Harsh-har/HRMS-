import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const ProfileScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
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
    final emergencyContactRelation =
        employeeData['emergencyContactRelation'] ?? 'N/A';
    final emergencyContactPhone =
        employeeData['emergencyContactPhone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF002147), // Dark blue
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002147), Color(0xFF01497C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(profileUrl, name, designation, empId),
                const SizedBox(height: 24),
                _buildSection('Personal Details', [
                  _buildDetailItem(Icons.person, 'Full Name', name),
                  _buildDetailItem(Icons.email, 'Email', email),
                  _buildDetailItem(Icons.phone, 'Phone', phone),
                  _buildDetailItem(Icons.cake, 'Date of Birth', dob),
                ]),
                const SizedBox(height: 16),
                _buildSection('Company Details', [
                  _buildDetailItem(Icons.business, 'Department', department),
                  _buildDetailItem(Icons.work, 'Designation', designation),
                  _buildDetailItem(Icons.event, 'Join Date', joinDate),
                  _buildDetailItem(Icons.access_time, 'Work Hours', workHours),
                ]),
                const SizedBox(height: 16),
                _buildSection('Emergency Contact', [
                  _buildDetailItem(
                      Icons.contact_emergency, 'Name', emergencyContactName),
                  _buildDetailItem(Icons.person, 'Relation',
                      emergencyContactRelation),
                  _buildDetailItem(Icons.phone, 'Phone', emergencyContactPhone),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      String profileUrl, String name, String designation, String empId) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(profileUrl),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          designation,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Chip(
          backgroundColor: Colors.yellow[100],
          label: Text(
            'ID: $empId',
            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Navigate back or go to login
              // Add any logout logic like clearing session/token here
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
