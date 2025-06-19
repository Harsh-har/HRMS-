import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProjectScreen extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const UserProjectScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    final String employeeName = employeeData['name'] ?? 'Employee';

    return Scaffold(
      appBar: AppBar(
        title: Text("$employeeName's Projects"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .where('assignedTo', isEqualTo: employeeName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data?.docs ?? [];

          if (projects.isEmpty) {
            return Center(
              child: Text(
                'No projects assigned.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final title = project['title'] ?? 'Untitled';
              final projectId = project['projectId'] ?? '';
              final status = project['status'] ?? 'Pending';
              final start = project['startDate'] ?? '';
              final end = project['endDate'] ?? '';
              final progress = (project['progress'] ?? 0.0).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(label: Text(projectId)),
                          const Spacer(),
                          Chip(
                            label: Text(status),
                            backgroundColor: status == 'On Track'
                                ? Colors.green[100]
                                : Colors.orange[100],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("$start - $end", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text("${(progress * 100).round()}% Complete"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
