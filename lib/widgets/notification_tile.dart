import 'package:flutter/material.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kChipBg = Color(0xFFEEF2F7);

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String timeAgo;
  final bool unread;

  const NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.unread = false,
  });
}

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  const NotificationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(item.icon, size: 20, color: _kBrand),
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
                        item.title,
                        style: rf(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _kInk,
                        ),
                      ),
                    ),
                    if (item.unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        decoration: const BoxDecoration(
                          color: _kBrand,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: rf(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: _kMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.timeAgo,
                  style: rf(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: _kMuted,
                    letterSpacing: 0.2,
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
