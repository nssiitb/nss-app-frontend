import 'package:flutter/material.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

const Map<String, String> _kDeptNames = {
  'CE': 'Campus Engagement',
  'EO': 'Educational Outreach',
  'SD': 'Social Development',
  'EnS': 'Environment and Sustainability',
};

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _authService.getToken();
    if (!mounted) return;
    setState(() {
      _user = data;
      _loading = false;
    });
    if (data == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't load your profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?['name']?.toString() ?? '';
    final roll = _user?['roll']?.toString() ?? '';
    final email = _user?['email']?.toString() ?? '';
    final phone = _user?['mobile']?.toString() ?? '';
    final deptCode = _user?['dept']?.toString() ?? '';
    final deptLabel = _kDeptNames[deptCode] ?? deptCode;
    final isAA = _user?['isaa'] == true;

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
          'Profile',
          style: rf(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _kInk,
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _kBrand, strokeWidth: 2.4))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                _Header(name: name, isAA: isAA),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'ACCOUNT INFORMATION',
                    style: rf(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: name.isEmpty ? '—' : name,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Roll Number',
                  value: roll.isEmpty ? '—' : roll,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.school_outlined,
                  label: 'Department',
                  value: deptLabel.isEmpty ? '—' : deptLabel,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: email.isEmpty ? '—' : email,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: phone.isEmpty ? '—' : phone,
                ),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final bool isAA;
  const _Header({required this.name, required this.isAA});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: _kBrand,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kBrand.withOpacity(0.25),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: rf(
              fontSize: 38,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          name.isEmpty ? 'User' : name,
          style: rf(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: _kInk,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _kChipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isAA ? 'AA' : 'Volunteer',
            style: rf(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kBrand,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A3B5A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: _kBrand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: rf(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _kMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: rf(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _kInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
