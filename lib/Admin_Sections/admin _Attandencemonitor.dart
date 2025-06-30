import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceMonitoringScreen extends StatefulWidget {
  const AttendanceMonitoringScreen({super.key});

  @override
  State<AttendanceMonitoringScreen> createState() => _AttendanceMonitoringScreenState();
}

class _AttendanceMonitoringScreenState extends State<AttendanceMonitoringScreen> {
  String selectedStatus = 'All';
  String selectedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Attendance Monitoring'),
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance_records')
            .doc(selectedDate)
            .collection('employees')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No attendance data for $selectedDate'));
          }

          final docs = snapshot.data!.docs;

          // Calculate counts
          int presentCount = 0;
          int lateCount = 0;
          int absentCount = 0;

          final attendanceList = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Absent';

            if (status == 'Present') presentCount++;
            else if (status == 'Late') lateCount++;
            else absentCount++;

            return data;
          }).toList();

          // Apply filter
          final filteredList = selectedStatus == 'All'
              ? attendanceList
              : attendanceList.where((d) => d['status'] == selectedStatus).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard('Total', '${docs.length}', Icons.people, Colors.blue),
                    _buildSummaryCard('Present', '$presentCount', Icons.check_circle, Colors.green),
                    _buildSummaryCard('Late', '$lateCount', Icons.access_time, Colors.orange),
                    _buildSummaryCard('Absent', '$absentCount', Icons.cancel, Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Showing data for: $selectedDate',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text("No data found for selected status."))
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = filteredList[index];
                    final name = data['name'] ?? 'Unknown';
                    final status = data['status'] ?? 'Absent';
                    final checkIn = data['checkIn'] != null
                        ? DateFormat('hh:mm a').format(data['checkIn'].toDate())
                        : '-';
                    final checkOut = data['checkOut'] != null
                        ? DateFormat('hh:mm a').format(data['checkOut'].toDate())
                        : '-';
                    final workedHours = data['workedHours'] ?? '-';
                    final profileImage = data['profileImage'] ?? 'https://via.placeholder.com/150';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                          radius: 24,
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Check-In: $checkIn'),
                              Text('Check-Out: $checkOut'),
                              if (workedHours != '-') Text('Worked: $workedHours'),
                            ],
                          ),
                        ),
                        trailing: _buildStatusBadge(status),
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

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    final isSelected = (label == 'Total' && selectedStatus == 'All') || selectedStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = label == 'Total' ? 'All' : label;
        });
      },
      child: Container(
        width: 75,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Present':
        color = Colors.green;
        icon = Icons.check;
        break;
      case 'Late':
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      default:
        color = Colors.red;
        icon = Icons.close;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}