import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:slide_to_act/slide_to_act.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late String _timeString;
  late String _dateString;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool isCheckedIn = false; // Track check-in or check-out state

  final GlobalKey<SlideActionState> _slideKey = GlobalKey();

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
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString = DateFormat('hh:mm:ss a').format(now);
      _dateString = DateFormat('dd MMM yyyy').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSlideComplete() async {
    await _animationController.forward();
    await _animationController.reverse();

    setState(() {
      isCheckedIn = !isCheckedIn;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCheckedIn ? "Checked In Successfully!" : "Checked Out Successfully!"),
        backgroundColor: isCheckedIn ? Colors.green : Colors.red,
      ),
    );

    // Reset the slider so user can slide again
    _slideKey.currentState?.reset();
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
                    children: const [
                      Text("Today’s Summary",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.login, color: Colors.green),
                              SizedBox(height: 4),
                              Text("Check-In\n09:20 AM",
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.logout, color: Colors.redAccent),
                              SizedBox(height: 4),
                              Text("Check-Out\n--",
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.access_time_filled,
                                  color: Colors.orange),
                              SizedBox(height: 4),
                              Text("Worked\n--",
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
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.grey[100],
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    title: const Text("10 May 2025",
                        style: TextStyle(color: Colors.black)),
                    subtitle: const Text("Check-In: 09:15 AM | Check-Out: 06:10 PM",
                        style: TextStyle(color: Colors.black54)),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
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
