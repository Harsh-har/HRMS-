import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isHalfDay = false;

  final List<String> _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Earned Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Comp Off',
    'Work From Home',
  ];

  void _submitRequest() async {
    if (_leaveType == null || _startDate == null || _endDate == null || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final leaveData = {
      'employeeId': widget.employeeData['id'],
      'employeeName': widget.employeeData['name'],
      'leaveType': _leaveType,
      'isHalfDay': _isHalfDay,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'reason': _reasonController.text.trim(),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('leave_requests').add(leaveData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave request submitted")),
    );
    Navigator.pop(context);
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey.shade100,
      leading: const Icon(Icons.calendar_today),
      title: Text(
        date == null ? label : DateFormat('dd MMM yyyy').format(date),
        style: const TextStyle(fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_drop_down),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Request Leave"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // LEAVE TYPE
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Leave Type"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      value: _leaveType,
                      items: _leaveTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      hint: const Text("Select Leave Type"),
                      onChanged: (val) => setState(() => _leaveType = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Is Half Day?", style: TextStyle(fontSize: 14)),
                        Switch(
                          value: _isHalfDay,
                          onChanged: (val) => setState(() => _isHalfDay = val),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DATE PICKERS
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSectionTitle("Leave Dates"),
                    const SizedBox(height: 8),
                    _buildDateTile("Start Date", _startDate, () => _pickDate(true)),
                    const SizedBox(height: 12),
                    _buildDateTile("End Date", _endDate, () => _pickDate(false)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // REASON
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Reason"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Write your reason here...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                ),
                label: const Text("Submit Leave Request", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
