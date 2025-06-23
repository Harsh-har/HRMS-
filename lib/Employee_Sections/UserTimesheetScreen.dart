import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTimesheetScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  const UserTimesheetScreen({super.key, required this.employeeData});

  @override
  _UserTimesheetScreenState createState() => _UserTimesheetScreenState();
}

class _UserTimesheetScreenState extends State<UserTimesheetScreen> {
  String selectedFilter = 'This Week';
  List<Map<String, String>> timesheet = [];

  @override
  void initState() {
    super.initState();
    _fetchTimesheet();
  }

  Future<void> _fetchTimesheet() async {
    final name = widget.employeeData['name'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<Map<String, String>> records = [];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    for (var day in days) {
      final snapshots = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(name)
          .collection(day)
          .get();

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
              status = checkInTime.hour > 9 || (checkInTime.hour == 9 && checkInTime.minute > 0)
                  ? 'Late'
                  : 'Present';
            }

            records.add({
              'date': data['date'] ?? '--',
              'checkIn': data['checkIn'] ?? '-',
              'checkOut': data['checkOut'] ?? '-',
              'status': status,
              'totalWorkedHours': data['totalWorkedHours'] ??
                  calculateWorkedHours(data['checkIn'] ?? '-', data['checkOut'] ?? '-'),
            });
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Sort by date descending
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

  String getTotalHours() {
    Duration total = Duration();
    for (var entry in timesheet) {
      final checkIn = entry['checkIn']!;
      final checkOut = entry['checkOut']!;
      if (checkIn != '-' && checkOut != '-') {
        try {
          final format = DateFormat('hh:mm a');
          final inTime = format.parse(checkIn);
          final outTime = format.parse(checkOut);
          final checkInTime = DateTime(2025, 6, 19, inTime.hour, inTime.minute);
          final checkOutTime = DateTime(2025, 6, 19, outTime.hour, outTime.minute);
          total += checkOutTime.difference(checkInTime);
        } catch (e) {}
      }
    }
    final h = total.inHours;
    final m = total.inMinutes.remainder(60);
    return '${h}h ${m.abs()}m';
  }

  String getLeavesCount() {
    return timesheet.where((entry) => entry['status'] == 'Absent').length.toString();
  }

  String getDaysWorked() {
    return timesheet.where((entry) => entry['status'] != 'Absent').length.toString();
  }

  void exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('User Timesheet Report',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...timesheet.map(
                  (day) => pw.Text(
                "${day['date']} - ${day['checkIn']} to ${day['checkOut']} - ${day['status']} - ${day['totalWorkedHours']}",
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Total Hours: ${getTotalHours()}'),
            pw.Text('Days Worked: ${getDaysWorked()}'),
            pw.Text('Leaves: ${getLeavesCount()}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void showDetailDialog(Map<String, String> day) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(day['date']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Check-In: ${day['checkIn']}"),
            Text("Check-Out: ${day['checkOut']}"),
            Text("Hours Worked: ${day['totalWorkedHours']}"),
            Text("Status: ${day['status']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Timesheet'),
        backgroundColor: Color(0xFF0D47A1),
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
          IconButton(
            onPressed: exportToPdf,
            icon: Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummary("Worked", getTotalHours(), Icons.access_time),
                _buildSummary("Present", getDaysWorked(), Icons.check_circle),
                _buildSummary("Leave", getLeavesCount(), Icons.close),
              ],
            ),
          ),
          Expanded(
            child: timesheet.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: timesheet.length,
              itemBuilder: (context, index) {
                final day = timesheet[index];
                return GestureDetector(
                  onTap: () => showDetailDialog(day),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
                      title: Text(day['date']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Check-In: ${day['checkIn']}  |  Check-Out: ${day['checkOut']}"),
                          Text("Hours: ${day['totalWorkedHours']}"),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          day['status']!,
                          style: TextStyle(
                            color: day['status'] == 'Absent'
                                ? Colors.red
                                : day['status'] == 'Late'
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(height: 6),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
