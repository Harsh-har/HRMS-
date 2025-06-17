import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class UserTimesheetScreen extends StatefulWidget {
  @override
  _UserTimesheetScreenState createState() => _UserTimesheetScreenState();
}

class _UserTimesheetScreenState extends State<UserTimesheetScreen> {
  String selectedFilter = 'This Week';

  List<Map<String, String>> fullTimesheet = [
    {
      'date': '10 June 2025',
      'checkIn': '09:05 AM',
      'checkOut': '06:00 PM',
      'status': 'Late',
    },
    {
      'date': '11 June 2025',
      'checkIn': '09:00 AM',
      'checkOut': '06:00 PM',
      'status': 'Present',
    },
    {
      'date': '12 June 2025',
      'checkIn': '-',
      'checkOut': '-',
      'status': 'Absent',
    },
  ];

  String calculateWorkedHours(String checkIn, String checkOut) {
    if (checkIn == '-' || checkOut == '-') return '0h';
    try {
      final format = DateFormat('hh:mm a');
      final inTime = format.parse(checkIn);
      final outTime = format.parse(checkOut);
      final duration = outTime.difference(inTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } catch (e) {
      return '0h';
    }
  }

  String getTotalHours() {
    Duration total = Duration();
    for (var entry in fullTimesheet) {
      final checkIn = entry['checkIn']!;
      final checkOut = entry['checkOut']!;
      if (checkIn != '-' && checkOut != '-') {
        try {
          final format = DateFormat('hh:mm a');
          final inTime = format.parse(checkIn);
          final outTime = format.parse(checkOut);
          total += outTime.difference(inTime);
        } catch (e) {}
      }
    }
    final h = total.inHours;
    final m = total.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  String getLeavesCount() {
    return fullTimesheet.where((entry) => entry['status'] == 'Absent').length.toString();
  }

  String getDaysWorked() {
    return fullTimesheet.where((entry) => entry['status'] != 'Absent').length.toString();
  }

  void exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('User Timesheet Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...fullTimesheet.map(
                  (day) => pw.Text(
                "${day['date']} - ${day['checkIn']} to ${day['checkOut']} - ${day['status']} - ${calculateWorkedHours(day['checkIn']!, day['checkOut']!)}",
              ),
            ),
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
            Text("Hours Worked: ${calculateWorkedHours(day['checkIn']!, day['checkOut']!)}"),
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
            onSelected: (val) => setState(() => selectedFilter = val),
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
            child: ListView.builder(
              itemCount: fullTimesheet.length,
              itemBuilder: (context, index) {
                final day = fullTimesheet[index];
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
                          Text("Hours: ${calculateWorkedHours(day['checkIn']!, day['checkOut']!)}"),
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
