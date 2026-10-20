import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/authenticator.dart';
import '../widgets/login_form.dart' show rf;
import '../global/IPv4_address.dart';

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kCardBg = Colors.white;
const Color _kBorder = Color(0xFFE2E8F0);
const Color _kDanger = Color(0xFFDC2626);
const Map<String, String> _kDepartmentOptions = {
  'CE': 'Campus Engagement',
  'EO': 'Educational Outreach',
  'SD': 'Social Development',
  'EnS': 'Environment and Sustainability',
};

class VolunteerDetailEditPage extends StatefulWidget {
  final Map<String, dynamic> volunteer;

  const VolunteerDetailEditPage({super.key, required this.volunteer});

  @override
  State<VolunteerDetailEditPage> createState() => _VolunteerDetailEditPageState();
}

class _VolunteerDetailEditPageState extends State<VolunteerDetailEditPage> {
  final AuthService _authService = AuthService();
  
  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedDept;

  bool _isCTM = false;
  bool _isAA = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.volunteer['name'] ?? '');
    _rollController = TextEditingController(text: widget.volunteer['roll'] ?? '');
    _emailController = TextEditingController(text: widget.volunteer['email'] ?? '');
    _phoneController = TextEditingController(text: widget.volunteer['mobile'] ?? '');
    final rawDept = widget.volunteer['dept']?.toString() ?? '';
    _selectedDept = _kDepartmentOptions.containsKey(rawDept)
        ? rawDept
        : _kDepartmentOptions.keys.first;
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final userData = await _authService.getToken();
    if (userData != null && mounted) {
      setState(() {
        _isCTM = userData['isctm'] == true || userData['isctm'] == 1;
        _isAA = userData['isaa'] == true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _loading = true);
    final jwt = await _authService.getJwt();

    final body = {
      'roll': _rollController.text.trim(),
      'name': _nameController.text.trim(),
      'mobile': _phoneController.text.trim(),
      'dept': _selectedDept,
      'email': _emailController.text.trim(),
    };

    try {
      final res = await http.put(
        Uri.parse('$baseURL/api/volunteers/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully!')),
        );
        Navigator.pop(context, true); // return true to refresh parent list
      } else {
        final err = jsonDecode(res.body)['error'] ?? 'Failed to update';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Volunteer'),
        content: Text('Are you sure you want to delete ${_nameController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kDanger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    final jwt = await _authService.getJwt();
    final roll = _rollController.text.trim();

    try {
      final res = await http.delete(
        Uri.parse('$baseURL/api/volunteers/delete/$roll'),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Volunteer deleted successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        final err = jsonDecode(res.body)['error'] ?? 'Failed to delete';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialLetter = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _kInk, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Volunteer Profile',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kBrand))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                // Avatar Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: _kBrand,
                        child: Text(
                          initialLetter,
                          style: rf(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nameController.text,
                        style: rf(fontSize: 20, fontWeight: FontWeight.w600, color: _kInk),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Volunteer',
                          style: rf(fontSize: 12, fontWeight: FontWeight.w500, color: _kMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'ACCOUNT INFORMATION',
                    style: rf(fontSize: 12, fontWeight: FontWeight.w500, color: _kMuted, letterSpacing: 1.2),
                  ),
                ),
                // Editable Cards
                _EditableInfoTile(
                  icon: Icons.person_outline,
                  label: 'Name',
                  controller: _nameController,
                  enabled: _isCTM, // Only CTM can edit
                ),
                const SizedBox(height: 12),
                _EditableInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Roll Number',
                  controller: _rollController,
                  enabled: false, // Roll is primary key, best to keep read-only
                ),
                const SizedBox(height: 12),
                // Department Dropdown Tile
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_isCTM || _isAA) ? _kCardBg : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: (_isCTM || _isAA) ? _kBrand : _kMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Department',
                              style: rf(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _kMuted,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDept,
                                isExpanded: true,
                                icon: (_isCTM || _isAA)
                                    ? const Icon(Icons.arrow_drop_down, color: _kBrand)
                                    : const SizedBox.shrink(),
                                items: _kDepartmentOptions.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key, // Backend store ayye short code ('EnS', 'SD', etc.)
                                    child: Text(
                                      entry.value, // Screen meeda kanipinche full name
                                      style: rf(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (_isCTM || _isAA) ? _kInk : _kMuted,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (_isCTM || _isAA)
                                    ? (val) {
                                        if (val != null) {
                                          setState(() => _selectedDept = val);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isCTM && !_isAA)
                        const Icon(Icons.lock_outline, size: 16, color: _kMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _EditableInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  controller: _emailController,
                  enabled: _isCTM, // Only CTM can edit
                ),
                const SizedBox(height: 12),
                _EditableInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  controller: _phoneController,
                  enabled: _isCTM, // Only CTM can edit
                ),
                const SizedBox(height: 32),
                // Actions
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrand,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Save Details', style: rf(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                if (_isCTM) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _handleDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kDanger,
                      side: const BorderSide(color: _kDanger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Delete Volunteer', style: rf(fontSize: 16, color: _kDanger, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
    );
  }
}

class _EditableInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const _EditableInfoTile({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? _kCardBg : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: enabled ? _kBrand : _kMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: rf(fontSize: 11, fontWeight: FontWeight.w500, color: _kMuted),
                ),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  style: rf(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled ? _kInk : _kMuted,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (!enabled)
            const Icon(Icons.lock_outline, size: 16, color: _kMuted),
        ],
      ),
    );
  }
}
