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
    {"icon": Icons.group, "label": "Employee"},
    {"icon": Icons.event_note, "label": "LEAVE"},
    {"icon": Icons.insert_chart, "label": "Projects"},
    {"icon": Icons.access_time, "label": "TIMESHEET"},
    {"icon": Icons.calendar_today, "label": "ATTENDANCE"},
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
                        backgroundImage: AssetImage("assets/profile.jpg"),
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'SERVICES'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'APPROVALS'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'MORE'),
        ],
      ),
    );
  }
}

