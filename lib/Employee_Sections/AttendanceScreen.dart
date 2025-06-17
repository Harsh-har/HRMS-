import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  const AttendanceScreen({super.key, required this.employeeData});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late String _timeString;
  late String _dateString;
  bool isCheckedIn = false;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  double? workedHoursDecimal;
  double weeklyWorkedHoursDecimal = 0.0;

  final GlobalKey<SlideActionState> _slideKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _updateTime());
    _fetchTodayAttendance();
    _fetchWeeklyWorkedHours();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString = DateFormat('hh:mm:ss a').format(now);
      _dateString = DateFormat('dd MMM yyyy').format(now);
    });
  }

  Future<void> _fetchTodayAttendance() async {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc('${widget.employeeData['name']}_$today')
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
        workedHoursDecimal = data['workedHours'] != null
            ? double.tryParse(data['workedHours'].toString())
            : null;
        isCheckedIn = checkInTime != null && checkOutTime == null;
      });
    }
  }

  Future<void> _fetchWeeklyWorkedHours() async {
    final name = widget.employeeData['name'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    List<String> weekDates = List.generate(
        now.difference(monday).inDays + 1,
            (i) => DateFormat('dd-MM-yyyy').format(monday.add(Duration(days: i))));

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('name', isEqualTo: name)
        .get();

    double total = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['date'] != null &&
          weekDates.contains(data['date']) &&
          data['workedHours'] != null) {
        total += double.tryParse(data['workedHours'].toString()) ?? 0.0;
      }
    }

    setState(() {
      weeklyWorkedHoursDecimal = total;
    });
  }

  Future<void> _handleSlideComplete() async {
    final now = DateTime.now();
    final todayFormatted = DateFormat('dd-MM-yyyy').format(now);
    final docRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc('${widget.employeeData['name']}_$todayFormatted');
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      checkInTime = now;
      await docRef.set({
        'name': widget.employeeData['name'],
        'date': todayFormatted,
        'checkIn': DateFormat('hh:mm a').format(now),
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isCheckedIn = true;
        checkOutTime = null;
        workedHoursDecimal = null;
      });
    } else {
      final data = snapshot.data()!;
      if (data.containsKey('checkIn') && !data.containsKey('checkOut')) {
        checkInTime = DateFormat('hh:mm a').parse(data['checkIn']);
        checkOutTime = now;
        Duration worked = checkOutTime!.difference(checkInTime!);
        double hours = worked.inMinutes / 60;
        String formattedHours = hours.toStringAsFixed(2);

        await docRef.update({
          'checkOut': DateFormat('hh:mm a').format(now),
          'workedHours': formattedHours,
        });

        setState(() {
          isCheckedIn = false;
          workedHoursDecimal = double.tryParse(formattedHours);
        });

        await _fetchWeeklyWorkedHours();
      }
    }

    _slideKey.currentState?.reset();
    _fetchTodayAttendance();
  }

  String displayWorkedHours(double? hours) {
    if (hours == null) return '--';
    int hr = hours.floor();
    int min = ((hours - hr) * 60).round();
    return '$hr hr ${min.toString().padLeft(2, '0')} min';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double weeklyProgress = weeklyWorkedHoursDecimal / 45;
    weeklyProgress = weeklyProgress.clamp(0, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Tracker"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Welcome, ${widget.employeeData['name']}",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("$_dateString | $_timeString",
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 20),
            Card(
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Summary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("Check In"),
                            Text(checkInTime != null
                                ? DateFormat('hh:mm a').format(checkInTime!)
                                : '--'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Check Out"),
                            Text(checkOutTime != null
                                ? DateFormat('hh:mm a').format(checkOutTime!)
                                : '--'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Worked"),
                            Text(displayWorkedHours(workedHoursDecimal)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: weeklyProgress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
                "Weekly Hours: ${displayWorkedHours(weeklyWorkedHoursDecimal)} / 45 hr",
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SlideAction(
              key: _slideKey,
              borderRadius: 30,
              elevation: 4,
              innerColor: isCheckedIn ? Colors.red : Colors.green,
              outerColor:
              isCheckedIn ? Colors.red.shade100 : Colors.green.shade100,
              sliderButtonIcon: Icon(
                isCheckedIn ? Icons.logout : Icons.login,
                color: isCheckedIn ? Colors.red : Colors.green,
              ),
              text: isCheckedIn ? 'Slide to Check-Out' : 'Slide to Check-In',
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              onSubmit: _handleSlideComplete,
            ),
          ],
        ),
      ),
    );
  }
}