import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // ADDED

class EmployeeForm extends StatefulWidget {
  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactRelationController = TextEditingController();
  final TextEditingController _emergencyContactPhoneController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedDepartment = 'Development';
  String _selectedDesignation = 'Developer';
  String _selectedEmploymentType = 'Full-time';
  DateTime _joiningDate = DateTime.now();
  DateTime _dateOfBirth = DateTime(1990, 1, 1);

  File? _profileImage;
  final picker = ImagePicker();
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy'); // ADDED

  final List<String> _departments = ['Development', 'Marketing', 'HR', 'Finance', 'Operations', 'Design'];

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
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String? profileImageUrl;
        if (_profileImage != null) {
          profileImageUrl = await _uploadImage(_profileImage!);
        }

        final String employeeId = _employeeIdController.text.trim();
        final employeeDocRef = FirebaseFirestore.instance.collection('employees').doc(employeeId);

        Map<String, dynamic> employeeData = {
          'employeeId': employeeId,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'department': _selectedDepartment,
          'designation': _selectedDesignation,
          'joiningDate': Timestamp.fromDate(_joiningDate), // UPDATED
          'employmentType': _selectedEmploymentType,
          'gender': _selectedGender,
          'salary': double.tryParse(_salaryController.text) ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'Active',
          'profileImage': profileImageUrl ?? '',
          'password': _passwordController.text.trim(),
          'dateOfBirth': Timestamp.fromDate(_dateOfBirth), // UPDATED
          'emergencyContactName': _emergencyContactNameController.text.trim(),
          'emergencyContactRelation': _emergencyContactRelationController.text.trim(),
          'emergencyContactPhone': _emergencyContactPhoneController.text.trim(),
        };

        await employeeDocRef.set(employeeData);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully!'), backgroundColor: Colors.green),
        );

        _formKey.currentState!.reset();
        setState(() {
          _employeeIdController.clear();
          _joiningDate = DateTime.now();
          _dateOfBirth = DateTime(1990, 1, 1);
          _profileImage = null;
          _selectedGender = 'Male';
          _selectedDepartment = 'Development';
          _selectedDesignation = 'Developer';
          _selectedEmploymentType = 'Full-time';
        });
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ===== VALIDATORS =====
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter Email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter valid Email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter Phone number';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Enter valid 10-digit phone number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter Password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateSalary(String? value) {
    if (value == null || value.isEmpty) return 'Enter Salary';
    if (double.tryParse(value) == null) return 'Enter valid number';
    return null;
  }

  String? _validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Enter $fieldName';
    return null;
  }

  String? _validateEmployeeId(String? value) {
    if (value == null || value.isEmpty) return 'Enter Employee ID';
    return null;
  }

  // ===== WIDGET BUILDERS =====
  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown(String currentValue, String label, IconData icon, List<String> items, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildDatePicker({required String label, required DateTime selectedDate, required ValueChanged<DateTime> onDateSelected}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null && picked != selectedDate) {
            onDateSelected(picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_dateFormatter.format(selectedDate), style: const TextStyle(fontSize: 16)),
              const Icon(Icons.edit_calendar),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    child: _profileImage == null ? const Icon(Icons.add_a_photo, size: 40) : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress, validator: _validateEmail),
              _buildTextField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone, validator: _validatePhone),
              _buildTextField(_employeeIdController, 'Employee ID', Icons.badge, validator: _validateEmployeeId),
              _buildTextField(_addressController, 'Address', Icons.home),
              _buildDropdown(_selectedGender, 'Gender', Icons.person_outline, ['Male', 'Female', 'Other'], (value) => setState(() => _selectedGender = value)),
              _buildDropdown(_selectedDepartment, 'Department', Icons.business, _departments, (value) => setState(() {
                _selectedDepartment = value;
                _selectedDesignation = _designations[value]!.first;
              })),
              _buildDropdown(_selectedDesignation, 'Designation', Icons.work, _designations[_selectedDepartment]!, (value) => setState(() => _selectedDesignation = value)),
              _buildDropdown(_selectedEmploymentType, 'Employment Type', Icons.access_time, ['Full-time', 'Part-time', 'Internship', 'Contract'], (value) => setState(() => _selectedEmploymentType = value)),
              _buildDatePicker(label: 'Joining Date', selectedDate: _joiningDate, onDateSelected: (date) => setState(() => _joiningDate = date)),
              _buildDatePicker(label: 'Date of Birth', selectedDate: _dateOfBirth, onDateSelected: (date) => setState(() => _dateOfBirth = date)),
              _buildTextField(_salaryController, 'Monthly Salary', Icons.money, keyboardType: TextInputType.number, validator: _validateSalary),
              _buildTextField(_passwordController, 'Temporary Password', Icons.lock, isPassword: true, validator: _validatePassword),
              const SizedBox(height: 20),
              const Text("Emergency Contact Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              _buildTextField(_emergencyContactNameController, 'Emergency Contact Name', Icons.person, validator: (val) => _validateNonEmpty(val, 'Emergency Contact Name')),
              _buildTextField(_emergencyContactRelationController, 'Emergency Contact Relation', Icons.people, validator: (val) => _validateNonEmpty(val, 'Emergency Contact Relation')),
              _buildTextField(_emergencyContactPhoneController, 'Emergency Contact Phone', Icons.phone, keyboardType: TextInputType.phone, validator: _validatePhone),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                  child: const Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
