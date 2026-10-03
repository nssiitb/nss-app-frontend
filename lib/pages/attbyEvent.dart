import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart'
    show PillButton, rf;
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

class Attbyevent extends StatefulWidget {
  const Attbyevent({super.key});

  @override
  State<Attbyevent> createState() => _AttbyeventState();
}

class _AttbyeventState extends State<Attbyevent> {
  String? _selectedEvent;

  List<dynamic> _events = [];
  List<dynamic> _records = [];

  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _snack(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadEvents() async {
    try {
      // AI ASSUMPTION:
      // Add ApiService.getEvents()
      final res = await ApiService.getEvents();

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (mounted) {
          setState(() {
            _events = decoded;
          });
        }
      }
    } catch (_) {
      _snack('Could not load events');
    }
  }

  Future<void> _fetch() async {
    if (_loading) return;

    if (_selectedEvent == null) {
      _snack('Select an event first.');
      return;
    }

    setState(() {
      _loading = true;
      _hasSearched = true;
      _records = [];
    });

    try {
      // AI ASSUMPTION:
      // Add ApiService.getAttendanceByEvent()
      final res =
          await ApiService.getAttendanceByEvent(_selectedEvent!);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map &&
            decoded['data'] is List) {
          data = decoded['data'];
        } else {
          data = [];
        }

        if (!mounted) return;

        setState(() {
          _records = data;
        });
      } else {
        _snack('Error: ${res.statusCode}');
      }
    } catch (_) {
      _snack("Couldn't reach the server.");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _generatePdf() async {
    if (_records.isEmpty) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Attendance Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              'Event: ${_selectedEvent ?? ""}',
            ),

            pw.Text(
              'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            ),

            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
              headers: [
                'Roll',
                'Name',
                'Status'
              ],
              data: _records.map((r) {
                return [
                  r['roll'] ?? '',
                  r['name'] ?? '',
                  ((r['_status_'] ??
                                  r['status'] ??
                                  '0')
                              .toString() ==
                          '1')
                      ? 'Present'
                      : 'Absent'
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration:
                  const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Attendance_Event.pdf',
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: _kInk,
          ),
        ),
        title: Text(
          'By event',
          style: rf(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _kInk,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedEvent,
                    hint: const Text('Select Event'),
                    isExpanded: true,
                    items: _events.map((e) {
                      return DropdownMenuItem<String>(
                        value: e['name'].toString(),
                        child: Text(e['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEvent = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              PillButton(
                label: 'Search',
                loading: _loading,
                onPressed: _fetch,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _body(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _kBrand,
          strokeWidth: 2.4,
        ),
      );
    }

    if (!_hasSearched) {
      return _hintCard(
        icon: Icons.event,
        title: 'Search attendance',
        message: 'Select an event to view attendance.',
      );
    }

    if (_records.isEmpty) {
      return _hintCard(
        icon: Icons.event_busy_outlined,
        title: 'No records',
        message: 'No attendance records found.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _kChipBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_records.length} records',
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
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 18,
                color: _kBrand,
              ),
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
            separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _RecordTile(record: _records[i]),
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
            child: Icon(
              icon,
              size: 28,
              color: _kBrand,
            ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24),
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

  const _RecordTile({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final statusRaw =
        (record['_status_'] ??
                record['status'] ??
                '0')
            .toString();

    final present = statusRaw == '1';

    final chipBg =
        present ? _kSuccessBg : _kDangerBg;

    final chipFg =
        present ? _kSuccess : _kDanger;

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
      child: ListTile(
        title: Text(
          record['name'] ?? '',
          style: rf(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _kInk,
          ),
        ),
        subtitle: Text(
          record['roll'] ?? '',
          style: rf(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: _kMuted,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius:
                BorderRadius.circular(14),
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
      ),
    );
  }
}