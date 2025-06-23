import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AttendanceScreen.dart';
import 'HolidayCalendarUserScreen.dart';
import 'LeaveRequestScreen.dart';
import 'UserPerformanceScreen.dart';
import 'UserProjectScreen.dart';
import 'UserTimesheetScreen.dart';
import 'ProfileScreen.dart';


class EmployeeDashboard extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const EmployeeDashboard({super.key, required this.employeeData});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _isCheckedIn = false;
  int _currentIndex = 0;
  bool _isDarkMode = false;

  void _handleCheckInOut() {
    setState(() => _isCheckedIn = !_isCheckedIn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isCheckedIn ? "Checked In Successfully" : "Checked Out")),
    );
  }

  String _getGreetingWithDate() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    return "$greeting, ${DateFormat('d MMMM yyyy').format(now)}";
  }

  void _navigateToPage(int index) {
    Widget? destination;
    switch (index) {
      case 1:
        destination =  NewAttendanceScreen(employeeData: widget.employeeData);
        break;
      case 2:
        destination = UserProjectScreen(employeeData: widget.employeeData);
        break;
      case 3:
        destination = UserTimesheetScreen (employeeData: widget.employeeData);
        break;
    }

    if (destination != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: destination,
          ),
        ),
      );
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = widget.employeeData['name'] ?? 'Employee';
    final profileUrl = widget.employeeData['profileUrl'] ??
        "https://randomuser.me/api/portraits/men/1.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Replace with your notification page if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No new notifications")),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(profileUrl),
                ),
                accountName: Text(employeeName),
                accountEmail: Text(widget.employeeData['email'] ?? ''),
              ),
              _drawerItem(Icons.home, 'Dashboard', () {
                Navigator.pop(context);
              }),
              _drawerItem(Icons.calendar_today, 'Holiday Calendar', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => HolidayCalendarUserScreen()));
              }),
              _drawerItem(Icons.person, 'Profile', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(employeeData: widget.employeeData),
                  ),
                );
              }),
              _drawerItem(Icons.request_page, 'Leave', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SubmitLeaveRequestPage(employeeData: widget.employeeData)),
                );
              }),
              _drawerItem(Icons.assessment, 'Performance', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserPerformanceScreen(employeeName: employeeName),
                  ),
                );
              }),
              SwitchListTile(
                value: _isDarkMode,
                onChanged: (val) => setState(() => _isDarkMode = val),
                title: Text("Dark Mode", style: TextStyle(color: Colors.white)),
                secondary: Icon(Icons.dark_mode, color: Colors.white),
              ),
              if (widget.employeeData['role'] == 'admin') ...[
                Divider(color: Colors.white),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Admin Tools", style: TextStyle(color: Colors.white70)),
                ),
                _drawerItem(Icons.people, 'Manage Employees', () {}),
                _drawerItem(Icons.analytics, 'Reports', () {}),
              ]
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreetingWithDate(),
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      SizedBox(height: 4),
                      Text(employeeName,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(profileUrl)),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: FloatingActionButton.extended(
                onPressed: _handleCheckInOut,
                backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
                label: Text(_isCheckedIn ? "CHECK OUT" : "CHECK IN"),
                icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 0.8,
              children: [
                _buildStatCard("12", "Leave Days", Icons.calendar_today),
                _buildStatCard("95%", "Attendance", Icons.percent),
                _buildStatCard("June", "Payslip", Icons.attach_money),
              ],
            ),
            SizedBox(height: 20),
            Text("Recent Activities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Leave Approved"),
              subtitle: Text("Sick leave for June 10–12"),
              trailing: Text("Today", style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.orange),
              title: Text("New Announcement"),
              subtitle: Text("Office closed on July 4"),
              trailing: Text("Yesterday", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Timesheet'),
        ],
      ),
    );
  }
}
