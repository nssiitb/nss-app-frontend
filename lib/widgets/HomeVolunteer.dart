import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/login_form.dart' show BrandWordmark, rf;
import 'package:url_launcher/url_launcher.dart';
import 'app_drawer.dart';

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);
const Color _kBorder = Color(0xFFE9ECEF);
const int _kHoursTarget = 40;

class Homevolunteer extends StatefulWidget {
  final String name;
  const Homevolunteer({super.key, required this.name});

  @override
  State<Homevolunteer> createState() => _HomevolunteerState();
}

class _HomevolunteerState extends State<Homevolunteer> {
  int? _completedHours;
  bool _hoursLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHours();
  }

  Future<void> _loadHours() async {
    try {
      final data = await AuthService().getToken();
      final roll = data?['roll']?.toString() ?? '';
      if (roll.isEmpty) {
        if (mounted) setState(() => _hoursLoading = false);
        return;
      }
      final res = await ApiService.getCompletedHours(roll);
      final body = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          if (body['status'] == true && body['hours'] != null) {
            _completedHours = (body['hours'] as num).toInt();
          }
          _hoursLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hoursLoading = false);
    }
  }

  Future<void> _openCertificates() async {
    final url = Uri.parse("https://nss.gymkhana.iitb.ac.in/certificates/");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the portal")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHours,
          color: _kBrand,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(),
                const SizedBox(height: 28),
                Text(
                  'Hi, ${widget.name}',
                  style: rf(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: _kInk,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ready to volunteer today?',
                  style: rf(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: _kMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _HoursCard(
                  completed: _completedHours,
                  target: _kHoursTarget,
                  loading: _hoursLoading,
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.dashboardpage),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.95,
                  children: [
                    _TileCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Attendance',
                      subtitle: 'Track your participation',
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.attRoute),
                    ),
                    _TileCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'Event Calendar',
                      subtitle: 'Upcoming activities',
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.calendarRoute),
                    ),
                    _TileCard(
                      icon: Icons.verified_outlined,
                      title: 'Certificates',
                      subtitle: 'Access your certs',
                      onTap: _openCertificates,
                    ),
                    _TileCard(
                      icon: Icons.trending_up,
                      title: 'Progress',
                      subtitle: 'Hours & grade status',
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.dashboardpage),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (ctx) => _CircleIconButton(
            icon: Icons.menu,
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        const Spacer(),
        const BrandWordmark(logoSize: 28, fontSize: 15),
        const Spacer(),
        _CircleIconButton(
          icon: Icons.notifications_none,
          onTap: () =>
              Navigator.pushNamed(context, Routes.notificationRoute),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: _kBorder, width: 1)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: _kInk),
        ),
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  final int? completed;
  final int target;
  final bool loading;
  final VoidCallback onTap;

  const _HoursCard({
    required this.completed,
    required this.target,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hours = completed ?? 0;
    final progress = (hours / target).clamp(0.0, 1.0);
    final remaining = (target - hours).clamp(0, target);
    final percent = (progress * 100).round();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF244A6E),
                _kBrand,
                Color(0xFF122C43),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _kBrand.withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Ghost accents — big translucent circles for a premium feel.
                Positioned(
                  right: -40,
                  top: -60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.timelapse_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Volunteer hours',
                                style: rf(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.85),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$percent%',
                              style: rf(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      loading
                          ? SizedBox(
                              height: 48,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$hours',
                                  style: rf(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: -1.5,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    '/ $target hrs',
                                    style: rf(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: loading ? null : progress,
                          minHeight: 7,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loading
                                  ? 'Fetching your hours…'
                                  : remaining == 0
                                      ? "You've completed your PP requirement."
                                      : "$remaining more hrs to qualify for the PP grade.",
                              style: rf(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ],
                      ),
                    ],
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

class _TileCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_TileCard> createState() => _TileCardState();
}

class _TileCardState extends State<_TileCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1A3B5A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 22, color: _kBrand),
              ),
              const Spacer(),
              Text(
                widget.title,
                style: rf(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _kInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: rf(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
