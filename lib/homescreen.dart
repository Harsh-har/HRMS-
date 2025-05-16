import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaveRequestsPage(),
    );
  }
}

class LeaveRequestsPage extends StatelessWidget {
  final List<Map<String, String>> leaveRequests = [
    {
      'name': 'Harsh Singhal',
      'type': 'Sick Leave',
      'date': '9 May - 19 Nov 2025',
      'duration': '1 day(s)',
      'reason': 'High fever',
      'applied': '19 nov 2022',
      'balance': '',
      'image': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Mayank',
      'type': 'Unpaid Leave',
      'date': '9 May - 19 Nov 2025',
      'duration': '1 day(s)',
      'reason': 'Going to village due to urgency',
      'applied': '19 nov 2022',
      'balance': '',
      'image': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Ansh',
      'type': 'Unpaid Leave',
      'date': '9 May - 19 Nov 2025',
      'duration': '1 day(s)',
      'reason': 'High fever',
      'applied': '19 nov 2022',
      'balance': '0 day(s)',
      'image': 'https://via.placeholder.com/150'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Requests'),
        leading: Icon(Icons.arrow_back),
        actions: [
          Icon(Icons.search),
          Stack(
            children: [
              Icon(Icons.notifications),
              Positioned(
                top: 5,
                right: 0,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.pink),
              ),
            ],
          ),
          SizedBox(width: 12),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'PENDING REQUESTS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text('HISTORY', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: leaveRequests.length,
              itemBuilder: (context, index) {
                final request = leaveRequests[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(request['image']!),
                                radius: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                request['name']!,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: request['type'] == 'Sick Leave'
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    child: Text(
                                      request['type']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: request['type'] == 'Sick Leave'
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Applied on\n${request['applied']}'),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 12),
                          Text('Leave Date\n${request['date']}'),
                          Text('Duration\n${request['duration']}'),
                          if (request['balance']!.isNotEmpty)
                            Text('Leave Balance\n${request['balance']}'),
                          Text('Reason\n${request['reason']}'),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade100,
                                  foregroundColor: Colors.green.shade900,
                                ),
                                child: Text('APPROVE'),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade100,
                                  foregroundColor: Colors.red.shade900,
                                ),
                                child: Text('REJECT'),
                              ),
                              // TextButton(
                              //   onPressed: () {},
                              //   child: Text('EDIT'),
                              // )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
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
