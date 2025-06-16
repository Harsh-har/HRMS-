import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  const AttendanceScreen({super.key, required this.employeeData});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late String _timeString;
  late String _dateString;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool isCheckedIn = false;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  Duration? workedDuration;

  final GlobalKey<SlideActionState> _slideKey = GlobalKey();
  List<Map<String, dynamic>> recentAttendance = [];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fetchTodayAttendance();
    _fetchRecentAttendance();
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
        checkInTime = data['checkIn'] != null ? DateFormat('hh:mm a').parse(data['checkIn']) : null;
        checkOutTime = data['checkOut'] != null ? DateFormat('hh:mm a').parse(data['checkOut']) : null;
        workedDuration = data['worked'] != null
            ? Duration(minutes: int.parse(data['worked'].split(' ')[0]) * 60 + int.parse(data['worked'].split(' ')[2]))
            : null;
        isCheckedIn = checkInTime != null && checkOutTime == null;
      });
    }
  }

  /// ✅ UPDATED METHOD TO FETCH LAST 5 DAYS OF ATTENDANCE
  Future<void> _fetchRecentAttendance() async {
    final name = widget.employeeData['name'];
    final today = DateTime.now();

    // Last 5 distinct dates in same format as saved in Firestore
    List<String> last5Dates = List.generate(5, (i) {
      final date = today.subtract(Duration(days: i));
      return DateFormat('dd MMM yyyy').format(date);
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('name', isEqualTo: name)
        .where('date', whereIn: last5Dates)
        .get();

    setState(() {
      recentAttendance = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _handleSlideComplete() async {
    await _animationController.forward();
    await _animationController.reverse();

    final now = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(now);
    final docRef = FirebaseFirestore.instance.collection('attendance').doc('${widget.employeeData['name']}_$today');

    if (!isCheckedIn) {
      checkInTime = now;
      await docRef.set({
        'name': widget.employeeData['name'],
        'date': DateFormat('dd MMM yyyy').format(now), // ✅ Ensure same format
        'checkIn': DateFormat('hh:mm a').format(now),
        'timestamp': FieldValue.serverTimestamp()
      });
    } else {
      checkOutTime = now;
      if (checkInTime != null) {
        workedDuration = checkOutTime!.difference(checkInTime!);
        await docRef.update({
          'checkOut': DateFormat('hh:mm a').format(now),
          'worked': formatDuration(workedDuration)
        });
      }
    }

    setState(() {
      isCheckedIn = !isCheckedIn;
    });

    _fetchRecentAttendance();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCheckedIn ? "Checked In Successfully!" : "Checked Out Successfully!"),
        backgroundColor: isCheckedIn ? Colors.green : Colors.red,
      ),
    );

    _slideKey.currentState?.reset();
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attendance",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$_dateString | $_timeString",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today’s Summary",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.login, color: Colors.green),
                              const SizedBox(height: 4),
                              Text("Check-In\n${checkInTime != null ? DateFormat('hh:mm a').format(checkInTime!) : '--'}",
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.logout, color: Colors.redAccent),
                              const SizedBox(height: 4),
                              Text("Check-Out\n${checkOutTime != null ? DateFormat('hh:mm a').format(checkOutTime!) : '--'}",
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.access_time_filled, color: Colors.orange),
                              const SizedBox(height: 4),
                              Text("Worked\n${formatDuration(workedDuration)}",
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: SlideAction(
                  key: _slideKey,
                  borderRadius: 30,
                  elevation: 4,
                  innerColor: isCheckedIn ? Colors.red : Colors.green,
                  outerColor: isCheckedIn ? Colors.red.shade100 : Colors.green.shade100,
                  sliderButtonIcon: Icon(
                    isCheckedIn ? Icons.logout : Icons.login,
                    color: isCheckedIn ? Colors.red : Colors.green,
                  ),
                  text: isCheckedIn ? 'Slide to Check-Out' : 'Slide to Check-In',
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  onSubmit: _handleSlideComplete,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Recent Attendance",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentAttendance.length,
                itemBuilder: (context, index) {
                  final item = recentAttendance[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.grey[100],
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    title: Text(item['date'], style: const TextStyle(color: Colors.black)),
                    subtitle: Text(
                      "Check-In: ${item['checkIn']} | Check-Out: ${item['checkOut'] ?? '--'}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: Text(
                      item['worked'] ?? '--',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
