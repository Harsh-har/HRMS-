import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hrms_project/Admin_Sections/admin_login.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const ProfileScreen({super.key, required this.employeeData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> employeeData;

  @override
  void initState() {
    super.initState();
    employeeData = widget.employeeData;
  }

  @override
  Widget build(BuildContext context) {
    final profileUrl = employeeData['profileImage']?.isNotEmpty == true
        ? employeeData['profileImage']
        : "https://randomuser.me/api/portraits/men/1.jpg";
    final name = employeeData['name'] ?? 'No Name Provided';
    final designation = employeeData['role'] ?? 'No Role';
    final empId = employeeData['employeeId'] ?? 'N/A';
    final department = employeeData['department'] ?? 'N/A';
    final email = employeeData['email'] ?? 'N/A';
    final phone = employeeData['phone'] ?? 'N/A';
    final dob = _formatDate(employeeData['dateOfBirth']);
    final joinDate = _formatDate(employeeData['joiningDate']);

    final gender = employeeData['gender'] ?? 'N/A';
    final address = employeeData['address'] ?? 'N/A';
    final employmentType = employeeData['employmentType'] ?? 'N/A';
    final salary = employeeData['salary']?.toString() ?? 'N/A';
    final status = employeeData['status'] ?? 'N/A';

    final emergencyContactName = employeeData['emergencyContactName'] ?? 'N/A';
    final emergencyContactRelation =
        employeeData['emergencyContactRelation'] ?? 'N/A';
    final emergencyContactPhone =
        employeeData['emergencyContactPhone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF002147),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
                  _buildDetailItem(Icons.person_outline, 'Gender', gender),
                  _buildDetailItem(Icons.location_on, 'Address', address),
                ]),
                const SizedBox(height: 16),
                _buildSection('Company Details', [
                  _buildDetailItem(Icons.business, 'Department', department),
                  _buildDetailItem(Icons.work, 'Role', designation),
                  _buildDetailItem(Icons.event, 'Join Date', joinDate),
                  _buildDetailItem(Icons.access_time, 'Employment Type', employmentType),
                  _buildDetailItem(Icons.monetization_on, 'Salary', '₹ $salary'),
                  _buildDetailItem(Icons.verified_user, 'Status', status),
                ]),
                const SizedBox(height: 16),
                _buildSection('Emergency Contact', [
                  _buildDetailItem(Icons.contact_emergency, 'Name', emergencyContactName),
                  _buildDetailItem(Icons.person, 'Relation', emergencyContactRelation),
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
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profileUrl),
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, size: 18, color: Colors.blue),
              ),
            ],
          ),
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
            style: TextStyle(
                color: Colors.blue[900], fontWeight: FontWeight.w600),
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
      title: Text(label,
          style: const TextStyle(fontSize: 13, color: Colors.black54)),
      subtitle:
      Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final employeeId = employeeData['employeeId'] ?? '';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$employeeId.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .update({'profileImage': downloadUrl});

      setState(() {
        employeeData['profileImage'] = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated!')),
      );
    }
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
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
