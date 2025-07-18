import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomForgotPasswordPage extends StatefulWidget {
  @override
  _CustomForgotPasswordPageState createState() => _CustomForgotPasswordPageState();
}

class _CustomForgotPasswordPageState extends State<CustomForgotPasswordPage> {
  final TextEditingController identifierController = TextEditingController(); // email or empID
  bool isLoading = false;

  Future<void> _resetPassword() async {
    final identifier = identifierController.text.trim();

    if (identifier.isEmpty) {
      _showMessage('Please enter your Email or Employee ID.');
      return;
    }

    setState(() => isLoading = true);

    try {
      String? emailToReset;

      // Check if input looks like an email
      if (identifier.contains('@')) {
        emailToReset = identifier;
      } else {
        // Lookup by employee ID in Firestore
        final empSnapshot = await FirebaseFirestore.instance
            .collection('employees')
            .where('employeeId', isEqualTo: identifier)
            .get();

        if (empSnapshot.docs.isNotEmpty) {
          emailToReset = empSnapshot.docs.first.data()['email'];
        }
      }

      if (emailToReset == null || emailToReset.isEmpty) {
        _showMessage('No user found with that Email or Employee ID.');
        setState(() => isLoading = false);
        return;
      }

      // ✅ Send password reset email using Firebase Auth
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailToReset);

      _showMessage(
        'A password reset link has been sent to $emailToReset.\nPlease check your inbox.',
        onOk: () => Navigator.pop(context),
      );
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot your password?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Email or Employee ID. A password reset link will be sent to your registered email.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 40),

            // Identifier Field
            TextField(
              controller: identifierController,
              decoration: InputDecoration(
                labelText: 'Email or Employee ID',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            // Reset Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _resetPassword,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.send),
                label: Text(
                  isLoading ? 'Please wait...' : 'Send Reset Link',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD4B0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
