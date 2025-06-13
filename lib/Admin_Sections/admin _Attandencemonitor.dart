import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceMonitoringScreen extends StatelessWidget {
  const AttendanceMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Attendance Monitoring'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Counters
          int presentCount = 0;
          int lateCount = 0;
          int absentCount = 0;

          List<Map<String, dynamic>> attendanceList = [];

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Absent';

            if (status == 'Present') presentCount++;
            else if (status == 'Late') lateCount++;
            else absentCount++;

            attendanceList.add(data);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard('Total', '${docs.length}', Colors.blue),
                    _buildSummaryCard('Present', '$presentCount', Colors.green),
                    _buildSummaryCard('Late', '$lateCount', Colors.orange),
                    _buildSummaryCard('Absent', '$absentCount', Colors.red),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: attendanceList.length,
                  itemBuilder: (context, index) {
                    final data = attendanceList[index];
                    final name = data['name'] ?? 'Unknown';
                    final status = data['status'] ?? 'Absent';
                    final checkIn = data['checkIn'] ?? '-';
                    final checkOut = data['checkOut'] ?? '-';
                    final profileImage = data['profileImage'] ??
                        'https://via.placeholder.com/150';

                    return Card(
                      margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                        ),
                        title: Text(name),
                        subtitle: Text(
                          'In: $checkIn   Out: $checkOut',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: Chip(
                          label: Text(status),
                          backgroundColor: status == 'Present'
                              ? Colors.green[100]
                              : status == 'Late'
                              ? Colors.orange[100]
                              : Colors.red[100],
                          labelStyle: TextStyle(
                            color: status == 'Present'
                                ? Colors.green
                                : status == 'Late'
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.person, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
