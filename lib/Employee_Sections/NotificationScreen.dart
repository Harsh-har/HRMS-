import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  final String employeeId;
  const NotificationScreen({super.key, required this.employeeId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    List<Map<String, dynamic>> temp = [];

    final leaveSnapshot = await FirebaseFirestore.instance
        .collection('leave_requests')
        .where('employeeId', isEqualTo: widget.employeeId)
        .orderBy('updatedAt', descending: true)
        .get();

    for (var doc in leaveSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'Approved' || data['status'] == 'Rejected') {
        final updatedAt = data['updatedAt'] is Timestamp
            ? (data['updatedAt'] as Timestamp).toDate().toString().split(' ')[0]
            : '';
        temp.add({
          'title': 'Leave ${data['status']}',
          'subtitle': '${data['leaveType']} leave from ${data['from']} to ${data['to']}',
          'date': updatedAt,
          'type': data['status'] == 'Approved' ? 'success' : 'alert'
        });
      }
    }

    final holidaySnapshot = await FirebaseFirestore.instance.collection('holidays').get();
    for (var doc in holidaySnapshot.docs) {
      final data = doc.data();
      temp.add({
        'title': 'New Holiday',
        'subtitle': '${data['name']} on ${data['date']}',
        'date': data['date'],
        'type': 'info'
      });
    }

    temp.sort((a, b) => b['date'].compareTo(a['date']));

    setState(() {
      _notifications = temp;
    });
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  Icon _getIconByType(String type) {
    switch (type) {
      case 'success':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'info':
        return Icon(Icons.info, color: Colors.blue);
      case 'warning':
        return Icon(Icons.warning, color: Colors.orange);
      case 'alert':
        return Icon(Icons.error, color: Colors.red);
      default:
        return Icon(Icons.notifications, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.blue[700],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _notifications.isEmpty
            ? ListView(
          children: [
            SizedBox(height: 300),
            Center(child: Text("No notifications")),
          ],
        )
            : ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: _notifications.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) {
            final item = _notifications[index];

            return Dismissible(
              key: UniqueKey(),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                setState(() {
                  _notifications.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Notification dismissed")),
                );
              },
              child: ListTile(
                leading: _getIconByType(item['type']!),
                title: Text(item['title']!),
                subtitle: Text(item['subtitle']!),
                trailing: Text(item['date'] ?? '', style: TextStyle(color: Colors.grey)),
              ),
            );
          },
        ),
      ),
    );
  }
}
