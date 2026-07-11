import 'package:flutter/material.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/login_form.dart' show BrandWordmark, rf;
import 'package:url_launcher/url_launcher.dart';

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);
const Color _kBorder = Color(0xFFE9ECEF);
const Color _kDanger = Color(0xFFDC2626);

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _authService.getToken().then((data) {
      if (mounted) setState(() => _user = data);
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.loginRoute);
  }

  Future<void> _openCertificates() async {
    final url = Uri.parse("https://nss.gymkhana.iitb.ac.in/certificates/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  List<Widget> _navItems(BuildContext context, {required bool isAA}) {
    void go(String route) {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    }

    final items = <Widget>[
      _DrawerItem(
        icon: Icons.person_outline,
        label: 'Profile',
        onTap: () => go(Routes.profileRoute),
      ),
      if (isAA) ...[
        _DrawerItem(
          icon: Icons.add_circle_outline,
          label: 'Add Event',
          onTap: () => go(Routes.addEvent),
        ),
        _DrawerItem(
          icon: Icons.event_note_outlined,
          label: 'All Events',
          onTap: () => go(Routes.allEvents),
        ),
        _DrawerItem(
          icon: Icons.group_outlined,
          label: 'Volunteer List',
          onTap: () => go(Routes.volListRoute),
        ),
        _DrawerItem(
          icon: Icons.assignment_outlined,
          label: 'Attendance Records',
          onTap: () => go(Routes.fetchAtt),
        ),
        _DrawerItem(
          icon: Icons.calendar_month_outlined,
          label: 'Event Calendar',
          onTap: () => go(Routes.calendarRoute),
        ),
      ] else ...[
        _DrawerItem(
          icon: Icons.trending_up,
          label: 'Dashboard',
          onTap: () => go(Routes.dashboardpage),
        ),
        _DrawerItem(
          icon: Icons.fact_check_outlined,
          label: 'Attendance',
          onTap: () => go(Routes.attRoute),
        ),
        _DrawerItem(
          icon: Icons.calendar_month_outlined,
          label: 'Event Calendar',
          onTap: () => go(Routes.calendarRoute),
        ),
        _DrawerItem(
          icon: Icons.verified_outlined,
          label: 'Certificates',
          onTap: () {
            Navigator.pop(context);
            _openCertificates();
          },
        ),
      ],
      _DrawerItem(
        icon: Icons.notifications_none,
        label: 'Notifications',
        onTap: () => go(Routes.notificationRoute),
      ),
      _DrawerItem(
        icon: Icons.chat_bubble_outline,
        label: 'Feedback',
        onTap: () => go(Routes.feedbackRoute),
      ),
    ];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?['name']?.toString() ?? 'User';
    final roll = _user?['roll']?.toString() ?? '';
    final role = (_user?['isaa'] == true) ? 'AA' : 'Volunteer';

    return Drawer(
      backgroundColor: _kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identity block
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandWordmark(logoSize: 28, fontSize: 15),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: rf(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _kInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roll.isEmpty ? role : '$roll  ·  $role',
                    style: rf(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: _kMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: _kBorder),
            // Nav list — role-aware.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                children: _navItems(context, isAA: _user?['isaa'] == true),
              ),
            ),
            Container(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: _DrawerItem(
                icon: Icons.logout,
                label: 'Logout',
                danger: true,
                onTap: _handleLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.danger ? _kDanger : _kBrand;
    final labelColor = widget.danger ? _kDanger : _kInk;
    final chipColor =
        widget.danger ? const Color(0xFFFEE2E2) : _kChipBg;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: rf(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: labelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
