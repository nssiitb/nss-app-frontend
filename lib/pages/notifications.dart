import 'package:flutter/material.dart';
import 'package:nssapp/widgets/notification_tile.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    // No API endpoint yet — will populate from a fetch once available.
    const List<NotificationItem> items = [];

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
          'Notifications',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
        centerTitle: false,
        actions: [
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  'Mark all read',
                  style: rf(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kBrand,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => NotificationTile(item: items[i]),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kChipBg,
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.notifications_none,
                  size: 34, color: _kBrand),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'re all caught up',
              style: rf(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _kInk,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New notifications about events and\nattendance will show up here.',
              textAlign: TextAlign.center,
              style: rf(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: _kMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
