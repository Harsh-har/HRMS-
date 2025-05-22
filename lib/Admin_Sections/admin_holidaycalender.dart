import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendarAdminScreen extends StatefulWidget {
  @override
  _HolidayCalendarAdminScreenState createState() => _HolidayCalendarAdminScreenState();
}

class _HolidayCalendarAdminScreenState extends State<HolidayCalendarAdminScreen> {
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
    return holidays.where((h) => DateTime.parse(h['date']!).day == date.day &&
        DateTime.parse(h['date']!).month == date.month &&
        DateTime.parse(h['date']!).year == date.year).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Calendar'),
        actions: [
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: Icon(Icons.file_download), onPressed: () {}),
        ],
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
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => getHolidaysForDay(day),
          ),

          // Holiday List
          Expanded(
            child: ListView.builder(
              itemCount: holidays.length,
              itemBuilder: (context, index) {
                final holiday = holidays[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.beach_access, color: Colors.teal),
                    title: Text(holiday['name']!),
                    subtitle: Text(
                      "${holiday['date']} • ${holiday['type']} • ${holiday['region']}",
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(child: Text("Edit"), value: "edit"),
                        PopupMenuItem(child: Text("Delete"), value: "delete"),
                      ],
                      onSelected: (value) {
                        if (value == "edit") {
                          // TODO: Implement edit
                        } else if (value == "delete") {
                          // TODO: Implement delete
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show Add Holiday form
        },
        child: Icon(Icons.add),
        tooltip: 'Add Holiday',
      ),
    );
  }
}