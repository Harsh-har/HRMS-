import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimesheetPagee extends StatefulWidget {
  const TimesheetPagee({super.key});

  @override
  State<TimesheetPagee> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPagee> {
  final TextEditingController _employeeNameController = TextEditingController();
  List<Map<String, dynamic>> _timesheets = [];
  bool _isLoading = false;
  String? _employeeId;
  String? _errorMessage;

  Future<void> _fetchTimesheets() async {
    final employeeName = _employeeNameController.text.trim();
    if (employeeName.isEmpty) {
      setState(() {
        _errorMessage = "Please enter an employee name";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _timesheets = [];
      _employeeId = null;
      _errorMessage = null;
    });

    try {
      debugPrint("Fetching timesheets for employee: $employeeName");

      // 1. Get the employee's timesheets collection
      final timesheetsCollection = FirebaseFirestore.instance
          .collection('weekly_timesheets')
          .doc(employeeName)
          .collection('timesheets');

      // 2. Fetch all timesheets ordered by weekStart
      final querySnapshot = await timesheetsCollection
          .orderBy('weekStart', descending: true)
          .get();

      debugPrint("Found ${querySnapshot.docs.length} timesheets");

      if (querySnapshot.docs.isEmpty) {
        debugPrint("No timesheets found for employee");
        setState(() {
          _errorMessage = "No timesheets found for this employee";
        });
        return;
      }

      // 3. Process timesheet data
      final timesheets = querySnapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint("Processing timesheet: ${doc.id} with data: ${data.toString()}");

        return {
          'id': doc.id,
          'weekStart': data['weekStart'] ?? 'N/A',
          'weekEnd': data['weekEnd'] ?? 'N/A',
          'status': data['status'] ?? 'Draft',
          'overallTotal': data['overallTotal'] ?? 0,
          'totalBreak': data['totalBreak'] ?? 0,
          'projects': List<Map<String, dynamic>>.from(data['projects'] ?? []),
          'timestamp': data['timestamp']?.toDate(),
          'employeeName': employeeName,
          'employeeId': data['employeeId'] ?? 'N/A',
        };
      }).toList();

      // Get employee ID from the first timesheet (assuming it's consistent)
      if (timesheets.isNotEmpty) {
        _employeeId = timesheets.first['employeeId'];
      }

      setState(() {
        _timesheets = timesheets;
      });

    } catch (e, stackTrace) {
      debugPrint("Error fetching data: $e");
      debugPrint("Stack trace: $stackTrace");
      setState(() {
        _errorMessage = "Error fetching data. Please check the employee name and try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTimesheetStatus(String employeeName, String docId, String newStatus) async {
    try {
      debugPrint("Updating timesheet $docId to status: $newStatus");
      await FirebaseFirestore.instance
          .collection('weekly_timesheets')
          .doc(employeeName)
          .collection('timesheets')
          .doc(docId)
          .update({'status': newStatus});

      setState(() {
        final index = _timesheets.indexWhere((ts) => ts['id'] == docId);
        if (index != -1) {
          _timesheets[index]['status'] = newStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e, stackTrace) {
      debugPrint("Error updating status: $e");
      debugPrint("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Timesheets'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),

            if (_employeeNameController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee: ${_employeeNameController.text}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_employeeId != null)
                      Text(
                        'Employee ID: $_employeeId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 16,
                  ),
                ),
              )
            else if (_timesheets.isEmpty)
                const Center(
                  child: Text(
                    "No timesheets to display",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _timesheets.length,
                    itemBuilder: (context, index) {
                      return _buildTimesheetCard(_timesheets[index]);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _employeeNameController,
            decoration: InputDecoration(
              labelText: 'Enter Employee Name',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _fetchTimesheets,
              ),
              errorText: _employeeNameController.text.isEmpty && _errorMessage != null
                  ? _errorMessage
                  : null,
            ),
            onSubmitted: (_) => _fetchTimesheets(),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _fetchTimesheets,
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _buildTimesheetCard(Map<String, dynamic> timesheet) {
    final weekStart = timesheet['weekStart'] as String;
    final weekEnd = timesheet['weekEnd'] as String;
    final status = timesheet['status'] as String;
    final overallTotal = timesheet['overallTotal'] as int;
    final totalBreak = timesheet['totalBreak'] as int;
    final projects = timesheet['projects'] as List<Map<String, dynamic>>;
    final docId = timesheet['id'] as String;
    final employeeName = timesheet['employeeName'] as String;
    final employeeId = timesheet['employeeId'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$weekStart - $weekEnd',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'ID: $employeeId',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: _getStatusColor(status),
                  labelStyle: TextStyle(
                    color: _getStatusTextColor(status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total Hours: $overallTotal | Break Minutes: $totalBreak',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Status update buttons for admin
            if (status == 'Submitted' || status == 'Rejected')
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _updateTimesheetStatus(employeeName, docId, 'Approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  if (status != 'Rejected')
                    ElevatedButton(
                      onPressed: () => _updateTimesheetStatus(employeeName, docId, 'Rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Reject'),
                    ),
                ],
              ),
            const SizedBox(height: 16),

            const Text(
              'Projects:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...projects.map((project) {
              return _buildProjectItem(project);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    final projectName = project['project'] as String? ?? 'Unknown Project';
    final totalHours = project['totalHours'] as int? ?? 0;
    final dailyHours = project['dailyHours'] as List<dynamic>? ?? [];
    final dailyBreaks = project['dailyBreaks'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < dailyHours.length; i++)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Day ${i + 1}: ${dailyHours[i]}h (${dailyBreaks[i]}m)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: $totalHours hours',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'approved':
        return Colors.blue.shade100;
      case 'draft':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green.shade800;
      case 'rejected':
        return Colors.red.shade800;
      case 'approved':
        return Colors.blue.shade800;
      case 'draft':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    super.dispose();
  }
}