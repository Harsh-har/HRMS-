// Full Updated EmployeeDashboard.dart

import 'package:flutter/material.dart';
import 'package:hrms_project/Employee_Sections/userentrtimesheet.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _navigateTo(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    setState(() => _currentIndex = index);

    late Widget destination;
    switch (index) {
      case 1:
        destination = NewAttendanceScreen(employeeData: widget.employeeData);
        break;
      case 2:
        destination = UserProjectScreen(employeeData: widget.employeeData);
        break;
      case 3:
        destination = WeeklyTimesheetScreen(employeeData: widget.employeeData);
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupLeaveListener(); // fixed here
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

  // ✅ Updated to listen to ALL leave_requests for this employee
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
        final data = doc.data() as Map<String, dynamic>;
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
      try {
        final data = doc.data() as Map<String, dynamic>;

        final status = data['status']?.toString() ?? '';
        final start = data['startDate']?.toString() ?? '';
        final end = data['endDate']?.toString() ?? '';
        final leaveType = data['leaveType']?.toString() ?? 'Leave';

        final timestamp = data['timestamp'] is Timestamp
            ? (data['timestamp'] as Timestamp).toDate()
            : DateTime.now();

        final date = DateFormat('dd MMM yyyy').format(timestamp);

        temp.add({
          'type': 'Leave $status',
          'description': '$leaveType from $start to $end',
          'date': date,
          'status': status,
          'timestamp': timestamp,
        });
      } catch (e) {
        print('Error processing document ${doc.id}: $e');
      }
    }

    temp.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    setState(() => recentActivities = temp.take(3).toList());
  }

  Widget _buildShortcut(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue[900]),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center),
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
                      builder: (context) => Notificationscreen(employeeData: widget.employeeData),
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
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(profileUrl),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadInitialData();
          await _checkNotifications();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
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
                  _buildShortcut("Holiday\nCalendar", Icons.event, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HolidayCalendarUserScreen()));
                  }),
                  _buildShortcut("Submit\nLeave", Icons.send, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SubmitLeaveRequestPage(employeeData: widget.employeeData),
                    ));
                  }),
                  _buildShortcut("Profile", Icons.person, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ProfileScreen(employeeData: widget.employeeData),
                    ));
                  }),
                  _buildShortcut("My Rewards", Icons.assessment, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => UserPerformanceScreen(employeeName: name),
                    ));
                  }),
                  _buildShortcut("My Timesheet", Icons.schedule, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserTimesheetScreen(employeeData: widget.employeeData),
                      ),
                    );
                  }),
                  _buildShortcut("Projects", Icons.folder, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => UserProjectScreen(employeeData: widget.employeeData),
                    ));
                  }),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No recent activities found"),
                )
              else
                Column(
                  children: recentActivities.map((activity) {
                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.info;
                    String title = activity['type'];

                    if (activity['type'].contains('Approved')) {
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      title = 'Leave Approved';
                    } else if (activity['type'].contains('Rejected')) {
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                      title = 'Leave Rejected';
                    } else if (activity['type'].contains('Holiday')) {
                      statusColor = Colors.orange;
                      statusIcon = Icons.celebration;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(statusIcon, color: statusColor),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
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
