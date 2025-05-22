import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddPerformanceReviewScreen extends StatefulWidget {
  final String employeeName;

  const AddPerformanceReviewScreen({Key? key, required this.employeeName}) : super(key: key);

  @override
  State<AddPerformanceReviewScreen> createState() => _AddPerformanceReviewScreenState();
}

class _AddPerformanceReviewScreenState extends State<AddPerformanceReviewScreen> {
  double _rating = 3.0;
  final _goalsController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _improvementController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      // Here you can call your backend or Firebase to save the data

      print('Review submitted:');
      print('Rating: $_rating');
      print('Goals: ${_goalsController.text}');
      print('Feedback: ${_feedbackController.text}');
      print('Improvements: ${_improvementController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Performance review submitted successfully')),
      );

      // Clear form after submit
      _formKey.currentState!.reset();
      _goalsController.clear();
      _feedbackController.clear();
      _improvementController.clear();
      setState(() => _rating = 3.0);
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
        title: Text('Add Review for ${widget.employeeName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Overall Rating",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter goals achieved' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _improvementController,
                decoration: InputDecoration(
                  labelText: "Areas of Improvement",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter areas of improvement' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: "Manager's Feedback",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please provide feedback' : null,
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
