import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SubmitLeaveRequestPage extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const SubmitLeaveRequestPage({super.key, required this.employeeData});

  @override
  State<SubmitLeaveRequestPage> createState() => _SubmitLeaveRequestPageState();
}

class _SubmitLeaveRequestPageState extends State<SubmitLeaveRequestPage> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _leaveType;

  final List<String> _leaveTypes = ['Sick Leave', 'Casual Leave', 'Paid Leave'];

  void _submitLeaveRequest() async {
    if (_leaveType == null || _startDate == null || _endDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final leaveRequest = {
      'employeeId': widget.employeeData['id'] ?? '',
      'employeeName': widget.employeeData['name'] ?? '',
      'leaveType': _leaveType,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'reason': _reasonController.text,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('leave_requests').add(leaveRequest);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave request submitted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error submitting leave: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting leave request")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()).add(Duration(days: 1)),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Leave Request")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _leaveType,
              hint: Text("Select Leave Type"),
              items: _leaveTypes.map((String type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _leaveType = val),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(_startDate == null
                        ? "Select Start Date"
                        : "From: ${DateFormat('yyyy-MM-dd').format(_startDate!)}"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startDate == null ? null : () => _selectDate(context, false),
                    child: Text(_endDate == null
                        ? "Select End Date"
                        : "To: ${DateFormat('yyyy-MM-dd').format(_endDate!)}"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitLeaveRequest,
              child: Text("Submit Request"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
