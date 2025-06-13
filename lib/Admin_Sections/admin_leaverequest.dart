import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('leave_requests')
                  .where('status', isEqualTo: 'Pending') // Show only pending
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No pending leave requests.'));
                }

                final leaveRequests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: leaveRequests.length,
                  itemBuilder: (context, index) {
                    final doc = leaveRequests[index];
                    final request = doc.data() as Map<String, dynamic>;

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
                                    backgroundImage: NetworkImage(request['image'] ?? 'https://via.placeholder.com/150'),
                                    radius: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      request['name'] ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
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
                                          request['type'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: request['type'] == 'Sick Leave'
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Applied on\n${request['applied'] ?? ''}', textAlign: TextAlign.right),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
                              Text('Leave Date\n${request['date'] ?? ''}'),
                              SizedBox(height: 4),
                              Text('Duration\n${request['duration'] ?? ''}'),
                              if ((request['balance'] ?? '').toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('Leave Balance\n${request['balance']}'),
                                ),
                              SizedBox(height: 4),
                              Text('Reason\n${request['reason'] ?? ''}'),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('leave_requests')
                                          .doc(doc.id)
                                          .update({'status': 'Approved'});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade100,
                                      foregroundColor: Colors.green.shade900,
                                    ),
                                    child: Text('APPROVE'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('leave_requests')
                                          .doc(doc.id)
                                          .update({'status': 'Rejected'});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade100,
                                      foregroundColor: Colors.red.shade900,
                                    ),
                                    child: Text('REJECT'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
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
