import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfile extends StatefulWidget {
  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final String adminId = 'admin_001'; // Firestore document ID for admin

  bool isEditing = false;
  bool isLoading = true;

  // Text Controllers for all fields
  late TextEditingController nameController;
  late TextEditingController roleController;
  late TextEditingController empIdController;
  late TextEditingController jobTitleController;
  late TextEditingController departmentController;
  late TextEditingController joinDateController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('admins').doc(adminId).get();
      final data = doc.data() as Map<String, dynamic>?;

      nameController = TextEditingController(text: data?['name'] ?? 'Pradeep Tamar');
      roleController = TextEditingController(text: data?['role'] ?? 'CEO');
      empIdController = TextEditingController(text: data?['empId'] ?? 'EMP-1006');
      jobTitleController = TextEditingController(text: data?['jobTitle'] ?? 'CEO');
      departmentController = TextEditingController(text: data?['department'] ?? 'Admin');
      joinDateController = TextEditingController(text: data?['joinDate'] ?? '15 Oct 2024');
      emailController = TextEditingController(text: data?['email'] ?? 'pradeep@gmail.com');
      phoneController = TextEditingController(text: data?['phone'] ?? '+91 7895037479');
      locationController = TextEditingController(text: data?['location'] ?? 'Noida Sector 132');
      imageUrl = data?['imageUrl'];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading admin data: $e');
      // Fallback defaults if needed
      nameController = TextEditingController(text: 'Pradeep Tamar');
      roleController = TextEditingController(text: 'CEO');
      empIdController = TextEditingController(text: 'EMP-1006');
      jobTitleController = TextEditingController(text: 'CEO');
      departmentController = TextEditingController(text: 'Admin');
      joinDateController = TextEditingController(text: '15 Oct 2024');
      emailController = TextEditingController(text: 'pradeep@gmail.com');
      phoneController = TextEditingController(text: '+91 7895037479');
      locationController = TextEditingController(text: 'Noida Sector 132');
      imageUrl = null;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('admins').doc(adminId).set({
        'name': nameController.text.trim(),
        'role': roleController.text.trim(),
        'empId': empIdController.text.trim(),
        'jobTitle': jobTitleController.text.trim(),
        'department': departmentController.text.trim(),
        'joinDate': joinDateController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'imageUrl': imageUrl ?? '',
      }, SetOptions(merge: true)); // merge true for partial update

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));

      setState(() {
        isEditing = false;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : AssetImage('assets/profile/adminimage.jpg') as ImageProvider,
        ),
        SizedBox(height: 16),
        isEditing
            ? _buildTextField(nameController, 'Name')
            : Text(nameController.text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        isEditing
            ? _buildTextField(roleController, 'Role')
            : Text(roleController.text, style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildInfoCard({required List<Widget> children}) => Card(
    elevation: 2,
    child: Padding(padding: EdgeInsets.all(16), child: Column(children: children)),
  );

  Widget _buildInfoRow(String label, TextEditingController controller, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 20, color: Colors.blue),
          if (icon != null) SizedBox(width: 16),
          Expanded(
            child: isEditing
                ? _buildTextField(controller, label)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 2),
                Text(controller.text, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                await _saveProfile();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 24),
            _buildSectionTitle('Basic Information'),
            _buildInfoCard(children: [
              _buildInfoRow('Employee ID', empIdController, icon: Icons.person),
              _buildInfoRow('Job Title', jobTitleController, icon: Icons.work),
              _buildInfoRow('Department', departmentController, icon: Icons.group),
              _buildInfoRow('Join Date', joinDateController, icon: Icons.calendar_today),
            ]),
            _buildSectionTitle('Contact Information'),
            _buildInfoCard(children: [
              _buildInfoRow('Work Email', emailController, icon: Icons.email),
              _buildInfoRow('Phone', phoneController, icon: Icons.phone),
              _buildInfoRow('Work Location', locationController, icon: Icons.location_on),
            ]),
          ],
        ),
      ),
    );
  }
}
