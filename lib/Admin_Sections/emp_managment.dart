import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EmployeeForm extends StatefulWidget {
  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _email = '', _phone = '', _department = '', _jobTitle = '', _password = '', _retypePassword = '';
  bool _obscurePassword = true, _obscureRetypePassword = true;
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveEmployeeData() {
    if (!_formKey.currentState!.validate()) return;

    if (_password != _retypePassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    _formKey.currentState!.save();

    // Log the employee data for now (since Firebase is removed)
    print("✅ Employee Saved:");
    print("Name: $_name");
    print("Email: $_email");
    print("Phone: $_phone");
    print("Department: $_department");
    print("Job Title: $_jobTitle");

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Employee data saved locally!")));

    _formKey.currentState!.reset();
    setState(() {
      _image = null;
      _name = _email = _phone = _department = _jobTitle = _password = _retypePassword = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employee', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFCFD8DC),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.camera_alt, size: 30, color: Colors.white) : null,
                ),
              ),
              SizedBox(height: 20),
              buildTextField('Employee Name', Icons.person, (value) => _name = value ?? ''),
              buildTextField('Employee Email', Icons.email, (value) => _email = value ?? ''),
              buildTextField('Phone No', Icons.phone, (value) => _phone = value ?? ''),
              buildDropdown('Department', ['HR', 'Engineering', 'Sales', 'Marketing'], (newValue) => _department = newValue ?? ''),
              buildDropdown('Job Title', ['Manager', 'Developer', 'Designer', 'Analyst'], (newValue) => _jobTitle = newValue ?? ''),
              buildPasswordField('Password', Icons.lock, (value) => _password = value ?? '',
                  obscureText: _obscurePassword, toggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
              buildPasswordField('Retype Password', Icons.lock, (value) => _retypePassword = value ?? '',
                  obscureText: _obscureRetypePassword, toggleVisibility: () {
                    setState(() => _obscureRetypePassword = !_obscureRetypePassword);
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEmployeeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, Function(String?) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder()),
        validator: (value) => (value == null || value.isEmpty) ? 'Please enter $label' : null,
        onSaved: onSave,
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.arrow_drop_down), border: OutlineInputBorder()),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget buildPasswordField(String label, IconData icon, Function(String?) onSave,
      {required bool obscureText, required VoidCallback toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
        onSaved: onSave,
      ),
    );
  }
}
