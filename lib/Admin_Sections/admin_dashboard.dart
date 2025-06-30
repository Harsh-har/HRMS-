import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hrms_project/Admin_Sections/admin_notification.dart';
import 'Adminweeklywatchsheet.dart';
import 'EmployeeListPage.dart';
import 'admin _Attandencemonitor.dart';
import 'admin_holidaycalender.dart';
import 'admin_performance.dart';
import 'admin_profile.dart';
import 'admin_projectswatch.dart';
import 'admin_setting.dart';
import 'admin_timesheetwtch.dart';
import 'emp_managment.dart';
import 'admin_leaverequest.dart';

void main() => runApp(EmployeeApp());

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems = [
    {"icon": Icons.group, "label": "Employee Management"},
    {"icon": Icons.event_note, "label": "Attendance Monitoring"},
    {"icon": Icons.insert_chart, "label": "Leave Management"},
    {"icon": Icons.access_time, "label": "TimeSheets"},
    {"icon": Icons.calendar_today, "label": "Holiday Calendar"},
    {"icon": Icons.folder, "label": "Employee Review"},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final adminName = user?.displayName ?? 'Pradeep Kumar';
    final adminImage = user?.photoURL ?? 'assets/profile/adminimage.jpg';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: adminImage.startsWith('assets')
                            ? AssetImage(adminImage)
                            : NetworkImage(adminImage) as ImageProvider,
                      ),
                      const SizedBox(width: 25),
                      Text(
                        adminName,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminNotificationScreen ()),
                        );
                      } catch (e) {
                        print('Error navigating to AdminNotification: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to open notifications: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 70),

              // Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: gridItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        try {
                          if (item["label"] == "Employee Management") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EmployeeListPage()),
                            );
                          } else if (item["label"] == "Attendance Monitoring") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AttendanceMonitoringScreen()),
                            );
                          } else if (item["label"] == "Leave Management") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LeaveRequestsPage()),
                            );
                          } else if (item["label"] == "TimeSheets") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TimesheetPagee()),
                            );
                          } else if (item["label"] == "Holiday Calendar") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HolidayCalendarAdminScreen()),
                            );
                          } else if (item["label"] == "Employee Review") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddPerformanceReviewScreen()),
                            );
                          }
                        } catch (e) {
                          print('Error navigating to ${item["label"]}: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to open ${item["label"]}: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item["icon"], size: 50, color: Colors.blueAccent),
                              const SizedBox(height: 10),
                              Text(item["label"], style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) {
          try {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminProfile()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminSetting()),
              );
            }
          } catch (e) {
            print('Error navigating to bottom nav index $index: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to navigate: $e'), backgroundColor: Colors.red),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}