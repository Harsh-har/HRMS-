import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  int _selectedTab = 0;
  final double _progress = 0.65; // 65% complete

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR Portal Redesign'),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: _shareProject),
          IconButton(icon: Icon(Icons.more_vert), onPressed: _showMoreOptions),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          _buildProjectHeader(),

          // Quick Actions
          _buildQuickActions(),

          // Tab Navigation
          _buildTabBar(),

          // Main Content Area
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text('PROJ-2024-05'),
                backgroundColor: Colors.blue[100],
              ),
              Spacer(),
              Chip(
                label: Text('On Track', style: TextStyle(color: Colors.green)),
                backgroundColor: Colors.green[100],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'HR Portal Redesign Project',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text('May 1 - Jun 30', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 16),
              Icon(Icons.priority_high, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text('High Priority', style: TextStyle(color: Colors.orange)),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_progress * 100).round()}% Complete'),
              Text('12 days remaining'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.add_task, 'Add Task'),
          _buildActionButton(Icons.person_add, 'Add Team'),
          _buildActionButton(Icons.insert_chart, 'Reports'),
          _buildActionButton(Icons.attach_file, 'Files'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () => _handleAction(label),
        ),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        // You can add border or color here if needed
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Tasks', 1),
          _buildTab('Team', 2),
          _buildTab('Documents', 3),
        ],
      ),
    );

  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: _selectedTab == index ? Colors.blue : Colors.grey,
                fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildOverviewTab();
      case 1: return _buildTasksTab();
      case 2: return _buildTeamTab();
      case 3: return _buildDocumentsTab();
      default: return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Metrics Row
          Row(
            children: [
              _buildMetricCard('Timeline', '12/30 tasks', Icons.timeline),
              SizedBox(width: 16),
              _buildMetricCard('Budget', '\$4,200/\$5,000', Icons.attach_money),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard('Hours', '142/200 hrs', Icons.timer),
              SizedBox(width: 16),
              _buildMetricCard('Team', '5 members', Icons.people),
            ],
          ),
          SizedBox(height: 24),

          // Mini Gantt Chart Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('Gantt Chart Preview')),
          ),
          SizedBox(height: 24),

          // Recent Activity
          Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildActivityItem('Emma completed "UI Design" task'),
          _buildActivityItem('New comment on "Database Schema"'),
          _buildActivityItem('Project status updated to "On Track"'),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 16),
      title: Text(text),
      subtitle: Text('2 hours ago', style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.blue,
                  tabs: [
                    Tab(text: 'To Do (5)'),
                    Tab(text: 'In Progress (3)'),
                    Tab(text: 'Review (2)'),
                    Tab(text: 'Done (12)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTaskList('To Do'),
                      _buildTaskList('In Progress'),
                      _buildTaskList('Review'),
                      _buildTaskList('Done'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(String status) {
    // In a real app, you would filter tasks by status
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildTaskCard('UI Design', 'Emma Wilson', 'May 28', status),
        _buildTaskCard('Database Schema', 'John Smith', 'May 30', status),
        _buildTaskCard('API Integration', 'Sarah Lee', 'Jun 2', status),
      ],
    );
  }

  Widget _buildTaskCard(String title, String assignee, String dueDate, String status) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignee),
            Text('Due $dueDate', style: TextStyle(color: Colors.red)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => _showTaskOptions(title),
        ),
      ),
    );
  }

  Widget _buildTeamTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTeamMember('Emma Wilson', 'UI/UX Designer', 'assets/avatar1.jpg'),
        _buildTeamMember('John Smith', 'Backend Developer', 'assets/avatar2.jpg'),
        _buildTeamMember('Sarah Lee', 'Frontend Developer', 'assets/avatar3.jpg'),
        _buildTeamMember('Michael Brown', 'Project Manager', 'assets/avatar4.jpg'),
        _buildTeamMember('Lisa Wong', 'QA Tester', 'assets/avatar5.jpg'),
      ],
    );
  }

  Widget _buildTeamMember(String name, String role, String avatar) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: AssetImage(avatar)),
        title: Text(name),
        subtitle: Text(role),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.message), onPressed: () {}),
            IconButton(icon: Icon(Icons.info), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return GridView.count(
      padding: EdgeInsets.all(16),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      children: [
        _buildDocumentCard('Project Brief', Icons.description),
        _buildDocumentCard('Requirements', Icons.list_alt),
        _buildDocumentCard('Wireframes', Icons.image),
        _buildDocumentCard('Meeting Notes', Icons.note),
        _buildDocumentCard('Test Cases', Icons.checklist),
        _buildDocumentCard('Final Report', Icons.assignment),
      ],
    );
  }

  Widget _buildDocumentCard(String title, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () => _openDocument(title),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Action Handlers
  void _shareProject() {
    // Implement share functionality
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Project'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('View Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics
              },
            ),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archive Project'),
              onTap: () {
                Navigator.pop(context);
                // Archive project
              },
            ),
          ],
        );
      },
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'Add Task':
      // Navigate to add task screen
        break;
      case 'Add Team':
      // Navigate to add team screen
        break;
      case 'Reports':
      // Navigate to reports screen
        break;
      case 'Files':
      // Navigate to files screen
        break;
    }
  }

  void _showTaskOptions(String taskName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit $taskName'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete $taskName'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Change Priority'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _openDocument(String docName) {
    // Implement document opening
  }
}