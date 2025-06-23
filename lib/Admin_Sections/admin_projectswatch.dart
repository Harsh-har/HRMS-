import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  int _selectedTab = 0;
  final double _progress = 0.65;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        actions: [
          IconButton(icon: Icon(Icons.more_vert), onPressed: _showMoreOptions),
        ],
      ),
      body: Column(
        children: [
          _buildProjectHeader(),
          _buildQuickActions(),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
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
              Chip(label: Text('PROJ-2024-05')),
              Spacer(),
              Chip(
                label: Text('On Track', style: TextStyle(color: Colors.green)),
                backgroundColor: Colors.green[100],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'HR Portal Redesign',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text('May 1 - Jun 30', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 16),
              Icon(Icons.flag, size: 16, color: Colors.orange),
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
              Text('12 days left'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.add_task, 'Add Task'),
          _buildActionButton(Icons.insert_chart, 'Reports'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), onPressed: () => _handleAction(label)),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Tasks', 1),
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
    return _selectedTab == 0 ? _buildOverviewTab() : _buildTasksTab();
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
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
              _buildMetricCard('Team Size', '5 members', Icons.people),
            ],
          ),
          SizedBox(height: 24),
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('Gantt Chart Preview')),
          ),
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
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTaskCard('UI Design', 'Emma', 'May 28', 'To Do'),
        _buildTaskCard('Backend Setup', 'John', 'Jun 2', 'In Progress'),
        _buildTaskCard('QA Testing', 'Lisa', 'Jun 15', 'Review'),
      ],
    );
  }

  Widget _buildTaskCard(String title, String assignee, String dueDate, String status) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text('$assignee • Due $dueDate'),
        trailing: Icon(Icons.more_vert),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Project'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.archive),
            title: Text('Archive Project'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _handleAction(String label) {
    // Placeholder action navigation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clicked: $label')));
  }
}
