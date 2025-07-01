import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(data['message'] ?? 'No message'),
                  subtitle: Text(
                    data['timestamp'] != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format((data['timestamp'] as Timestamp).toDate())
                        : 'No date',
                  ),
                  trailing: data['status'] == 'unread'
                      ? const Icon(Icons.circle, color: Colors.red, size: 10)
                      : null,
                  onTap: () {
                    // Optional: mark as read
                    doc.reference.update({'status': 'read'});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
