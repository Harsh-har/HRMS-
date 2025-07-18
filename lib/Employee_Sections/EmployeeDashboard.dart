import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrms_project/Employee_Sections/EmployeeWeeklySheet.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'AttendanceScreen.dart';
import 'HolidayCalendarUserScreen.dart';
import 'LeaveRequestScreen.dart';
import 'NotificationScreen.dart';
import 'ProfileScreen.dart';
import 'UserPerformanceScreen.dart';
import 'UserProjectScreen.dart';
import 'UserTimesheetScreen.dart';

class EmployeeDashboard extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const EmployeeDashboard({super.key, required this.employeeData});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _currentIndex = 0;
  int _notificationCount = 0;
  List<Map<String, dynamic>> recentActivities = [];
  late StreamSubscription<QuerySnapshot> _leaveSubscription;
  late StreamSubscription<QuerySnapshot> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupLeaveListener();
    _setupNotificationListener();
    _checkNotifications();
  }

  @override
  void dispose() {
    _leaveSubscription.cancel();
    _notificationSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .where('read', isEqualTo: false)
        .get();

    setState(() => _notificationCount = snapshot.size);
  }

  void _setupLeaveListener() {
    _leaveSubscription = FirebaseFirestore.instance
        .collection('leave_requests')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final filteredDocs = snapshot.docs.where((doc) {
        final status = doc['status'];
        return status == 'Approved' || status == 'Rejected';
      }).toList();
      _processLeaveActivities(filteredDocs);
    });
  }

  void _setupNotificationListener() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((_) => _checkNotifications());
  }

  Future<void> _loadInitialData() async {
    final leaveSnapshot = await FirebaseFirestore.instance
        .collection('leave_requests')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .orderBy('timestamp', descending: true)
        .get();

    final filtered = leaveSnapshot.docs.where((doc) {
      final status = doc['status'];
      return status == 'Approved' || status == 'Rejected';
    }).toList();

    _processLeaveActivities(filtered);

    if (recentActivities.isEmpty) {
      final holidaySnapshot = await FirebaseFirestore.instance
          .collection('holidays')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      for (var doc in holidaySnapshot.docs) {
        final data = doc.data();
        final date = data['date'] is Timestamp
            ? DateFormat('dd MMM yyyy').format(data['date'].toDate())
            : data['date'].toString();

        setState(() {
          recentActivities.add({
            'type': 'Holiday',
            'description': data['name'] ?? 'Holiday',
            'date': date,
          });
        });
      }
    }
  }

  void _processLeaveActivities(List<QueryDocumentSnapshot> docs) {
    List<Map<String, dynamic>> temp = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? '';
      final start = data['startDate'] ?? '';
      final end = data['endDate'] ?? '';
      final leaveType = data['leaveType'] ?? 'Leave';
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final formattedDate = DateFormat('dd MMM yyyy').format(timestamp);

      temp.add({
        'type': 'Leave $status',
        'description': '$leaveType from $start to $end',
        'date': formattedDate,
        'status': status,
        'timestamp': timestamp,
      });
    }

    temp.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    setState(() => recentActivities = temp.take(3).toList());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    Widget screen;
    switch (index) {
      case 1:
        screen = NewAttendanceScreen(employeeData: widget.employeeData);
        break;
      case 2:
        screen = UserProjectScreen(employeeData: widget.employeeData);
        break;
      case 3:
        screen = WeeklyTimesheetScreen(employeeData: widget.employeeData);
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildShortcut(String title, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue.shade900),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.employeeData['name'] ?? 'Employee';
    final profileUrl = widget.employeeData['profileUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(), style: const TextStyle(fontSize: 14)),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Notificationscreen(employeeData: widget.employeeData),
                    ),
                  );
                  _checkNotifications();
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_notificationCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(backgroundImage: NetworkImage(profileUrl)),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadInitialData();
          await _checkNotifications();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildShortcut("Holiday", Icons.event, HolidayCalendarUserScreen()),
                  _buildShortcut("Submit Leave", Icons.send, SubmitLeaveRequestPage(employeeData: widget.employeeData)),
                  _buildShortcut("Profile", Icons.person, ProfileScreen(employeeData: widget.employeeData)),
                  _buildShortcut("Rewards", Icons.assessment, UserPerformanceScreen(employeeName: name)),
                  _buildShortcut("Timesheet", Icons.schedule, UserTimesheetScreen(employeeData: widget.employeeData)),
                  _buildShortcut("Projects", Icons.folder, UserProjectScreen(employeeData: widget.employeeData)),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (recentActivities.isEmpty)
                const Center(child: Text("No recent activities found"))
              else
                Column(
                  children: recentActivities.map((activity) {
                    IconData icon = Icons.info;
                    Color color = Colors.grey;
                    String title = activity['type'];

                    if (activity['type'].contains('Approved')) {
                      icon = Icons.check_circle;
                      color = Colors.green;
                      title = 'Leave Approved';
                    } else if (activity['type'].contains('Rejected')) {
                      icon = Icons.cancel;
                      color = Colors.red;
                      title = 'Leave Rejected';
                    } else if (activity['type'].contains('Holiday')) {
                      icon = Icons.celebration;
                      color = Colors.orange;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(icon, color: color),
                        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        subtitle: Text(activity['description']),
                        trailing: Text(activity['date'], style: const TextStyle(color: Colors.grey)),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateTo,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Timesheet"),
        ],
      ),
    );
  }
}
