import 'package:flutter/material.dart';

import 'admin_profile.dart';

// Dummy Profile Edit Screen
class Profile_Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Center(child: Text('Profile Edit Screen')),
    );
  }
}

class AdminSetting extends StatefulWidget {
  @override
  _HRMSettingsScreenState createState() => _HRMSettingsScreenState();
}

class _HRMSettingsScreenState extends State<AdminSetting> {
  bool _notificationsEnabled = true;
  bool _biometricLogin = false;
  bool _darkMode = false;
  bool _syncOverWifiOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings saved successfully')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Account Settings', Icons.account_circle),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => _navigateToProfileEdit(context),
            ),
            _buildSettingsItem(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () => _showChangePasswordDialog(context),
            ),
          ]),

          _buildSectionHeader('Help & Support', Icons.help),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.question_answer,
              title: 'FAQs',
              onTap: () => _openFAQs(context),
            ),
            _buildSettingsItem(
              icon: Icons.bug_report,
              title: 'Report a Problem',
              onTap: () => _reportProblem(context),
            ),
          ]),

          _buildSectionHeader('Legal', Icons.gavel),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () => _openPrivacyPolicy(context),
            ),
            _buildSettingsItem(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () => _openTerms(context),
            ),
          ]),

          _buildSectionHeader('About', Icons.info),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.apps,
              title: 'App Version',
              trailing: Text('1.0.0'),
            ),
            _buildSettingsItem(
              icon: Icons.update,
              title: 'Last Updated',
              trailing: Text('May 2025'),
            ),
          ]),

          SizedBox(height: 20),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.logout),
      label: Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFCFD8DC),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () => _confirmLogout(context),
    );
  }

  // Function to navigate to the Profile Edit Screen
  void _navigateToProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminProfile()),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Current Password')),
            TextField(decoration: InputDecoration(labelText: 'New Password')),
            TextField(decoration: InputDecoration(labelText: 'Confirm Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Save')),
        ],
      ),
    );
  }

  void _openFAQs(BuildContext context) {
    // Open FAQs logic
  }

  void _reportProblem(BuildContext context) {
    // Report problem logic
  }

  void _openPrivacyPolicy(BuildContext context) {
    // Open privacy policy logic
  }

  void _openTerms(BuildContext context) {
    // Open terms logic
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout logic
            },
            child: Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
