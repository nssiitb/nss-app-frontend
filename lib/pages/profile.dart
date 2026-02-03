import 'package:flutter/material.dart';
import 'package:nssapp/utils/authenticator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  // Controllers to hold and display the data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetches user data from the local token and populates the fields.
  Future<void> _fetchUserData() async {
    Map<String, dynamic>? token = await _authService.getToken();
    if (token != null && mounted) {
      setState(() {
        _nameController.text = token['name'] ?? "N/A";
        _rollNumberController.text = token['roll'] ?? "N/A";
        _phoneController.text = token['mobile'] ?? "N/A";
        _emailController.text = token['email'] ?? "N/A";
        _departmentController.text = token['dept'] ?? "N/A";
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not load user data.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // A softer background color
      appBar: AppBar(
        title: const Text("My Profile"),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A3B5A),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A3B5A)),
          onPressed: () => Navigator.pop(context),
        ),
        // No actions (edit button) needed in view-only mode
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          // Profile Header with Avatar
          _buildProfileHeader(),
          const SizedBox(height: 30),
          
          const Text(
            "ACCOUNT INFORMATION",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),

          // Display-only information fields
          _buildProfileInfoTile(
            label: "Name",
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          _buildProfileInfoTile(
            label: "Roll Number",
            controller: _rollNumberController,
            icon: Icons.badge_outlined,
          ),
          _buildProfileInfoTile(
            label: "Department",
            controller: _departmentController,
            icon: Icons.school_outlined,
          ),
          _buildProfileInfoTile(
            label: "Email Address",
            controller: _emailController,
            icon: Icons.email_outlined,
          ),
          _buildProfileInfoTile(
            label: "Phone",
            controller: _phoneController,
            icon: Icons.phone_outlined,
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Builds the header section with a profile avatar and name.
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF0D47A1),
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3B5A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            _emailController.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds a styled, read-only text field for profile information.
  Widget _buildProfileInfoTile({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          controller: controller,
          readOnly: true, // This field is always read-only
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A3B5A),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.blueGrey),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.normal),
            border: InputBorder.none, // No border or underline
          ),
        ),
      ),
    );
  }
}