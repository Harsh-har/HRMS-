import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddPerformanceReviewScreen extends StatefulWidget {
  const AddPerformanceReviewScreen({Key? key}) : super(key: key);

  @override
  State<AddPerformanceReviewScreen> createState() => _AddPerformanceReviewScreenState();
}

class _AddPerformanceReviewScreenState extends State<AddPerformanceReviewScreen> {
  double _rating = 3.0;
  final _goalsController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _improvementController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployee;
  List<String> _employeeNames = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('employees').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _employeeNames = [];
          _selectedEmployee = null;
          _isLoading = false;
          _errorMessage = 'No employees found.';
        });
        return;
      }

      final names = snapshot.docs.map((doc) => doc['name'] as String? ?? doc.id).toList();

      setState(() {
        _employeeNames = names;
        _selectedEmployee = names.first;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching employees: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load employees.';
      });
    }
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate() && _selectedEmployee != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final reviewer = user?.displayName ?? user?.uid ?? 'Anonymous';
        final reviewData = {
          'rating': _rating,
          'goals': _goalsController.text,
          'feedback': _feedbackController.text,
          'improvement': _improvementController.text,
          'reviewer': reviewer,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('performance_reviews')
            .doc(_selectedEmployee)
            .collection('reviews')
            .add(reviewData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Performance review submitted successfully')),
        );

        _formKey.currentState!.reset();
        _goalsController.clear();
        _feedbackController.clear();
        _improvementController.clear();
        setState(() => _rating = 3.0);
      } catch (e) {
        print('Error submitting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _goalsController.dispose();
    _feedbackController.dispose();
    _improvementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Performance Review'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Select Employee", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedEmployee,
                items: _employeeNames.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmployee = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please select an employee' : null,
              ),
              const SizedBox(height: 20),
              Text("Overall Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 32,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _goalsController,
                decoration: InputDecoration(
                  labelText: "Goals Achieved",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter goals achieved' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _improvementController,
                decoration: InputDecoration(
                  labelText: "Areas of Improvement",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter areas of improvement' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: "Manager's Feedback",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Please provide feedback' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeePerformanceReviewScreen extends StatelessWidget {
  final String employeeName;
  const EmployeePerformanceReviewScreen({Key? key, required this.employeeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Performance Reviews'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('performance_reviews')
            .doc(employeeName)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No performance reviews found'));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              final timestamp = (review['timestamp'] as Timestamp?)?.toDate();
              final date = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
                  : 'Unknown';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('Review by ${review['reviewer'] ?? 'Anonymous'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 8),
                      Text('Goals: ${review['goals'] ?? '-'}'),
                      Text('Feedback: ${review['feedback'] ?? '-'}'),
                      Text('Improvement: ${review['improvement'] ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('Date: $date', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
