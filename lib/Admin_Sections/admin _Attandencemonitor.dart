import 'package:flutter/material.dart';

class AttendanceMonitoringScreen extends StatelessWidget {
  final List<Map<String, String>> attendanceData = [
    {
      'name': 'Harsh Singhal',
      'status': 'Present',
      'checkIn': '09:30 AM',
      'checkOut': '06:00 PM',
      'profileImage': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Mayank Singh',
      'status': 'Late',
      'checkIn': '10:05 AM',
      'checkOut': '06:00 PM',
      'profileImage': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Varun',
      'status': 'Present',
      'checkIn': '09:30 AM',
      'checkOut': '06:00 PM',
      'profileImage': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Abhay Singh',
      'status': 'Late',
      'status': 'Absent',
      'checkIn': '-',
      'checkOut': '-',
      'profileImage': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Ansh Sharma',
      'status': 'Absent',
      'checkIn': '-',
      'checkOut': '-',
      'profileImage': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Swastika',
      'status': 'Present',
      'checkIn': '09:30 AM',
      'checkOut': '06:00 PM',
      'profileImage': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Anshika',
      'status': 'Present',
      'checkIn': '09:30 AM',
      'checkOut': '06:00 PM',
      'profileImage': 'https://via.placeholder.com/150'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Attendance Monitoring'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Total', '9', Colors.blue),
                _buildSummaryCard('Present', '4', Colors.green),
                _buildSummaryCard('Late', '1', Colors.orange),
                _buildSummaryCard('Absent', '2', Colors.red),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attendanceData.length,
              itemBuilder: (context, index) {
                final emp = attendanceData[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(emp['profileImage']!),
                    ),
                    title: Text(emp['name']!),
                    subtitle: Text(
                      'In: ${emp['checkIn']}   Out: ${emp['checkOut']}',
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: Chip(
                      label: Text(emp['status']!),
                      backgroundColor: emp['status'] == 'Present'
                          ? Colors.green[100]
                          : emp['status'] == 'Late'
                          ? Colors.orange[100]
                          : Colors.red[100],
                      labelStyle: TextStyle(
                        color: emp['status'] == 'Present'
                            ? Colors.green
                            : emp['status'] == 'Late'
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.person, color: color),
        ),
        SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}