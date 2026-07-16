import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/global/global_auth_helper.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/app_drawer.dart';
import 'package:nssapp/widgets/login_form.dart' show BrandWordmark, rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);
const Color _kBorder = Color(0xFFE9ECEF);

class Homeaa extends StatefulWidget {
  final String name;
  const Homeaa({super.key, required this.name});

  @override
  State<Homeaa> createState() => _HomeaaState();
}

class _HomeaaState extends State<Homeaa> {
  bool _starting = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _startWindow() async {
    if (_starting) return;
    setState(() => _starting = true);

    try {
      await GlobalAuthHelper.fetchToken();
      final roll = GlobalAuthHelper.globalrollNo;
      final timeStamp =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are off. Enable location to continue.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location denied. Enable it in Settings › Apps › NSS IITB › Permissions.');
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final res = await ApiService.startAttendanceWindow({
        '_roll_': roll,
        '_name_': widget.name,
        '_timestamp_': timeStamp,
        '_latitude_': position.latitude.toString(),
        '_longitude_': position.longitude.toString(),
      });

      if (!mounted) return;
      if (res.statusCode == 201) {
        _snack('Attendance window started.');
      } else {
        _snack('Failed to start window: ${res.body}');
      }
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      _snack(msg);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      drawer: const AppDrawer(),
      body: SafeArea(
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
                "Ready to run today's activity?",
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                ),
              ),
              const SizedBox(height: 24),
              _WindowCard(
                loading: _starting,
                onTap: _startWindow,
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
                    icon: Icons.add_circle_outline,
                    title: 'Add Event',
                    subtitle: 'Schedule a new activity',
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.addEvent),
                  ),
                  _TileCard(
                    icon: Icons.event_note_outlined,
                    title: 'All Events',
                    subtitle: 'This month',
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.allEvents),
                  ),
                  _TileCard(
                    icon: Icons.group_outlined,
                    title: 'Volunteer List',
                    subtitle: 'Roster & departments',
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.volListRoute),
                  ),
                  _TileCard(
                    icon: Icons.assignment_outlined,
                    title: 'Attendance',
                    subtitle: 'Records & lookups',
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.fetchAtt),
                  ),
                ],
              ),
            ],
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

class _WindowCard extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _WindowCard({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: loading ? null : onTap,
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
                              Icons.watch_later_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Attendance window',
                            style: rf(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Start today\'s window',
                        style: rf(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Volunteers around your location can mark attendance while the window is open.',
                        style: rf(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (loading) ...[
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  loading ? 'Starting…' : 'Tap to start',
                                  style: rf(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                alignment: Alignment.center,
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
