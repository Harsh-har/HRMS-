import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your actual HR Profile screen here
import 'HrProfile.dart';


// Admin modules reused for now
import '../Admin_Sections/EmployeeListPage.dart';
import '../Admin_Sections/admin _Attandencemonitor.dart';
import '../Admin_Sections/admin_leaverequest.dart';
import '../Admin_Sections/Adminweeklywatchsheet.dart';
import '../Admin_Sections/admin_holidaycalender.dart';
import '../Admin_Sections/admin_performance.dart';
import '../Admin_Sections/admin_projectswatch.dart';
import '../Admin_Sections/admin_setting.dart';
import '../Admin_Sections/admin_notification.dart';

class HrDashboard extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const HrDashboard({super.key, required this.employeeData});

  @override
  State<HrDashboard> createState() => _HrDashboardState();
}

class _HrDashboardState extends State<HrDashboard> {
  Map<String, bool> hrPermissions = {};
  bool isLoading = true;

  final Stream<int> _unreadNotificationCount = FirebaseFirestore.instance
      .collection('notifications')
      .where('status', isEqualTo: 'unread')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);

  final List<Map<String, dynamic>> modules = [
    {
      "icon": Icons.group,
      "label": "Employee Management",
      "key": "employee_details",
      "screen": const EmployeeListPage(),
    },
    {
      "icon": Icons.event_note,
      "label": "Attendance Monitoring",
      "key": "attendance",
      "screen": AdminAttendanceScreen(),
    },
    {
      "icon": Icons.insert_chart,
      "label": "Leave Management",
      "key": "leave_requests",
      "screen": LeaveRequestsPage(),
    },
    {
      "icon": Icons.access_time,
      "label": "TimeSheets",
      "key": "time_sheet",
      "screen": TimesheetPagee(),
    },
    {
      "icon": Icons.calendar_today,
      "label": "Holiday Calendar",
      "key": "holiday_calendar",
      "screen": HolidayCalendarAdminScreen(),
    },
    {
      "icon": Icons.folder,
      "label": "Employee Review",
      "key": "projects",
      "screen": AddPerformanceReviewScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    final doc = await FirebaseFirestore.instance
        .collection('roles_permissions')
        .doc('hr')
        .get();

    if (doc.exists) {
      setState(() {
        hrPermissions = Map<String, bool>.from(doc.data()!);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String hrName = widget.employeeData['name'] ?? 'HR';
    final String hrImage = widget.employeeData['profileImage'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 Profile Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: hrImage.isNotEmpty
                            ? NetworkImage(hrImage)
                            : const AssetImage('assets/profile/adminimage.jpg')
                        as ImageProvider,
                      ),
                      const SizedBox(width: 25),
                      Text(
                        hrName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  StreamBuilder<int>(
                    stream: _unreadNotificationCount,
                    builder: (context, snapshot) {
                      int unreadCount = snapshot.data ?? 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const AdminNotificationScreen()),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 11,
                              top: 11,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 70),

              // 📦 Grid Modules
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: modules
                      .where((module) =>
                  hrPermissions[module['key']] == true)
                      .map((item) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => item['screen']),
                        );
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
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item['icon'] as IconData,
                                  size: 50, color: Colors.blueAccent),
                              const SizedBox(height: 10),
                              Text(item['label'] as String,
                                  style: const TextStyle(fontSize: 16)),
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
          if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProjectScreen()));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      HrProfile(employeeData: widget.employeeData)),
            );
          } else if (index == 3) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AdminSetting()));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}
