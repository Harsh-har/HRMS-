import 'package:flutter/material.dart';

import 'homescreen.dart';

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
    {"icon": Icons.group, "label": "Employee Management"},
    {"icon": Icons.event_note, "label": "Attendance Monitoring"},
    {"icon": Icons.insert_chart, "label": "Leave Management"},
    {"icon": Icons.access_time, "label": "TimeSheets"},
    {"icon": Icons.calendar_today, "label": "Holiday Calender"},
    {"icon": Icons.folder, "label": "Performance Review"},
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
                        child: Icon(Icons.person), // fallback icon
                        onBackgroundImageError: (error, stackTrace) {
                          print("Image load failed: $error");
                        },
                      ),
                      SizedBox(width: 12),
                      Text("Pradeep Tamar",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
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
                    return GestureDetector(
                      onTap: () {
                        if (item["label"] == "Leave Management") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LeaveRequestsPage()),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item["icon"],
                                size: 50, color: Colors.blueAccent),
                            SizedBox(height: 10),
                            Text(item["label"],
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Projects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}


