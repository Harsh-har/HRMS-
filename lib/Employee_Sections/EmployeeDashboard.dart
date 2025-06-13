import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hrms_project/Employee_Sections/AttendanceScreen.dart';
import 'package:hrms_project/Employee_Sections/ProfileScreen.dart';
import 'package:hrms_project/Employee_Sections/LeaveRequestScreen.dart'; // Correctly import the updated leave screen

class EmployeeDashboard extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const EmployeeDashboard({super.key, required this.employeeData});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _isCheckedIn = false;
  int _currentIndex = 0;

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

  String _getGreetingWithDate() {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    String formattedDate = DateFormat('d MMMM yyyy').format(now);
    return "$greeting, $formattedDate";
  }

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

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AttendanceScreen(employeeData: widget.employeeData)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SubmitLeaveRequestPage(employeeData: widget.employeeData),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProfileScreen(employeeData: widget.employeeData),
        ),
      );
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = widget.employeeData['name'] ?? 'Employee';
    final profileUrl = widget.employeeData['profileUrl'] ??
        "https://randomuser.me/api/portraits/men/1.jpg";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreetingWithDate(),
                            style:
                            TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            employeeName,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(profileUrl),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: FloatingActionButton.extended(
                  onPressed: _handleCheckInOut,
                  backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
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
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Recent Activities",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Leave Approved"),
                      subtitle: Text("Sick leave for June 10–12"),
                      trailing:
                      Text("Today", style: TextStyle(color: Colors.grey)),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.notifications, color: Colors.orange),
                      title: Text("New Announcement"),
                      subtitle: Text("Office closed on July 4"),
                      trailing: Text("Yesterday",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[500],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: "Attendance"),
          BottomNavigationBarItem(
              icon: Icon(Icons.leave_bags_at_home), label: "Leave"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
