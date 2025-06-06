import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hrms_project/Admin_Sections/admin_dashboard.dart';

import '../Employee_Sections/EmployeeDashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Admin login check
    if (email == 'pradeep@gmail.com' && password == '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin login successful!"), backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
      });
      return;
    }

    // Employee login check from Firestore
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found with this email."), backgroundColor: Colors.red),
        );
        return;
      }

      final userData = snapshot.docs.first.data();
      final storedPassword = userData['password'];

      if (storedPassword == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee login successful!"), backgroundColor: Colors.green),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => EmployeeDashboard(employeeData: userData),
          ));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid password."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimation.value,
                  child: child,
                ),
                child: Image.asset(
                  "assets/profile/splashdrawer.png",
                  height: 140,
                  width: 140,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text('WorkSync HR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 100),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) => setState(() => rememberMe = value ?? false),
                  ),
                  const Text('Remember Me'),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CD4B0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Forgot password logic
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
