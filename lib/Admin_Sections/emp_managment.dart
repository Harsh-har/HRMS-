// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EmployeeForm extends StatefulWidget {
  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedDepartment = 'Development';
  String _selectedDesignation = 'Developer';
  String _selectedEmploymentType = 'Full-time';
  DateTime _joiningDate = DateTime.now();

  File? _profileImage;
  final picker = ImagePicker();

  final List<String> _departments = [
    'Development', 'Marketing', 'HR', 'Finance', 'Operations', 'Design'
  ];

  final Map<String, List<String>> _designations = {
    'Development': ['Developer', 'Senior Developer', 'Team Lead'],
    'Marketing': ['Executive', 'Manager'],
    'HR': ['HR Executive', 'HR Manager'],
    'Finance': ['Accountant', 'Finance Manager'],
    'Operations': ['Operations Executive', 'Manager'],
    'Design': ['Designer', 'Creative Head'],
  };

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('employee_profiles').child('$fileName.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        String? profileImageUrl;
        if (_profileImage != null) {
          profileImageUrl = await _uploadImage(_profileImage!);
        }

        Map<String, dynamic> employeeData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'department': _selectedDepartment,
          'designation': _selectedDesignation,
          'joiningDate': _joiningDate,
          'employmentType': _selectedEmploymentType,
          'gender': _selectedGender,
          'salary': double.tryParse(_salaryController.text) ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'Active',
          'profileImage': profileImageUrl ?? '',
        };

        await FirebaseFirestore.instance.collection('employees').add(employeeData);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee added successfully!'), backgroundColor: Colors.green),
        );

        _formKey.currentState!.reset();
        setState(() {
          _joiningDate = DateTime.now();
          _profileImage = null;
        });
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Employee')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.add_a_photo, size: 40) : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(_emailController, 'Email', Icons.email),
              _buildTextField(_phoneController, 'Phone', Icons.phone),
              _buildTextField(_addressController, 'Address', Icons.home),
              _buildDropdown(_selectedGender, 'Gender', Icons.person_outline, ['Male', 'Female', 'Other'],
                      (value) => setState(() => _selectedGender = value)),
              _buildDropdown(_selectedDepartment, 'Department', Icons.business, _departments,
                      (value) => setState(() {
                    _selectedDepartment = value;
                    _selectedDesignation = _designations[value]!.first;
                  })),
              _buildDropdown(_selectedDesignation, 'Designation', Icons.work,
                  _designations[_selectedDepartment]!,
                      (value) => setState(() => _selectedDesignation = value)),
              _buildDropdown(_selectedEmploymentType, 'Employment Type', Icons.access_time,
                  ['Full-time', 'Part-time', 'Internship', 'Contract'],
                      (value) => setState(() => _selectedEmploymentType = value)),
              _buildDatePicker(),
              _buildTextField(_salaryController, 'Monthly Salary', Icons.money, keyboardType: TextInputType.number),
              _buildTextField(_passwordController, 'Temporary Password', Icons.lock, isPassword: true),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown(String currentValue, String label, IconData icon, List<String> items, ValueChanged<String> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _joiningDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null && picked != _joiningDate) {
            setState(() => _joiningDate = picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Joining Date',
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_joiningDate.toLocal()}".split(' ')[0], style: TextStyle(fontSize: 16)),
              Icon(Icons.edit_calendar),
            ],
          ),
        ),
      ),
    );
  }
}