import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
      final dayName = DateFormat('EEEE').format(_selectedDate); // e.g. Monday

      final employeesSnapshot =
      await FirebaseFirestore.instance.collection('employees').get();

      final futures = employeesSnapshot.docs.map((employeeDoc) async {
        final employeeData = employeeDoc.data();

        final attendanceRef = FirebaseFirestore.instance
            .collection('attendance')
            .doc(employeeData['name'])
            .collection(dayName)
            .doc('record');

        final attendanceDoc = await attendanceRef.get();

        if (attendanceDoc.exists) {
          final attendanceData = attendanceDoc.data()!;
          if (attendanceData['date'] == formattedDate) {
            return {
              'employeeId': employeeData['employeeId'],
              'name': employeeData['name'],
              'position': employeeData['position'],
              'checkIn': attendanceData['checkIn'] ?? '--',
              'checkOut': attendanceData['checkOut'] ?? '--',
              'status': attendanceData['checkIn'] != null
                  ? (attendanceData['checkOut'] != null ? 'Present' : 'Working')
                  : 'Absent',
              'checkInLocation': attendanceData['checkInLocation']?['address'] ?? '--',
              'checkOutLocation':
              attendanceData['checkOutLocation']?['address'] ?? '--',
              'totalWorkedHours': attendanceData['totalWorkedHours'] ?? '--',
            };
          }
        }

        return {
          'employeeId': employeeData['employeeId'],
          'name': employeeData['name'],
          'position': employeeData['position'],
          'checkIn': '--',
          'checkOut': '--',
          'status': 'Absent',
          'checkInLocation': '--',
          'checkOutLocation': '--',
          'totalWorkedHours': '--',
        };
      }).toList();

      final data = await Future.wait(futures);

      setState(() {
        _attendanceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchAttendanceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Attendance for ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _attendanceData.isEmpty
                ? const Center(child: Text('No attendance records found'))
                : ListView.builder(
              itemCount: _attendanceData.length,
              itemBuilder: (context, index) {
                final record = _attendanceData[index];
                return _buildAttendanceCard(record);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record['name'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    record['status'],
                    style: TextStyle(
                      color: record['status'] == 'Absent'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  backgroundColor: record['status'] == 'Absent'
                      ? Colors.red[50]
                      : Colors.green[50],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${record['employeeId']} | ${record['position']}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTimeInfo('Check In', record['checkIn']),
                const SizedBox(width: 16),
                _buildTimeInfo('Check Out', record['checkOut']),
                const SizedBox(width: 16),
                _buildTimeInfo('Worked', record['totalWorkedHours']),
              ],
            ),
            const SizedBox(height: 8),
            if (record['checkIn'] != '--')
              Text(
                'Check-in Location: ${record['checkInLocation']}',
                style: const TextStyle(fontSize: 12),
              ),
            if (record['checkOut'] != '--')
              Text(
                'Check-out Location: ${record['checkOutLocation']}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
