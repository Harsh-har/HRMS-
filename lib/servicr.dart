import 'package:flutter/material.dart';

void main() => runApp(EmployeeApp());

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems = [
    {"icon": Icons.group, "label": "Mark Attendance"},
    {"icon": Icons.event_note, "label": "Apply LEAVE"},
    {"icon": Icons.insert_chart, "label": "Projects"},
    {"icon": Icons.access_time, "label": "TimeSheets"},
    {"icon": Icons.calendar_today, "label": "Holiday Calender"},
    {"icon": Icons.folder, "label": "FILES"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage("assets/profile/profileuser.png"),
                      ),
                      SizedBox(width: 12),
                      Text("Harsh", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 16),

                      Icon(Icons.notifications),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              // Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: gridItems.map((item) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item["icon"], size: 50, color: Colors.blueAccent),
                          SizedBox(height: 10),
                          Text(item["label"], style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
    type: BottomNavigationBarType.fixed, // Important to allow backgroundColor
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.black, // This sets the background- color
    items: const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Projects'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
    ],
    ),
    );
  }
}

