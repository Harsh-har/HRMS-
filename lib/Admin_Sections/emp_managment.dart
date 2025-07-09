// Add this line at the top of your file
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EmployeeForm extends StatefulWidget {
  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _salaryController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  // Dropdown + Date
  String _selectedGender = 'male';
  String _selectedDepartment = 'employee';
  String _selectedRole = 'developer';
  String _selectedEmploymentType = 'Full-time';
  DateTime _joiningDate = DateTime.now();
  DateTime _dateOfBirth = DateTime(1990, 1, 1);

  File? _profileImage;
  final picker = ImagePicker();
  final _dateFormatter = DateFormat('dd-MM-yyyy');
  bool _isLoading = false;

  // Department → Role mapping
  final List<String> _departments = ['employee', 'manager', 'hr', 'admin'];
  final Map<String, List<String>> _roles = {
    'admin': ['superadmin'],
    'hr': ['hr'],
    'manager': ['teammanager', 'projectmanager'],
    'employee': ['developer', 'designer', 'tester', 'support']
  };

  @override
  void initState() {
    super.initState();
    _selectedRole = _roles[_selectedDepartment]?.first ?? 'employee';
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('employee_profiles/$fileName.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_employeeIdController.text.trim().isEmpty) {
      _showError("Employee ID is required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      final employeeData = {
        'employeeId': _employeeIdController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'department': _selectedDepartment.toLowerCase(),
        'role': _selectedRole.toLowerCase(),
        'joiningDate': Timestamp.fromDate(_joiningDate),
        'employmentType': _selectedEmploymentType,
        'gender': _selectedGender.toLowerCase(),
        'salary': double.tryParse(_salaryController.text.trim()) ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'profileImage': profileImageUrl ?? '',
        'password': _passwordController.text.trim(),
        'dateOfBirth': Timestamp.fromDate(_dateOfBirth),
        'emergencyContactName': _emergencyContactNameController.text.trim(),
        'emergencyContactRelation': _emergencyContactRelationController.text.trim(),
        'emergencyContactPhone': _emergencyContactPhoneController.text.trim(),
      };

      final empId = _employeeIdController.text.trim();

      await FirebaseFirestore.instance.collection('employees').doc(empId).set(employeeData);
      await _addToRoleBasedCollection(employeeData, empId);

      _resetForm();
      _showSuccess('Employee added successfully!');
    } catch (e, stack) {
      print("Error: $e");
      print(stack);
      _showError("Failed to add employee. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addToRoleBasedCollection(Map<String, dynamic> employeeData, String empId) async {
    String role = employeeData['role'];
    String collectionName;
    if (role == 'superadmin') {
      collectionName = 'admins';
    } else if (role == 'hr') {
      collectionName = 'hrs';
    } else if (role == 'teammanager' || role == 'projectmanager') {
      collectionName = 'managers';
    } else {
      collectionName = 'employees';
    }

    await FirebaseFirestore.instance.collection(collectionName).doc(empId).set(employeeData);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _employeeIdController.clear();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _passwordController.clear();
      _salaryController.clear();
      _emergencyContactNameController.clear();
      _emergencyContactRelationController.clear();
      _emergencyContactPhoneController.clear();
      _profileImage = null;
      _joiningDate = DateTime.now();
      _dateOfBirth = DateTime(1990, 1, 1);
      _selectedGender = 'male';
      _selectedDepartment = 'employee';
      _selectedRole = 'developer';
      _selectedEmploymentType = 'Full-time';
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter Email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter valid Email';
    return null;
  }
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter Phone';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Enter 10-digit number';
    return null;
  }



  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter Password';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  String? _validateSalary(String? value) {
    if (value == null || value.isEmpty) return 'Enter Salary';
    if (double.tryParse(value) == null) return 'Enter valid number';
    return null;
  }

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
        onChanged: (val) {
          if (val != null) {
            onChanged(val);
            if (label == 'Department') {
              setState(() => _selectedRole = _roles[val]!.first);
            }
          }
        },
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate, ValueChanged<DateTime> onDateSelected) {
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
          if (picked != null) onDateSelected(picked);
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
              Text(_dateFormatter.format(selectedDate)),
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
      appBar: AppBar(title: const Text('Add New Employee'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
              _buildTextField(_employeeIdController, 'Employee ID', Icons.badge),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress, validator: _validateEmail),
              _buildTextField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone, validator: _validatePhone),
              _buildTextField(_addressController, 'Address', Icons.home),

              _buildDropdown(_selectedGender, 'Gender', Icons.person, ['male', 'female', 'other'], (val) => setState(() => _selectedGender = val)),
              _buildDropdown(_selectedDepartment, 'Department', Icons.business, _departments, (val) => setState(() => _selectedDepartment = val)),
              _buildDropdown(_selectedRole, 'Role', Icons.work, _roles[_selectedDepartment]!, (val) => setState(() => _selectedRole = val)),
              _buildDropdown(_selectedEmploymentType, 'Employment Type', Icons.access_time,
                  ['Full-time', 'Part-time', 'Internship', 'Contract'], (val) => setState(() => _selectedEmploymentType = val)),

              _buildDatePicker('Joining Date', _joiningDate, (val) => setState(() => _joiningDate = val)),
              _buildDatePicker('Date of Birth', _dateOfBirth, (val) => setState(() => _dateOfBirth = val)),

              _buildTextField(_salaryController, 'Salary', Icons.money, keyboardType: TextInputType.number, validator: _validateSalary),
              _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true, validator: _validatePassword),

              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text("Emergency Contact Details", style: TextStyle(fontWeight: FontWeight.bold))),
              _buildTextField(_emergencyContactNameController, 'Contact Name', Icons.person),
              _buildTextField(_emergencyContactRelationController, 'Relation', Icons.group),
              _buildTextField(_emergencyContactPhoneController, 'Contact Phone', Icons.phone, keyboardType: TextInputType.phone, validator: _validatePhone),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit"),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
