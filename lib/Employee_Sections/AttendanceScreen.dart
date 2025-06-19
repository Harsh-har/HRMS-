import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slide_to_act/slide_to_act.dart';

class NewAttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  const NewAttendanceScreen({super.key, required this.employeeData});

  @override
  State<NewAttendanceScreen> createState() => _NewAttendanceScreenState();
}

class _NewAttendanceScreenState extends State<NewAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late String _timeString;
  late String _dateString;
  bool isCheckedIn = false;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  List<Map<String, dynamic>> lastFiveRecords = [];
  double totalWorkedHours = 0.0;

  final GlobalKey<SlideActionState> _slideKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    _fetchTodayAttendance();
    _fetchLastFiveRecords();
    _fetchTotalWorkedHours();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString = DateFormat('hh:mm:ss a').format(now);
      _dateString = DateFormat('dd MMM yyyy').format(now);
    });
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  Future<void> _fetchTodayAttendance() async {
    final today = DateTime.now();
    final dayName = _getDayName(today);
    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.employeeData['name'])
        .collection(dayName)
        .doc('record')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        checkInTime = data['checkIn'] != null
            ? DateFormat('hh:mm a').parse(data['checkIn'])
            : null;
        checkOutTime = data['checkOut'] != null
            ? DateFormat('hh:mm a').parse(data['checkOut'])
            : null;
        isCheckedIn = checkInTime != null && checkOutTime == null;
      });
    }
  }

  Future<void> _fetchLastFiveRecords() async {
    final name = widget.employeeData['name'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<Map<String, dynamic>> records = [];

    for (var day in days) {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(name)
          .collection(day)
          .doc('record')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        records.add({
          'date': data['date'] ?? '--',
          'checkIn': data['checkIn'] ?? '--',
          'checkOut': data['checkOut'] ?? '--',
        });
      }
    }

    // Sort records by date in descending order
    records.sort((a, b) {
      try {
        final dateA = DateFormat('dd MMM yyyy').parse(a['date']);
        final dateB = DateFormat('dd MMM yyyy').parse(b['date']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      lastFiveRecords = records.take(5).toList();
    });
  }

  Future<void> _fetchTotalWorkedHours() async {
    final name = widget.employeeData['name'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    double total = 0.0;

    for (var day in days) {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(name)
          .collection(day)
          .doc('record')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['checkIn'] != null && data['checkOut'] != null && data['date'] != null) {
          try {
            final date = DateFormat('dd MMM yyyy').parse(data['date']);
            final checkInTime = DateFormat('hh:mm a').parse(data['checkIn']);
            final checkOutTime = DateFormat('hh:mm a').parse(data['checkOut']);
            // Combine date with time
            final checkIn = DateTime(
              date.year,
              date.month,
              date.day,
              checkInTime.hour,
              checkInTime.minute,
            );
            final checkOut = DateTime(
              date.year,
              date.month,
              date.day,
              checkOutTime.hour,
              checkOutTime.minute,
            );
            final worked = checkOut.difference(checkIn);
            total += worked.inMinutes / 60.0;
          } catch (e) {
            // Skip invalid records
            continue;
          }
        }
      }
    }

    setState(() {
      totalWorkedHours = total;
    });
  }

  Future<void> _handleSlideComplete() async {
    final now = DateTime.now();
    final dayName = _getDayName(now);
    final dateFormatted = DateFormat('dd MMM yyyy').format(now);
    final docRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.employeeData['name'])
        .collection(dayName)
        .doc('record');
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      if (data.containsKey('checkIn') && data.containsKey('checkOut')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already checked in and out today!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        _slideKey.currentState?.reset();
        return;
      }
    }

    if (!snapshot.exists) {
      checkInTime = now;
      await docRef.set({
        'checkIn': DateFormat('hh:mm a').format(now),
        'date': dateFormatted,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isCheckedIn = true;
        checkOutTime = null;
      });
    } else {
      final data = snapshot.data()!;
      if (data.containsKey('checkIn') && !data.containsKey('checkOut')) {
        final date = DateFormat('dd MMM yyyy').parse(data['date']);
        final checkInTime = DateFormat('hh:mm a').parse(data['checkIn']);
        final checkIn = DateTime(
          date.year,
          date.month,
          date.day,
          checkInTime.hour,
          checkInTime.minute,
        );
        checkOutTime = now;
        final checkOut = DateTime(
          date.year,
          date.month,
          date.day,
          now.hour,
          now.minute,
        );
        final worked = checkOut.difference(checkIn);
        final hours = worked.inMinutes / 60.0;
        final hr = hours.floor();
        final min = ((hours - hr) * 60).round();

        await docRef.update({
          'checkOut': DateFormat('hh:mm a').format(now),
          'totalWorkedHours': '$hr hr ${min.toString().padLeft(2, '0')} min',
        });

        setState(() {
          isCheckedIn = false;
        });
      }
    }

    _slideKey.currentState?.reset();
    await _fetchTodayAttendance();
    await _fetchLastFiveRecords();
    await _fetchTotalWorkedHours();

    _animationController.reset();
    _animationController.forward();
  }

  String _formatTotalWorkedHours(double hours) {
    final hr = hours.floor();
    final min = ((hours - hr) * 60).round();
    return '$hr hr ${min.toString().padLeft(2, '0')} min';
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Attendance Dashboard"),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${widget.employeeData['name']}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$_dateString | $_timeString",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Activity",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoColumn(
                            "Check In",
                            checkInTime != null
                                ? DateFormat('hh:mm a').format(checkInTime!)
                                : '--',
                          ),
                          _buildInfoColumn(
                            "Check Out",
                            checkOutTime != null
                                ? DateFormat('hh:mm a').format(checkOutTime!)
                                : '--',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideAction(
                key: _slideKey,
                borderRadius: 30,
                elevation: 6,
                innerColor: isCheckedIn ? Colors.red[600] : Colors.green[600],
                outerColor: isCheckedIn ? Colors.red[100] : Colors.green[100],
                sliderButtonIcon: Icon(
                  isCheckedIn ? Icons.logout : Icons.login,
                  color: Colors.white,
                ),
                text: isCheckedIn ? 'Slide to Check Out' : 'Slide to Check In',
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                onSubmit: _handleSlideComplete,
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attendance Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Worked: ${_formatTotalWorkedHours(totalWorkedHours)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Last 5 Attendance Records",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      lastFiveRecords.isEmpty
                          ? const Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lastFiveRecords.length,
                        separatorBuilder: (context, index) =>
                        const Divider(),
                        itemBuilder: (context, index) {
                          final record = lastFiveRecords[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Date: ${record['date']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text("Check In: ${record['checkIn']}"),
                                Text("Check Out: ${record['checkOut']}"),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.indigo[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}