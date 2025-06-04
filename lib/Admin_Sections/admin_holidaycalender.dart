import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendarAdminScreen extends StatefulWidget {
  @override
  _HolidayCalendarAdminScreenState createState() =>
      _HolidayCalendarAdminScreenState();
}

class _HolidayCalendarAdminScreenState
    extends State<HolidayCalendarAdminScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, String>> holidays = [
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
    return holidays
        .where((h) =>
    DateTime.parse(h['date']!).day == date.day &&
        DateTime.parse(h['date']!).month == date.month &&
        DateTime.parse(h['date']!).year == date.year)
        .toList();
  }

  void _showAddHolidayDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String type = '';
    String region = '';
    String notes = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Holiday"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "Holiday Name"),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                    value!.isEmpty ? "Enter holiday name" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Type"),
                    onChanged: (value) => type = value,
                    validator: (value) =>
                    value!.isEmpty ? "Enter holiday type" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Region"),
                    onChanged: (value) => region = value,
                    validator: (value) =>
                    value!.isEmpty ? "Enter holiday region" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Notes"),
                    onChanged: (value) => notes = value,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                      Spacer(),
                      TextButton(
                        child: Text("Pick Date"),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    holidays.add({
                      'date': selectedDate.toIso8601String().split('T')[0],
                      'name': name,
                      'type': type,
                      'region':  region,
                      'notes': notes
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                          setState(() {
                            holidays.removeAt(index);
                          });
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
        onPressed: _showAddHolidayDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Holiday',
      ),
    );
  }
}
