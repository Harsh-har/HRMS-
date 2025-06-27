import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  PlatformFile? _pickedFile;
  String? _fileUrl;

  final List<String> _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Earned Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Comp Off',
    'Work From Home',
  ];

  final Map<String, int> _leaveLimits = {
    'Casual Leave': 5,
    'Sick Leave': 5,
    'Earned Leave': 5,
    'Maternity Leave': 3,
    'Paternity Leave': 2,
    'Comp Off': 3,
    'Work From Home': 2,
  };

  Map<String, int> _pendingByType = {};

  @override
  void initState() {
    super.initState();
    _fetchPendingLeaves();
  }

  Future<void> _fetchPendingLeaves() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('leave_requests')
        .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
        .where('status', isEqualTo: 'Pending')
        .get();

    Map<String, int> typeCount = {};
    for (var doc in snapshot.docs) {
      final type = doc['leaveType'] ?? '';
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    setState(() {
      _pendingByType = typeCount;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  void _submitRequest() async {
    if (_leaveType == null || _startDate == null || _endDate == null || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    if (_pickedFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('leave_attachments/${_pickedFile!.name}');
      final uploadTask = await ref.putData(_pickedFile!.bytes!);
      _fileUrl = await uploadTask.ref.getDownloadURL();
    }

    final leaveData = {
      'employeeId': widget.employeeData['employeeId'],
      'employeeName': widget.employeeData['name'],
      'leaveType': _leaveType,
      'isHalfDay': _isHalfDay,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'reason': _reasonController.text.trim(),
      'attachmentUrl': _fileUrl,
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

  Widget _buildLeaveHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leave_requests')
          .where('employeeId', isEqualTo: widget.employeeData['employeeId'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final leaves = snapshot.data!.docs;

        if (leaves.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("No leave history found."),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text("Leave Request History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...leaves.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.event_note,
                    color: data['status'] == 'Approved'
                        ? Colors.green
                        : data['status'] == 'Rejected'
                        ? Colors.red
                        : Colors.orange,
                  ),
                  title: Text("${data['leaveType']}"),
                  subtitle: Text(
                    "From ${data['startDate']} to ${data['endDate']}\nReason: ${data['reason']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    data['status'],
                    style: TextStyle(
                      color: data['status'] == 'Approved'
                          ? Colors.green
                          : data['status'] == 'Rejected'
                          ? Colors.red
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.employeeData['employeeId'] ?? 'N/A';

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
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Employee ID: $employeeId",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            ),
            const SizedBox(height: 12),
            _buildForm(),
            _buildLeaveHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Leave Type", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  value: _leaveType,
                  items: _leaveTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  hint: const Text("Select Leave Type"),
                  onChanged: (val) => setState(() => _leaveType = val),
                ),
                if (_leaveType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Pending: ${_pendingByType[_leaveType] ?? 0} | Remaining: ${(_leaveLimits[_leaveType] ?? 0) - (_pendingByType[_leaveType] ?? 0)}",
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Half Day?"),
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
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  title: Text(_startDate == null ? "Start Date" : DateFormat('dd MMM yyyy').format(_startDate!)),
                  leading: const Icon(Icons.date_range),
                  onTap: () => _pickDate(true),
                ),
                ListTile(
                  title: Text(_endDate == null ? "End Date" : DateFormat('dd MMM yyyy').format(_endDate!)),
                  leading: const Icon(Icons.date_range),
                  onTap: () => _pickDate(false),
                )
              ],
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Reason for leave",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text("Choose File", style: TextStyle(fontSize: 13)),
                  onPressed: _pickFile,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pickedFile?.name ?? "No file selected",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitRequest,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Submit Leave Request", style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}