import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyTimesheetScreen extends StatefulWidget {
  final Map<String, dynamic>? employeeData;

  const WeeklyTimesheetScreen({super.key, this.employeeData});

  @override
  State<WeeklyTimesheetScreen> createState() => _WeeklyTimesheetScreenState();
}

class _WeeklyTimesheetScreenState extends State<WeeklyTimesheetScreen> {
  DateTime? selectedDate;
  String? timesheetDocId; // To store the ID of the existing timesheet document.
  bool _isSubmitted = false;

  final List<List<TextEditingController>> _breakControllers = List.generate(
      5,
          (_) => List.generate(7, (_) => TextEditingController(text: '0'),
          ));

      final List<List<TextEditingController>> _controllers = List.generate(
      5,
          (_) => List.generate(7, (_) => TextEditingController(text: '0'),
          ));

      List<String?> selectedProjects = List.filled(5, null);
  List<String> projectList = [
    'HRM App',
    'E-Commerce App',
    'Inventory Tracker',
    'Payroll System',
    'Employee Portal',
    'CRM Dashboard',
  ];

  String _status = 'Draft';
  final List<String> _statusOptions = ['Draft', 'Send for Approval', 'Submitted'];

  List<DateTime> get weekDates {
    if (selectedDate == null) return [];
    final monday = selectedDate!.subtract(Duration(days: selectedDate!.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      await _loadTimesheetData(); // Call this to check for existing data for the selected week.
    }
  }

  Future<void> _loadTimesheetData() async {
    if (selectedDate == null || widget.employeeData == null) return;

    // Get the start of the selected week.
    final weekStart = selectedDate!.subtract(Duration(days: selectedDate!.weekday - 1));
    final weekStartFormatted = DateFormat('yyyy-MM-dd').format(weekStart);

    // Query Firestore for a timesheet for this employee and week.
    final querySnapshot = await FirebaseFirestore.instance
        .collection('weekly_timesheets')
        .where('employeeId', isEqualTo: widget.employeeData!['employeeId'])
        .where('weekStart', isEqualTo: weekStartFormatted)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Timesheet found, load the data.
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      timesheetDocId = doc.id;

      setState(() {
        _status = data['status'] ?? 'Draft';
        _isSubmitted = _status == 'Submitted';

        // Clear existing controllers and selected projects first.
        for (var row in _controllers) {
          for (var controller in row) {
            controller.text = '0';
          }
        }
        for (var row in _breakControllers) {
          for (var controller in row) {
            controller.text = '0';
          }
        }
        selectedProjects = List.filled(5, null);

        // Populate with loaded data.
        final projectsData = List<Map<String, dynamic>>.from(data['projects'] ?? []);
        for (int i = 0; i < projectsData.length && i < 5; i++) {
          final project = projectsData[i];
          selectedProjects[i] = project['project'];

          final dailyHours = List<int>.from(project['dailyHours'] ?? List.filled(7, 0));
          for (int j = 0; j < dailyHours.length && j < 7; j++) {
            _controllers[i][j].text = dailyHours[j].toString();
          }

          final dailyBreaks = List<int>.from(project['dailyBreaks'] ?? List.filled(7, 0));
          for (int j = 0; j < dailyBreaks.length && j < 7; j++) {
            _breakControllers[i][j].text = dailyBreaks[j].toString();
          }
        }
      });
    } else {
      // No timesheet found, reset the form.
      timesheetDocId = null;
      setState(() {
        _status = 'Draft';
        _isSubmitted = false;
        for (var row in _controllers) {
          for (var controller in row) {
            controller.text = '0';
          }
        }
        for (var row in _breakControllers) {
          for (var controller in row) {
            controller.text = '0';
          }
        }
        selectedProjects = List.filled(5, null);
      });
    }
  }

  int _calculateRowTotal(int row) {
    return _controllers[row].map((c) => int.tryParse(c.text) ?? 0).fold(0, (a, b) => a + b);
  }

  int _calculateDayTotal(int col) {
    return _controllers.map((row) => int.tryParse(row[col].text) ?? 0).fold(0, (a, b) => a + b);
  }

  int _calculateNetHours(int row, int col) {
    final hours = int.tryParse(_controllers[row][col].text) ?? 0;
    final breakMins = int.tryParse(_breakControllers[row][col].text) ?? 0;
    return hours - (breakMins ~/ 60);
  }

  int get overallTotal {
    int total = 0;
    for (var row in _controllers) {
      for (var controller in row) {
        total += int.tryParse(controller.text) ?? 0;
      }
    }
    return total;
  }

  int get totalBreakTime {
    int total = 0;
    for (var row in _breakControllers) {
      for (var controller in row) {
        total += int.tryParse(controller.text) ?? 0;
      }
    }
    return total;
  }

  Future<void> _saveTimesheet({bool submit = false}) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a week date.")),
      );
      return;
    }

    List<Map<String, dynamic>> projectEntries = [];

    for (int i = 0; i < selectedProjects.length; i++) {
      final projectName = selectedProjects[i];
      if (projectName == null || projectName.isEmpty) continue;

      List<int> dailyHours = _controllers[i].map((c) => int.tryParse(c.text) ?? 0).toList();
      List<int> dailyBreaks = _breakControllers[i].map((c) => int.tryParse(c.text) ?? 0).toList();

      projectEntries.add({
        'project': projectName,
        'dailyHours': dailyHours,
        'dailyBreaks': dailyBreaks,
        'totalHours': dailyHours.reduce((a, b) => a + b),
        'totalBreak': dailyBreaks.reduce((a, b) => a + b),
      });
    }

    if (projectEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one project.")),
      );
      return;
    }

    final weekStart = selectedDate!.subtract(Duration(days: selectedDate!.weekday - 1));
    final weekStartFormatted = DateFormat('yyyy-MM-dd').format(weekStart);
    final weekEndFormatted = DateFormat('yyyy-MM-dd').format(weekStart.add(const Duration(days: 6)));

    final timesheetData = {
      'weekStart': weekStartFormatted,
      'weekEnd': weekEndFormatted,
      'projects': projectEntries,
      'overallTotal': overallTotal,
      'totalBreak': totalBreakTime,
      'status': submit ? 'Submitted' : _status,
      'timestamp': FieldValue.serverTimestamp(),
      if (widget.employeeData != null) ...{
        'employeeId': widget.employeeData!['employeeId'],
        'employeeName': widget.employeeData!['name'],
      }
    };

    try {
      if (timesheetDocId != null) {
        // Update existing document
        await FirebaseFirestore.instance.collection('weekly_timesheets').doc(timesheetDocId).update(timesheetData);
      } else {
        // Create new document
        final docRef = await FirebaseFirestore.instance.collection('weekly_timesheets').add(timesheetData);
        timesheetDocId = docRef.id;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Timesheet ${submit ? 'submitted' : 'saved'} successfully")),
      );

      setState(() {
        _isSubmitted = submit;
        _status = submit ? 'Submitted' : _status;
      });

      if (submit) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save timesheet: $e")),
      );
    }
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      value: _status,
      items: _statusOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _isSubmitted ? null : (newValue) {
        setState(() {
          _status = newValue!;
          if (_status == 'Submitted') {
            _saveTimesheet(submit: true);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = weekDates.isEmpty
        ? List.filled(7, '')
        : weekDates.map((d) => DateFormat('EEE\ndd MMM').format(d)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Weekly Timesheet"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _status,
                style: TextStyle(
                  color: _status == 'Rejected'
                      ? Colors.red
                      : _status == 'Submitted'
                      ? Colors.green
                      : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDatePicker(),
            const SizedBox(height: 12),
            if (weekDates.isNotEmpty)
              Text(
                "Week: ${DateFormat('MMM dd').format(weekDates.first)} - ${DateFormat('MMM dd').format(weekDates.last)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 12),
            _buildStatusDropdown(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildTimesheetTable(days),
              ),
            ),
            const SizedBox(height: 16),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Week Starting Date", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Text(
              selectedDate != null
                  ? "${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                  : 'Pick a date',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimesheetTable(List<String> days) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _headerCell("#", flex: 1),
              _headerCell("Project", flex: 2),
              for (var day in days) _headerCell(day),
              _headerCell("Break"),
              _headerCell("Net"),
              _headerCell("Total"),
            ],
          ),
        ),
        for (int row = 0; row < 5; row++) _buildRow(row),
        _buildSummaryRow(),
      ],
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Container(
      width: flex == 2 ? 120 : 60,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }

  Widget _buildRow(int rowIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 40, child: Center(child: Text('${rowIndex + 1}'))),
          SizedBox(
            width: 120,
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedProjects[rowIndex],
              hint: const Text("Select"),
              items: projectList.map((proj) => DropdownMenuItem(value: proj, child: Text(proj))).toList(),
              onChanged: _isSubmitted ? null : (val) => setState(() => selectedProjects[rowIndex] = val),
            ),
          ),
          for (int col = 0; col < 7; col++)
            SizedBox(
              width: 60,
              child: TextField(
                controller: _controllers[rowIndex][col],
                enabled: !_isSubmitted,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _breakControllers[rowIndex][0],
              enabled: !_isSubmitted,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'mins',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                '${_calculateNetHours(rowIndex, 0)}',
                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(width: 60, child: Center(child: Text('${_calculateRowTotal(rowIndex)}'))),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 160, child: Center(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)))),
          for (int i = 0; i < 7; i++)
            SizedBox(
              width: 60,
              child: Center(
                child: Text(
                  '${_calculateDayTotal(i)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                '$totalBreakTime',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade800),
              ),
            ),
          ),
          const SizedBox(width: 60),
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                '$overallTotal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Back"),
        ),
        const Spacer(),
        if (!_isSubmitted) ...[
          OutlinedButton(
            onPressed: () => _saveTimesheet(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text("Save Draft"),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton(
          onPressed: _isSubmitted ? null : () => _saveTimesheet(submit: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSubmitted ? Colors.grey : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            _isSubmitted ? "Submitted" : "Submit Timesheet",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}