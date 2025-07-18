import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  String selectedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  String selectedFilter = 'All';
  bool isLoading = false;
  List<Map<String, dynamic>> allAttendance = [];

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
        _loadAttendanceData();
      });
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      isLoading = true;
      allAttendance = [];
    });

    try {
      // Get all employees first
      final employeesSnapshot = await FirebaseFirestore.instance.collection('employees').get();
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

      // Process each employee's attendance
      for (var employeeDoc in employeesSnapshot.docs) {
        final employeeData = employeeDoc.data();
        final employeeName = employeeData['name'];
        final employeeId = employeeDoc.id;

        // Check each day collection for the selected date
        for (var day in days) {
          try {
            final recordRef = FirebaseFirestore.instance
                .collection('attendance')
                .doc(employeeId)
                .collection(day)
                .doc('record');

            final record = await recordRef.get();

            if (record.exists) {
              final data = record.data()!;
              if (data['date'] == selectedDate) {
                final checkIn = data['checkIn'] ?? '--';
                final checkOut = data['checkOut'] ?? '--';
                final checkInTime = checkIn != '--' ? DateFormat('hh:mm a').parse(checkIn) : null;
                final status = _determineStatus(checkInTime);

                allAttendance.add({
                  'employeeId': employeeId,
                  'name': employeeName,
                  'date': data['date'] ?? '--',
                  'checkIn': checkIn,
                  'checkOut': checkOut,
                  'status': status,
                  'checkInLocation': data['checkInLocation'] ?? null,
                  'checkOutLocation': data['checkOutLocation'] ?? null,
                  'totalWorkedHours': data['totalWorkedHours'] ?? '--',
                  'profileImage': employeeData['profileImage'] ?? '',
                });
              }
            }
          } catch (e) {
            debugPrint('Error loading attendance for $employeeName: $e');
          }
        }
      }

      // Sort by employee name
      allAttendance.sort((a, b) => a['name'].compareTo(b['name']));
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _determineStatus(DateTime? checkInTime) {
    if (checkInTime == null) return 'Absent';

    // Consider 9:30 AM as late (adjust as needed)
    final lateThreshold = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 9, 30);
    return checkInTime.isAfter(lateThreshold) ? 'Late' : 'Present';
  }

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAttendance = selectedFilter == 'All'
        ? allAttendance
        : allAttendance.where((a) => a['status'] == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing: $selectedDate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: ['All', 'Present', 'Late', 'Absent']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : allAttendance.isEmpty
                ? const Center(
              child: Text(
                'No attendance records found',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: filteredAttendance.length,
              itemBuilder: (context, index) {
                final record = filteredAttendance[index];
                return _buildAttendanceCard(record);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    Color statusColor;
    switch (record['status']) {
      case 'Present':
        statusColor = Colors.green;
        break;
      case 'Late':
        statusColor = Colors.orange;
        break;
      case 'Absent':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: record['profileImage'] != null && record['profileImage'].isNotEmpty
                      ? NetworkImage(record['profileImage'])
                      : null,
                  child: record['profileImage'] == null || record['profileImage'].isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${record['status']}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(record['totalWorkedHours']),
                  backgroundColor: Colors.grey[100],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeInfo('Check In', record['checkIn']),
                _buildTimeInfo('Check Out', record['checkOut']),
              ],
            ),
            if (record['checkInLocation'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Check-In Location:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(record['checkInLocation']['address'] ?? 'Location not available'),
            ],
            if (record['checkOutLocation'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Check-Out Location:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(record['checkOutLocation']['address'] ?? 'Location not available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}