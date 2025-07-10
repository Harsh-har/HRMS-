import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Admin_Sections/admin_notification.dart';
import '../Admin_Sections/admin_projectswatch.dart';
import '../Admin_Sections/admin_profile.dart';
import '../Admin_Sections/admin_setting.dart';
import '../Admin_Sections/admin_leaverequest.dart';
import '../Admin_Sections/EmployeeListPage.dart';
import '../Admin_Sections/admin _Attandencemonitor.dart';
import '../Admin_Sections/admin_holidaycalender.dart';
import '../Admin_Sections/Adminweeklywatchsheet.dart';
import '../Admin_Sections/admin_performance.dart';

class ManagerDashboard extends StatefulWidget {
  final String role;

  const ManagerDashboard({Key? key, required this.role}) : super(key: key);

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  Map<String, bool> permissions = {};
  bool isLoading = true;

  final Stream<int> _unreadNotificationCount = FirebaseFirestore.instance
      .collection('notifications')
      .where('status', isEqualTo: 'unread')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);

  @override
  void initState() {
    super.initState();
    fetchRolePermissions();
  }

  Future<void> fetchRolePermissions() async {
    final doc = await FirebaseFirestore.instance
        .collection('roles_permissions')
        .doc(widget.role)
        .get();

    if (doc.exists) {
      setState(() {
        permissions = Map<String, bool>.from(doc.data()!);
        isLoading = false;
      });
    } else {
      setState(() {
        permissions = {};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String managerName = 'Team Manager'; // Replace with dynamic name if needed
    final String profileImage = 'assets/profile/managerimage.jpg'; // Replace with manager image path

    final List<Map<String, dynamic>> gridItems = [
      if (permissions['employee_details'] == true)
        {"icon": Icons.group, "label": "Employee Management", "screen": const EmployeeListPage()},
      if (permissions['attendance'] == true)
        {"icon": Icons.event_note, "label": "Attendance Monitoring", "screen": AttendanceMonitoringScreen()},
      if (permissions['leave_requests'] == true)
        {"icon": Icons.insert_chart, "label": "Leave Management", "screen":  LeaveRequestsPage()},
      if (permissions['time_sheet'] == true)
        {"icon": Icons.access_time, "label": "TimeSheets", "screen": const TimesheetPagee()},
      if (permissions['holiday_calendar'] == true)
        {"icon": Icons.calendar_today, "label": "Holiday Calendar", "screen":  HolidayCalendarAdminScreen()},
      if (permissions['projects'] == true)
        {"icon": Icons.folder, "label": "Employee Review", "screen": const AddPerformanceReviewScreen()},
    ];

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
              // Profile Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: profileImage.startsWith('assets')
                            ? AssetImage(profileImage)
                            : NetworkImage(profileImage) as ImageProvider,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        managerName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                                MaterialPageRoute(builder: (_) => const AdminNotificationScreen()),
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

              // GridView
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: gridItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => item['screen']),
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
                              Icon(item['icon'], size: 50, color: Colors.blueAccent),
                              const SizedBox(height: 10),
                              Text(item['label'], style: const TextStyle(fontSize: 16)),
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

      // Optional bottom nav
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>  ProjectScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>  AdminProfile()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>  AdminSetting()));
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
