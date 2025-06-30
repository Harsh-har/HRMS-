import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No notifications found."));

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isUnread = !(data['read'] ?? false);
              final timestamp = data['timestamp'] as Timestamp?;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                tileColor: isUnread ? Colors.blue[50] : Colors.grey[100],
                title: Text(data['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['message'] ?? ''),
                    if (timestamp != null)
                      Text(
                        DateFormat('MMM dd, yyyy – hh:mm a').format(timestamp.toDate()),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                  ],
                ),
                trailing: isUnread
                    ? Icon(Icons.circle, color: Colors.blueAccent, size: 10)
                    : null,
                onTap: () async {
                  // Mark as read when tapped
                  await docs[index].reference.update({'read': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}
