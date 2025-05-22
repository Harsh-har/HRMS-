import 'package:flutter/material.dart';


class AdminProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Edit profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Section
            _buildProfileHeader(),
            SizedBox(height: 24),

            // Basic Information Section
            _buildSectionTitle('Basic Information'),
            _buildInfoCard(
              children: [
                _buildInfoRow(Icons.person, 'Employee ID', 'EMP-1006'),
                _buildInfoRow(Icons.work, 'Job Title', 'CEO'),
                _buildInfoRow(Icons.group, 'Department', 'Admin'),
                _buildInfoRow(Icons.calendar_today, 'Join Date', '15 Oct 2024'),
              ],
            ),

            // Contact Information Section
            _buildSectionTitle('Contact Information'),
            _buildInfoCard(
              children: [
                _buildInfoRow(Icons.email, 'Work Email', 'pradeep@gmail.com'),
                _buildInfoRow(Icons.phone, 'Phone', '+91 7895037479  '),
                _buildInfoRow(Icons.location_on, 'Work Location', 'Noida  Sector 132'),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/profile/adminimage.jpg'),
        ),
        SizedBox(height: 16),
        Text(
          'Pradeep Tamar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'CEO',
          style: TextStyle(fontSize: 16, color: Colors.grey,fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




}