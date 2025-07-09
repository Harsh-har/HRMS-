import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';


class HolidayCalendarAdminScreen extends StatefulWidget {
  @override
  _HolidayCalendarAdminScreenState createState() => _HolidayCalendarAdminScreenState();
}

class _HolidayCalendarAdminScreenState extends State<HolidayCalendarAdminScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, String>> holidays = [];

  @override
  void initState() {
    super.initState();
    _loadHolidaysFromFirestore();
  }

  Future<void> _loadHolidaysFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('holidays').get();
    setState(() {
      holidays = snapshot.docs.map((doc) => Map<String, String>.from(doc.data())).toList();
    });
  }

  List<Map<String, String>> getHolidaysForDay(DateTime date) {
    return holidays.where((h) =>
    DateTime.parse(h['date']!).day == date.day &&
        DateTime.parse(h['date']!).month == date.month &&
        DateTime.parse(h['date']!).year == date.year
    ).toList();
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
                    validator: (value) => value!.isEmpty ? "Enter holiday name" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Type"),
                    onChanged: (value) => type = value,
                    validator: (value) => value!.isEmpty ? "Enter holiday type" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Region"),
                    onChanged: (value) => region = value,
                    validator: (value) => value!.isEmpty ? "Enter holiday region" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Notes"),
                    onChanged: (value) => notes = value,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      Spacer(),
                      TextButton(
                        child: Text("Pick Date"),
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(now.year, now.month, now.day),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Map<String, String> newHoliday = {
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'name': name,
                    'type': type,
                    'region': region,
                    'notes': notes,
                  };
                  await FirebaseFirestore.instance.collection('holidays').add(newHoliday);
                  setState(() {
                    holidays.add(newHoliday);
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

  Future<void> _exportToCSV() async {
    List<List<String>> csvData = [
      ['Date', 'Name', 'Type', 'Region', 'Notes'],
      ...holidays.map((h) => [
        h['date'] ?? '',
        h['name'] ?? '',
        h['type'] ?? '',
        h['region'] ?? '',
        h['notes'] ?? ''
      ])
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/holiday_calendar.csv';
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV downloaded to: $path")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Calendar'),
        actions: [
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: Icon(Icons.file_download), onPressed: _exportToCSV),
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
          Expanded(
            child: ListView.builder(
              itemCount: holidays.length,
              itemBuilder: (context, index) {
                final holiday = holidays[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.beach_access, color: Colors.teal),
                    title: Text(holiday['name'] ?? ''),
                    subtitle: Text("${holiday['date']} • ${holiday['type']} • ${holiday['region']}"),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(child: Text("Edit"), value: "edit"),
                        PopupMenuItem(child: Text("Delete"), value: "delete"),
                      ],
                      onSelected: (value) async {
                        if (value == "delete") {
                          setState(() {
                            holidays.removeAt(index);
                          });
                          QuerySnapshot snapshot = await FirebaseFirestore.instance
                              .collection('holidays')
                              .where('date', isEqualTo: holiday['date'])
                              .where('name', isEqualTo: holiday['name'])
                              .get();
                          for (var doc in snapshot.docs) {
                            await doc.reference.delete();
                          }
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