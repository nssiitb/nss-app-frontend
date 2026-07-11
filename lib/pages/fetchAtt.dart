import 'package:flutter/material.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class Fetchatt extends StatelessWidget {
  const Fetchatt({super.key});

  void _upcoming(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _kInk),
        ),
        title: Text(
          'Attendance',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              'View records',
              style: rf(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: _kInk,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Look up attendance by roll, event, or department.',
              style: rf(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: _kMuted,
              ),
            ),
            const SizedBox(height: 24),
            _RowCard(
              icon: Icons.person_search_outlined,
              title: 'By roll number',
              subtitle: 'Attendance history for a single volunteer.',
              onTap: () => Navigator.pushNamed(context, Routes.attbyRoll),
            ),
            const SizedBox(height: 12),
            _RowCard(
              icon: Icons.event_available_outlined,
              title: 'By event',
              subtitle: 'List of volunteers who attended a given event.',
              comingSoon: true,
              onTap: () => _upcoming(context),
            ),
            const SizedBox(height: 12),
            _RowCard(
              icon: Icons.apartment_outlined,
              title: 'By department',
              subtitle: 'All attendance grouped by department.',
              comingSoon: true,
              onTap: () => _upcoming(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool comingSoon;
  final VoidCallback onTap;

  const _RowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  State<_RowCard> createState() => _RowCardState();
}

class _RowCardState extends State<_RowCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(widget.icon, size: 22, color: _kBrand),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: rf(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _kInk,
                            ),
                          ),
                        ),
                        if (widget.comingSoon)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kChipBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Soon',
                              style: rf(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _kBrand,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: rf(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: _kMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: _kMuted),
            ],
          ),
        ),
      ),
    );
  }
}
