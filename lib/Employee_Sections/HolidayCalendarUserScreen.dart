import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendarUserScreen extends StatefulWidget {
  @override
  _HolidayCalendarUserScreenState createState() =>
      _HolidayCalendarUserScreenState();
}

class _HolidayCalendarUserScreenState extends State<HolidayCalendarUserScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Map<String, String>> holidays = [
    {
      'date': '2025-01-01',
      'name': 'New Year’s Day',
      'type': 'Public',
      'region': 'All Offices',
      'notes': 'Holiday for all employees'
    },
    {
      'date': '2025-03-29',
      'name': 'Holi',
      'type': 'Regional',
      'region': 'North India',
      'notes': 'Festival of colors'
    },
    {
      'date': '2025-08-15',
      'name': 'Independence Day',
      'type': 'Public',
      'region': 'All Offices',
      'notes': 'National holiday'
    },
  ];

  List<Map<String, String>> getHolidaysForDay(DateTime date) {
    return holidays.where((h) {
      final holidayDate = DateTime.parse(h['date']!);
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

          // Display holiday cards for selected date
          Expanded(
            child: ListView(
              children: holidays
                  .where((h) =>
              DateTime.parse(h['date']!).day == _focusedDay.day &&
                  DateTime.parse(h['date']!).month == _focusedDay.month &&
                  DateTime.parse(h['date']!).year == _focusedDay.year)
                  .map((holiday) => Card(
                margin:
                EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.flag, color: Colors.indigo),
                  title: Text(holiday['name']!),
                  subtitle: Text(
                      "${holiday['date']} • ${holiday['type']} • ${holiday['region']}"),
                  trailing: Icon(Icons.info_outline),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
