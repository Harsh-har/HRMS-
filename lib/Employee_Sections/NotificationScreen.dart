import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notificationscreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const Notificationscreen({super.key, required this.employeeData});

  @override
  State<Notificationscreen> createState() => _SeenStatusPageState();
}

class _SeenStatusPageState extends State<Notificationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seen Notification"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildLeaveHistory(),
      ),
    );
  }

  Widget _buildLeaveHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leave_requests')
          .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaves = snapshot.data!.docs;

        if (leaves.isEmpty) {
          return const Center(
            child: Text("No Notification found."),
          );
        }

        return ListView(
          children: [
            const SizedBox(height: 10),
            const SizedBox(height: 12),
            ...leaves.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.event_note,
                    color: data['status'] == 'Approved'
                        ? Colors.green
                        : data['status'] == 'Rejected'
                        ? Colors.red
                        : Colors.orange,
                  ),
                  title: Text("${data['leaveType']}"),
                  subtitle: Text(
                    "From ${data['startDate']} to ${data['endDate']}\nReason: ${data['reason']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    data['status'],
                    style: TextStyle(
                      color: data['status'] == 'Approved'
                          ? Colors.green
                          : data['status'] == 'Rejected'
                          ? Colors.red
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
