import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HrProfile extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const HrProfile({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    final profileUrl = employeeData['profileImage']?.toString().isNotEmpty == true
        ? employeeData['profileImage']
        : "https://randomuser.me/api/portraits/men/1.jpg";

    final name = employeeData['name'] ?? 'No Name Provided';
    final role = employeeData['role'] ?? 'N/A';
    final empId = employeeData['employeeId'] ?? 'N/A';
    final department = employeeData['department'] ?? 'N/A';
    final email = employeeData['email'] ?? 'N/A';
    final phone = employeeData['phone'] ?? 'N/A';
    final dob = _formatDate(employeeData['dateOfBirth']);
    final joinDate = _formatDate(employeeData['joiningDate']);
    final address = employeeData['address'] ?? 'N/A';
    final gender = employeeData['gender'] ?? 'N/A';
    final employmentType = employeeData['employmentType'] ?? 'N/A';
    final salary = employeeData['salary']?.toString() ?? 'N/A';
    final status = employeeData['status'] ?? 'N/A';
    final emergencyContactName = employeeData['emergencyContactName'] ?? 'N/A';
    final emergencyContactRelation = employeeData['emergencyContactRelation'] ?? 'N/A';
    final emergencyContactPhone = employeeData['emergencyContactPhone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Profile'),
        backgroundColor: const Color(0xFFFFFFFF),
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
                _buildProfileHeader(profileUrl, name, role, empId, status),
                const SizedBox(height: 24),
                _buildSection('Personal Details', [
                  _buildDetailItem(Icons.person, 'Full Name', name),
                  _buildDetailItem(Icons.email, 'Email', email),
                  _buildDetailItem(Icons.phone, 'Phone', phone),
                  _buildDetailItem(Icons.cake, 'Date of Birth', dob),
                  _buildDetailItem(Icons.male, 'Gender', gender),
                  _buildDetailItem(Icons.location_on, 'Address', address),
                ]),
                const SizedBox(height: 16),
                _buildSection('Company Details', [
                  _buildDetailItem(Icons.business, 'Department', department),
                  _buildDetailItem(Icons.badge, 'Role', role),
                  _buildDetailItem(Icons.event, 'Join Date', joinDate),
                  _buildDetailItem(Icons.work_history, 'Employment Type', employmentType),
                  _buildDetailItem(Icons.attach_money, 'Salary', '₹ $salary'),
                  _buildDetailItem(Icons.verified, 'Status', status),
                ]),
                const SizedBox(height: 16),
                _buildSection('Emergency Contact', [
                  _buildDetailItem(Icons.contact_emergency, 'Name', emergencyContactName),
                  _buildDetailItem(Icons.group, 'Relation', emergencyContactRelation),
                  _buildDetailItem(Icons.phone, 'Phone', emergencyContactPhone),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String profileUrl, String name, String role, String empId, String status) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(profileUrl),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(role, style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 8),
        Chip(
          backgroundColor: status == 'inactive' ? Colors.red[100] : Colors.green[100],
          label: Text('Status: ${status.toUpperCase()}',
              style: TextStyle(
                color: status == 'inactive' ? Colors.red[900] : Colors.green[900],
                fontWeight: FontWeight.bold,
              )),
        ),
        const SizedBox(height: 8),
        Chip(
          backgroundColor: Colors.yellow[100],
          label: Text('ID: $empId',
              style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600)),
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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

  String _formatDate(dynamic dateData) {
    if (dateData == null) return 'N/A';
    try {
      DateTime date;
      if (dateData is String) {
        date = DateTime.tryParse(dateData) ?? DateTime(2000);
      } else if (dateData is Timestamp) {
        date = dateData.toDate();
      } else if (dateData is DateTime) {
        date = dateData;
      } else {
        return 'Invalid';
      }
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
