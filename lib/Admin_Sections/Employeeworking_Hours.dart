import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class employeewrokingscreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  final bool isAdminView;

  const employeewrokingscreen({
    Key? key,
    required this.employeeData,
    this.isAdminView = true,
  }) : super(key: key);

  @override
  State<employeewrokingscreen> createState() => _employeewrokingscreenState();
}

class _employeewrokingscreenState extends State<employeewrokingscreen> {
  List<Map<String, String>> timesheet = [];
  String selectedFilter = 'This Week';

  @override
  void initState() {
    super.initState();
    _fetchTimesheet();
  }

  Future<void> _fetchTimesheet() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<Map<String, String>> records = [];

    List<String> employeeNames = [];

    if (widget.isAdminView) {
      // Fetch all employee names from attendance collection
      final snapshot = await FirebaseFirestore.instance.collection('attendance').get();
      employeeNames = snapshot.docs.map((doc) => doc.id).toList();
    } else {
      // Only current employee
      employeeNames = [widget.employeeData['name']];
    }

    for (var name in employeeNames) {
      final futures = days.map((day) {
        return FirebaseFirestore.instance
            .collection('attendance')
            .doc(name)
            .collection(day)
            .get();
      }).toList();

      final results = await Future.wait(futures);

      for (var snapshots in results) {
        for (var doc in snapshots.docs) {
          final data = doc.data();
          final dateStr = data['date'];
          if (dateStr == null) continue;

          try {
            final recordDate = DateFormat('dd MMM yyyy').parse(dateStr);
            bool includeRecord = false;

            if (selectedFilter == 'This Week') {
              includeRecord = recordDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                  recordDate.isBefore(startOfWeek.add(Duration(days: 7)));
            } else if (selectedFilter == 'This Month') {
              includeRecord = recordDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
                  recordDate.isBefore(endOfMonth.add(Duration(days: 1)));
            }

            if (includeRecord) {
              String status = 'Absent';
              if (data['checkIn'] != null && data['checkOut'] != null) {
                final checkInTime = DateFormat('hh:mm a').parse(data['checkIn']);
                status = checkInTime.hour < 9 || (checkInTime.hour == 9 && checkInTime.minute > 0)
                    ? 'Present'
                    : 'Late';
              }

              records.add({
                'employeeName': name,
                'date': data['date'] ?? '--',
                'checkIn': data['checkIn'] ?? '-',
                'checkOut': data['checkOut'] ?? '-',
                'status': status,
                'totalWorkedHours': data['totalWorkedHours'] ??
                    calculateWorkedHours(data['checkIn'] ?? '-', data['checkOut'] ?? '-')
              });
            }
          } catch (e) {
            continue;
          }
        }
      }
    }

    records.sort((a, b) {
      try {
        final dateA = DateFormat('dd MMM yyyy').parse(a['date']!);
        final dateB = DateFormat('dd MMM yyyy').parse(b['date']!);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      timesheet = records;
    });
  }

  String calculateWorkedHours(String checkIn, String checkOut) {
    if (checkIn == '-' || checkOut == '-') return '0h 0m';
    try {
      final format = DateFormat('hh:mm a');
      final inTime = format.parse(checkIn);
      final outTime = format.parse(checkOut);
      final checkInTime = DateTime(2025, 6, 19, inTime.hour, inTime.minute);
      final checkOutTime = DateTime(2025, 6, 19, outTime.hour, outTime.minute);
      final duration = checkOutTime.difference(checkInTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes.abs()}m';
    } catch (e) {
      return '0h 0m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = widget.isAdminView ? 'All Employees' : widget.employeeData['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Timesheet for $employeeName'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                selectedFilter = val;
                _fetchTimesheet();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'This Month', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: timesheet.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: timesheet.length,
        itemBuilder: (context, index) {
          final day = timesheet[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(day['date']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isAdminView)
                    Text("Employee: ${day['employeeName']}"),
                  Text("Check-In: ${day['checkIn']} | Check-Out: ${day['checkOut']}"),
                  Text("Worked: ${day['totalWorkedHours']}"),
                ],
              ),
              trailing: Text(
                day['status']!,
                style: TextStyle(
                  color: day['status'] == 'Absent'
                      ? Colors.red
                      : day['status'] == 'Late'
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
