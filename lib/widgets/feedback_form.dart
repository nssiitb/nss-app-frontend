import 'package:flutter/material.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kChipBg = Color(0xFFEEF2F7);

const List<_Category> _kCategories = [
  _Category('General', Icons.chat_bubble_outline),
  _Category('Campus Engagement', Icons.groups_outlined),
  _Category('Educational Outreach', Icons.school_outlined),
  _Category('Social Development', Icons.favorite_outline),
  _Category('Environment', Icons.eco_outlined),
  _Category('App / Bug report', Icons.bug_report_outlined),
];

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  _Category _selected = _kCategories.first;
  int _rating = 0;
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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

  Future<void> _submit() async {
    if (_submitting) return;
    final msg = _messageController.text.trim();
    if (msg.length < 10) {
      _snack('Please write at least a few words.');
      return;
    }
    setState(() => _submitting = true);
    // No backend endpoint yet — simulate a submission and reset the form.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _messageController.clear();
    setState(() {
      _selected = _kCategories.first;
      _rating = 0;
      _submitting = false;
    });
    _snack('Thanks — your feedback has been sent.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: _kInk),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Text(
                'Feedback',
                style: rf(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Hero
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.chat_bubble_outline,
                color: _kBrand, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            "We'd love to hear from you",
            style: rf(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: _kInk,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us what worked, what didn\'t, or what you\'d like to see next.',
            style: rf(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: _kMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          // Category
          Text(
            'CATEGORY',
            style: rf(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kCategories.map((c) => _CategoryChip(
                  category: c,
                  selected: c.label == _selected.label,
                  onTap: () => setState(() => _selected = c),
                )).toList(),
          ),
          const SizedBox(height: 24),
          // Rating
          Text(
            'HOW WAS YOUR EXPERIENCE?',
            style: rf(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: filled ? _kBrand : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F1A3B5A),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? Colors.white : _kMuted,
                      size: 22,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Message
          Text(
            'MESSAGE',
            style: rf(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: TextField(
              controller: _messageController,
              maxLines: 6,
              minLines: 5,
              maxLength: 500,
              style: rf(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _kInk,
                height: 1.5,
              ),
              cursorColor: _kBrand,
              decoration: InputDecoration(
                hintText: 'Share your thoughts…',
                hintStyle: rf(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                ),
                counterStyle: rf(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Submit
          SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: _submitting
                    ? null
                    : [
                        BoxShadow(
                          color: _kBrand.withOpacity(0.28),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBrand,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kBrand.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Send Feedback',
                        style: rf(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

class _CategoryChip extends StatelessWidget {
  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kBrand : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1A3B5A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 15,
              color: selected ? Colors.white : _kBrand,
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: rf(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : _kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
