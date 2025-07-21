import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserTimesheetScreen extends StatefulWidget {
  final String employeeName;
  const UserTimesheetScreen({Key? key, required this.employeeName}) : super(key: key);

  @override
  _UserTimesheetScreenState createState() => _UserTimesheetScreenState();
}

class _UserTimesheetScreenState extends State<UserTimesheetScreen> {
  Map<String, dynamic> timesheetData = {};

  @override
  void initState() {
    super.initState();
    _fetchTimesheet();
  }

  Future<void> _fetchTimesheet() async {
    try {
      final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
      final timesheet = <String, dynamic>{};

      for (final day in daysOfWeek) {
        final snapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .doc(widget.employeeName)
            .collection(day)
            .doc('record')
            .get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          final checkIn = data['checkIn'];
          final checkOut = data['checkOut'];
          final date = data['date'];
          final totalWorkedHours = data['totalWorkedHours'];

          String status = 'Absent';

          if (checkIn != null && checkOut != null) {
            final rawCheckIn = DateFormat('hh:mm a').parse(checkIn);
            final checkInTime = DateTime(2000, 1, 1, rawCheckIn.hour, rawCheckIn.minute);
            final presentLimit = DateTime(2000, 1, 1, 9, 0);
            final lateLimit = DateTime(2000, 1, 1, 11, 0);

            if (checkInTime.isBefore(presentLimit) || checkInTime == presentLimit) {
              status = 'Present';
            } else if (checkInTime.isBefore(lateLimit)) {
              status = 'Late';
            } else {
              status = 'Absent';
            }
          }

          timesheet[day] = {
            'checkIn': checkIn,
            'checkOut': checkOut,
            'date': date,
            'totalWorkedHours': totalWorkedHours,
            'status': status,
          };
        }
      }

      setState(() {
        timesheetData = timesheet;
      });
    } catch (e) {
      print('Error fetching timesheet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.employeeName} Timesheet'),
      ),
      body: timesheetData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: timesheetData.length,
        itemBuilder: (context, index) {
          final day = timesheetData.keys.elementAt(index);
          final data = timesheetData[day];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(day),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${data['date'] ?? 'N/A'}'),
                  Text('Check-in: ${data['checkIn'] ?? 'N/A'}'),
                  Text('Check-out: ${data['checkOut'] ?? 'N/A'}'),
                  Text('Total Worked Hours: ${data['totalWorkedHours'] ?? 'N/A'}'),
                  Text('Status: ${data['status']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
