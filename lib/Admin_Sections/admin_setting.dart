import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_profile.dart';

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
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved successfully')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
              trailing: const Text('1.0.0'),
            ),
            _buildSettingsItem(
              icon: Icons.update,
              title: 'Last Updated',
              trailing: const Text('May 2025'),
            ),
          ]),

          const SizedBox(height: 20),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
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
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCFD8DC),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () => _confirmLogout(context),
    );
  }

  void _navigateToProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminProfile()),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPassword = currentPassController.text.trim();
              final newPassword = newPassController.text.trim();
              final confirmPassword = confirmPassController.text.trim();

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New password and confirmation do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                final cred = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: currentPassword,
                );

                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPassword);

                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? 'Failed to change password'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openFAQs(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FAQs clicked')),
    );
  }

  void _reportProblem(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report Problem clicked')),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy clicked')),
    );
  }

  void _openTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service clicked')),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pop(context); // Optional: navigate to login screen
            },
            child: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
