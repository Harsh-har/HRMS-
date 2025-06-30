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

  // 1. Added _greeting method
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  // 2. Added _navigateTo method
  void _navigateTo(int index) {
    Widget? destination;
    switch (index) {
      case 1:
        destination = NewAttendanceScreen(employeeData: widget.employeeData);
        break;
      case 2:
        destination = UserProjectScreen(employeeData: widget.employeeData);
        break;
      case 3:
        destination = WeeklyTimesheetScreen(employeeData: widget.employeeData,);
        break;
    }

    if (destination != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => destination!));
      setState(() => _currentIndex = index);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupLeaveListener();
    _checkNotifications();
  }

  @override
  void dispose() {
    _leaveSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .where('read', isEqualTo: false)
        .get();

    setState(() {
      _notificationCount = snapshot.size;
    });
  }

  void _setupLeaveListener() {
    _leaveSubscription = FirebaseFirestore.instance
        .collection('leave_requests')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .where('status', whereIn: ['Approved', 'Rejected'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _processLeaveActivities(snapshot.docs);
    });
  }

  Future<void> _loadInitialData() async {
    final leaveSnapshot = await FirebaseFirestore.instance
        .collection('leave_requests')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .where('status', whereIn: ['Approved', 'Rejected'])
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    _processLeaveActivities(leaveSnapshot.docs);

    if (recentActivities.isEmpty) {
      final holidaySnapshot = await FirebaseFirestore.instance
          .collection('holidays')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      for (var doc in holidaySnapshot.docs) {
        final data = doc.data();
        final date = data['date'];
        final formattedDate = date is Timestamp
            ? DateFormat('dd MMM yyyy').format(date.toDate())
            : date.toString();

        setState(() {
          recentActivities.add({
            'type': 'Holiday',
            'description': data['name'] ?? 'Holiday',
            'date': formattedDate,
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
      final timestamp = data['timestamp'];

      String date;
      if (timestamp is Timestamp) {
        date = DateFormat('dd MMM yyyy').format(timestamp.toDate());
      } else {
        date = 'N/A';
      }

      temp.add({
        'type': 'Leave $status',
        'description': '$leaveType from $start to $end',
        'date': date,
        'status': status,
      });
    }

    setState(() {
      recentActivities = temp.take(3).toList();
    });
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationScreen(employeeId: widget.employeeData['employeeId']),
                    ),
                  ).then((_) => _checkNotifications());
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
      body: SingleChildScrollView(
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
                      builder: (_) =>UserTimesheetScreen (employeeData: widget.employeeData),
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

                  if (activity['type'].contains('Approved')) {
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                  } else if (activity['type'].contains('Rejected')) {
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                  } else if (activity['type'].contains('Holiday')) {
                    statusColor = Colors.orange;
                    statusIcon = Icons.celebration;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(statusIcon, color: statusColor),
                      title: Text(
                        activity['type'],
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