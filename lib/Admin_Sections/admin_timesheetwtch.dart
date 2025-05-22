import 'package:flutter/material.dart';

class TimesheetPage extends StatefulWidget {
  @override
  _TimesheetPageState createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  String selectedRange = 'This Week';
  final List<Map<String, String>> timesheetData = [
    {
      'name': 'Harsh Singhal',
      'profile': 'https://via.placeholder.com/150',
      'date': '22 May 2025',
      'checkIn': '09:15 AM',
      'checkOut': '06:10 PM',
      'status': 'Late',
      'hours': '8h 55m'
    },
    {
      'name': 'Mayank Singh',
      'profile': 'https://via.placeholder.com/150',
      'date': '22 May 2025',
      'checkIn': '09:00 AM',
      'checkOut': '06:00 PM',
      'status': 'Present',
      'hours': '9h 00m'
    },
    {
      'name': 'Ansh Sharma',
      'profile': 'https://via.placeholder.com/150',
      'date': '22 May 2025',
      'checkIn': '-',
      'checkOut': '-',
      'status': 'Absent',
      'hours': '0h'
    },
    {
      'name': 'Varun',
      'profile': 'https://via.placeholder.com/150',
      'date': '22 May 2025',
      'checkIn': '-',
      'checkOut': '-',
      'status': 'Absent',
      'hours': '0h'
    },

    {
      'name': 'Anshika',
      'profile': 'https://via.placeholder.com/150',
      'date': '22 May 2025',
      'checkIn': '09:15 AM',
      'checkOut': '06:10 PM',
      'status': 'Late',
      'hours': '8h 55m'
    },
    {
      'name': 'Swastika',
      'profile': 'https://via.placeholder.com/150',
      'date': '22 May 2025',
      'checkIn': '09:00 AM',
      'checkOut': '06:00 PM',
      'status': 'Present',
      'hours': '9h 00m'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timesheet'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.filter_alt)),
          IconButton(onPressed: () {}, icon: Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                summaryCard('Total Hours', '27h 15m'),
                summaryCard('Overtime', '2h 30m'),
                summaryCard('Leave', '1 Day'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: timesheetData.length,
              itemBuilder: (context, index) {
                final data = timesheetData[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['profile']!),
                    ),
                    title: Text(data['name']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${data['date']}'),
                        Text('Check-In: ${data['checkIn']} | Check-Out: ${data['checkOut']}'),
                        Text('Hours: ${data['hours']}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        data['status']!,
                        style: TextStyle(
                          color: data['status'] == 'Absent'
                              ? Colors.red
                              : data['status'] == 'Late'
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                      backgroundColor: Colors.grey.shade100,
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

  Widget summaryCard(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }
}