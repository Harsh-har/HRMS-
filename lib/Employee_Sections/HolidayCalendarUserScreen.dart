import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HolidayCalendarUserScreen extends StatefulWidget {
  @override
  _HolidayCalendarUserScreenState createState() => _HolidayCalendarUserScreenState();
}

class _HolidayCalendarUserScreenState extends State<HolidayCalendarUserScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> holidays = [];

  @override
  void initState() {
    super.initState();
    _loadHolidaysFromFirestore();
  }

  Future<void> _loadHolidaysFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('holidays').get();
    setState(() {
      holidays = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  List<Map<String, dynamic>> getHolidaysForDay(DateTime date) {
    return holidays.where((h) {
      final holidayDate = DateTime.parse(h['date']);
      return holidayDate.year == date.year &&
          holidayDate.month == date.month &&
          holidayDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade300,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => getHolidaysForDay(day),
          ),
          Expanded(
            child: ListView(
              children: getHolidaysForDay(_focusedDay).map((holiday) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.flag, color: Colors.indigo),
                  title: Text(holiday['name'] ?? ''),
                  subtitle: Text("${holiday['date']} • ${holiday['type']} • ${holiday['region']}"),
                  trailing: Icon(Icons.info_outline),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
