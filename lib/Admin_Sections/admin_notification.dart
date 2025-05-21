import 'package:flutter/material.dart';

class AdminNotification extends StatefulWidget {
  @override
  _HRMNotificationScreenState createState() => _HRMNotificationScreenState();
}

class _HRMNotificationScreenState extends State<AdminNotification> {
  // Sample notification data
  final List<Map<String, dynamic>> _allNotifications = [
    {
      'type': 'leave',
      'title': 'Leave Request Approved',
      'message': 'Your leave request for May 15-17 has been approved',
      'time': '10:30 AM',
      'date': 'Today',
      'read': false,
      'action': 'view_leave'
    },
    {
      'type': 'payroll',
      'title': 'Payslip Available',
      'message': 'Your payslip for April 2024 is now available',
      'time': '9:15 AM',
      'date': 'Today',
      'read': false,
      'action': 'view_payslip'
    },
    {
      'type': 'announcement',
      'title': 'Company Update',
      'message': 'Monthly all-hands meeting scheduled for May 25',
      'time': 'Yesterday',
      'date': 'May 10',
      'read': true,
      'action': 'view_announcement'
    },
    {
      'type': 'task',
      'title': 'New Task Assigned',
      'message': 'You have been assigned a new project: HR Portal Redesign',
      'time': 'Yesterday',
      'date': 'May 10',
      'read': true,
      'action': 'view_task'
    },
    {
      'type': 'birthday',
      'title': 'Birthday Reminder',
      'message': 'Sarah from Marketing has a birthday today',
      'time': 'May 9',
      'date': 'May 9',
      'read': true,
      'action': 'view_profile'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter Notifications',
          ),
          IconButton(
            icon: Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          // Notification categories tab bar
          _buildCategoryTabs(),
          // Notification list
          Expanded(
            child: ListView.builder(
              itemCount: _allNotifications.length,
              itemBuilder: (context, index) {
                final notification = _allNotifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryTab('All', true),
          _buildCategoryTab('Leave', false),
          _buildCategoryTab('Payroll', false),
          _buildCategoryTab('Tasks', false),
          _buildCategoryTab('Announcements', false),
          _buildCategoryTab('Birthdays', false),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification['read'] ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: _getNotificationIcon(notification['type']),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notification['date'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 8),
                Text(
                  notification['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => _showNotificationOptions(notification),
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'leave':
        return Icon(Icons.beach_access, color: Colors.orange);
      case 'payroll':
        return Icon(Icons.attach_money, color: Colors.green);
      case 'announcement':
        return Icon(Icons.announcement, color: Colors.blue);
      case 'task':
        return Icon(Icons.assignment, color: Colors.purple);
      case 'birthday':
        return Icon(Icons.cake, color: Colors.pink);
      default:
        return Icon(Icons.notifications, color: Colors.grey);
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filter Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All Notifications', true),
              _buildFilterOption('Unread Only', false),
              _buildFilterOption('Leave Requests', false),
              _buildFilterOption('Payroll Updates', false),
              _buildFilterOption('Company Announcements', false),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Apply Filters'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, bool selected) {
    return ListTile(
      title: Text(title),
      trailing: selected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        // Handle filter selection
        Navigator.pop(context);
      },
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _showNotificationOptions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.mark_email_read),
                title: Text('Mark as ${notification['read'] ? 'unread' : 'read'}'),
                onTap: () {
                  setState(() {
                    notification['read'] = !notification['read'];
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Notification'),
                onTap: () {
                  setState(() {
                    _allNotifications.remove(notification);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_off),
                title: Text('Turn off this type'),
                onTap: () {
                  // Handle notification type mute
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['read'] = true;
    });

    // Handle different notification types
    switch (notification['action']) {
      case 'view_leave':
      // Navigate to leave details
        break;
      case 'view_payslip':
      // Navigate to payslip
        break;
      case 'view_announcement':
      // Navigate to announcement
        break;
      case 'view_task':
      // Navigate to task
        break;
      case 'view_profile':
      // Navigate to colleague profile
        break;
    }
  }
}