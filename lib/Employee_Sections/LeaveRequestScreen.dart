import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();

  final List<Map<String, dynamic>> _leaveHistory = [
    {
      "type": "Casual Leave",
      "from": DateTime(2025, 5, 10),
      "to": DateTime(2025, 5, 12),
      "status": "Approved",
    },
    {
      "type": "Sick Leave",
      "from": DateTime(2025, 4, 5),
      "to": DateTime(2025, 4, 7),
      "status": "Rejected",
    },
    {
      "type": "Earned Leave",
      "from": DateTime(2025, 3, 20),
      "to": DateTime(2025, 3, 22),
      "status": "Pending",
    },
  ];

  Future<void> _pickDate({required bool isFrom}) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? now) : (_toDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  void _submitLeaveRequest() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted successfully!')),
      );

      setState(() {
        _selectedLeaveType = null;
        _fromDate = null;
        _toDate = null;
        _reasonController.clear();
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Leave Request'),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply Leave',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedLeaveType,
                      decoration: InputDecoration(
                        labelText: 'Leave Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Casual Leave', child: Text('Casual Leave')),
                        DropdownMenuItem(value: 'Sick Leave', child: Text('Sick Leave')),
                        DropdownMenuItem(value: 'Earned Leave', child: Text('Earned Leave')),
                        DropdownMenuItem(value: 'Maternity Leave', child: Text('Maternity Leave')),
                        DropdownMenuItem(value: 'Paternity Leave', child: Text('Paternity Leave')),
                      ],
                      onChanged: (val) => setState(() => _selectedLeaveType = val),
                      validator: (val) => val == null ? 'Please select a leave type' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(isFrom: true),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'From Date',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                controller: TextEditingController(text: _formatDate(_fromDate)),
                                validator: (val) => _fromDate == null ? 'Select from date' : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(isFrom: false),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'To Date',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                controller: TextEditingController(text: _formatDate(_toDate)),
                                validator: (val) => _toDate == null ? 'Select to date' : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter a reason' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitLeaveRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[900],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Submit Leave Request',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Leave Status / History',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              _leaveHistory.isEmpty
                  ? const Center(child: Text("No leave requests found.", style: TextStyle(color: Colors.black54)))
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaveHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final leave = _leaveHistory[index];
                  final fromDate = leave['from'] as DateTime;
                  final toDate = leave['to'] as DateTime;
                  final status = leave['status'] as String;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        leave['type'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}'),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
