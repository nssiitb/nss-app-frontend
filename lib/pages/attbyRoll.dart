import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart'
    show PillField, PillButton, rf;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);
const Color _kSuccess = Color(0xFF16A34A);
const Color _kSuccessBg = Color(0xFFECFDF5);
const Color _kDanger = Color(0xFFDC2626);
const Color _kDangerBg = Color(0xFFFEF2F2);

class Attbyroll extends StatefulWidget {
  const Attbyroll({super.key});

  @override
  State<Attbyroll> createState() => _AttbyrollState();
}

class _AttbyrollState extends State<Attbyroll> {
  final _roll = TextEditingController();
  List<dynamic> _records = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _roll.dispose();
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

  Future<void> _fetch() async {
    if (_loading) return;
    if (_roll.text.trim().isEmpty) {
      _snack('Enter a roll number first.');
      return;
    }
    setState(() {
      _loading = true;
      _hasSearched = true;
      _records = [];
    });
    try {
      final res = await ApiService.getAttendanceByRoll(_roll.text.trim());
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          data = decoded['data'];
        } else {
          data = [];
        }
        if (!mounted) return;
        setState(() => _records = data);
      } else {
        _snack('Error: ${res.statusCode}');
      }
    } catch (_) {
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_records.isEmpty) return;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Attendance Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Roll Number: ${_roll.text}',
                style: const pw.TextStyle(fontSize: 18)),
            pw.Text(
              'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Event / Activity', 'Status'],
              data: _records.map((r) {
                final date = r['_timestamp_'] ?? r['timestamp'] ?? 'N/A';
                final event = r['_message_'] ?? r['message'] ?? 'N/A';
                final status =
                    (r['_status_'] ?? r['status'] ?? '0').toString() == '1'
                        ? 'Present'
                        : 'Absent';
                return [date, event, status];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Attendance_${_roll.text}.pdf',
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
          'By roll number',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PillField(
                controller: _roll,
                hintText: 'Roll number',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.search,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                onSubmitted: (_) => _fetch(),
              ),
              const SizedBox(height: 14),
              PillButton(
                label: 'Search',
                loading: _loading,
                onPressed: _fetch,
              ),
              const SizedBox(height: 20),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _kBrand, strokeWidth: 2.4),
      );
    }
    if (!_hasSearched) {
      return _hintCard(
        icon: Icons.search,
        title: 'Search for a volunteer',
        message: 'Enter a roll number above to see their attendance history.',
      );
    }
    if (_records.isEmpty) {
      return _hintCard(
        icon: Icons.event_busy_outlined,
        title: 'No records',
        message: 'This roll number has no attendance records yet.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kChipBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_records.length} ${_records.length == 1 ? "record" : "records"}',
                style: rf(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kBrand,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf_outlined,
                  size: 18, color: _kBrand),
              label: Text(
                'PDF',
                style: rf(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kBrand,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: _records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _RecordTile(record: _records[i]),
          ),
        ),
      ],
    );
  }

  Widget _hintCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 28, color: _kBrand),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: rf(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: rf(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: _kMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final dynamic record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final event = (record['_message_'] ?? record['message'] ?? 'Event')
        .toString();
    final ts =
        (record['_timestamp_'] ?? record['timestamp'] ?? '').toString();
    final statusRaw =
        (record['_status_'] ?? record['status'] ?? '0').toString();
    final present = statusRaw == '1';
    final chipBg = present ? _kSuccessBg : _kDangerBg;
    final chipFg = present ? _kSuccess : _kDanger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A3B5A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              present ? Icons.check_rounded : Icons.close_rounded,
              size: 22,
              color: chipFg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event,
                  style: rf(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ts.isEmpty ? '—' : ts,
                  style: rf(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              present ? 'Present' : 'Absent',
              style: rf(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: chipFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
