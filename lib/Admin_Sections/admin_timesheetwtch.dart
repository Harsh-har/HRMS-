import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TimesheetPage extends StatefulWidget {
  @override
  _TimesheetPageState createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  String selectedRange = 'This Week';
  Map<String, List<Map<String, String>>> groupedTimesheets = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTimesheetData();
  }

  Future<void> _fetchTimesheetData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      groupedTimesheets = {};
    });

    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

      final employeeSnapshot = await FirebaseFirestore.instance.collection('attendance').get();
      final employeeNames = employeeSnapshot.docs.map((doc) => doc.id).toList();

      for (var employeeName in employeeNames) {
        for (var day in days) {
          final snapshot = await FirebaseFirestore.instance
              .collection('attendance')
              .doc(employeeName)
              .collection(day)
              .doc('record')
              .get();

          if (snapshot.exists) {
            final data = snapshot.data()!;

            if (data['date'] == null) continue;

            DateTime? recordDate;
            try {
              recordDate = DateFormat('dd MMM yyyy').parse(data['date']);
            } catch (_) {
              continue;
            }

            bool includeRecord = true;
            if (selectedRange == 'This Week') {
              includeRecord = recordDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                  recordDate.isBefore(startOfWeek.add(Duration(days: 7)));
            } else if (selectedRange == 'This Month') {
              includeRecord = recordDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
                  recordDate.isBefore(endOfMonth.add(Duration(days: 1)));
            }

            if (includeRecord) {
              String status = 'Absent';
              String hours = '0h 0m';
              if (data['checkIn'] != null && data['checkOut'] != null) {
                try {
                  final checkInTime = DateFormat('hh:mm a').parse(data['checkIn']);
                  status = checkInTime.hour > 9 || (checkInTime.hour == 9 && checkInTime.minute > 0) ? 'Late' : 'Present';
                  hours = data['totalWorkedHours'] ?? calculateWorkedHours(data['checkIn'], data['checkOut'], data['date']);
                } catch (_) {}
              }

              groupedTimesheets.putIfAbsent(employeeName, () => []);
              groupedTimesheets[employeeName]!.add({
                'date': data['date'] ?? '--',
                'checkIn': data['checkIn'] ?? '-',
                'checkOut': data['checkOut'] ?? '-',
                'status': status,
                'hours': hours,
              });
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load timesheet data: $e';
      });
    }
  }

  String calculateWorkedHours(String checkIn, String checkOut, String date) {
    if (checkIn == '-' || checkOut == '-') return '0h 0m';
    try {
      final format = DateFormat('hh:mm a');
      final dateFormat = DateFormat('dd MMM yyyy');
      final recordDate = dateFormat.parse(date);
      final inTime = format.parse(checkIn);
      final outTime = format.parse(checkOut);
      final checkInTime = DateTime(recordDate.year, recordDate.month, recordDate.day, inTime.hour, inTime.minute);
      final checkOutTime = DateTime(recordDate.year, recordDate.month, recordDate.day, outTime.hour, outTime.minute);
      final duration = checkOutTime.difference(checkInTime);
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } catch (_) {
      return '0h 0m';
    }
  }

  void showEmployeeTimesheetDialog(String name, List<Map<String, String>> records) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Timesheet: $name"),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: records.map((r) => ListTile(
              title: Text(r['date']!),
              subtitle: Text("Check-In: ${r['checkIn']} | Check-Out: ${r['checkOut']} | Hours: ${r['hours']} | Status: ${r['status']}"),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timesheet'),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                selectedRange = val;
                _fetchTimesheetData();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'This Month', child: Text('This Month')),
            ],
            icon: Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
          : groupedTimesheets.isEmpty
          ? Center(child: Text('No records found'))
          : ListView.builder(
        itemCount: groupedTimesheets.length,
        itemBuilder: (context, index) {
          final employeeName = groupedTimesheets.keys.elementAt(index);
          final records = groupedTimesheets[employeeName]!;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              title: Text(employeeName),
              subtitle: Text("Total Records: ${records.length}"),
              onTap: () => showEmployeeTimesheetDialog(employeeName, records),
            ),
          );
        },
      ),
    );
  }
}
