import 'package:flutter/material.dart';

import 'AttendanceScreen.dart';
import 'ProfileScreen.dart';

class EmployeeDashboard extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const EmployeeDashboard({super.key, required this.employeeData});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _isCheckedIn = false;
  int _currentIndex = 0;

  // Handle Check-In/Out
  void _handleCheckInOut() {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCheckedIn ? "Checked In Successfully" : "Checked Out"),
      ),
    );
  }

  // Build Stat Card Widget
  Widget _buildStatCard(String value, String label, IconData icon) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue[600], size: 24),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Navigation Handler
  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AttendanceScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(employeeId: widget.employeeData['employeeId']),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final employeeName = widget.employeeData['name'] ?? 'Employee';
    final profileUrl = widget.employeeData['profileUrl'] ??
        "https://randomuser.me/api/portraits/men/1.jpg";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Welcome Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Good Morning,",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        SizedBox(height: 4),
                        Text(employeeName,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(profileUrl),
                    ),
                  ],
                ),
              ),

              // Check-In/Out Button
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: FloatingActionButton.extended(
                  onPressed: _handleCheckInOut,
                  backgroundColor: Colors.blue[600],
                  elevation: 0,
                  label: Text(
                    _isCheckedIn ? "CHECK OUT" : "CHECK IN",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(
                    _isCheckedIn ? Icons.logout : Icons.login,
                    color: Colors.white,
                  ),
                ),
              ),

              // Stats Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.8,
                  children: [
                    _buildStatCard("12", "Leave Days", Icons.calendar_today),
                    _buildStatCard("95%", "Attendance", Icons.percent),
                    _buildStatCard("June", "Payslip", Icons.attach_money),
                  ],
                ),
              ),

              // Recent Activities
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Recent Activities",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Leave Approved"),
                      subtitle: Text("Sick leave for June 10-12"),
                      trailing: Text("Today", style: TextStyle(color: Colors.grey)),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.notifications, color: Colors.orange),
                      title: Text("New Announcement"),
                      subtitle: Text("Office closed on July 4"),
                      trailing: Text("Yesterday", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[500],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.leave_bags_at_home), label: "Leave"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
