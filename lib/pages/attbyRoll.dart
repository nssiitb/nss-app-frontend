import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nssapp/global/IPv4_address.dart'; // To access baseURL
import 'package:intl/intl.dart';

// PDF Dependencies
// Ensure you have added 'pdf' and 'printing' to your pubspec.yaml
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Attbyroll extends StatefulWidget {
  const Attbyroll({super.key});

  @override
  State<Attbyroll> createState() => _AttbyrollState();
}

class _AttbyrollState extends State<Attbyroll> {
  final TextEditingController _rollController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> _attendanceData = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  // 1. Function to fetch data from API
  Future<void> _fetchAttendance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _attendanceData = []; // Clear previous results
    });

    try {
      // Assuming the API expects a JSON body with "roll" key
      // Adjust the body keys ("roll" vs "_roll_") based on your backend requirement
      var body = jsonEncode({
        "roll": _rollController.text.trim(),
      });

      final response = await http.post(
        Uri.parse('$baseURL/attByRoll'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Adjust this parsing based on whether your API returns a direct list 
        // or a wrapper object like { "data": [...] }
        if (jsonResponse is List) {
          setState(() {
            _attendanceData = jsonResponse;
          });
        } else if (jsonResponse['data'] != null) {
          setState(() {
            _attendanceData = jsonResponse['data'];
          });
        } else {
           // Fallback if structure is different
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No attendance data found format unknown.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Function to generate and print/download PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text("Attendance Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Roll Number: ${_rollController.text}", style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}"),
              pw.SizedBox(height: 20),
              
              // Create the table
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Event/Activity', 'Status'],
                data: _attendanceData.map((record) {
                  // Adjust these keys ('timestamp', 'message', 'status') to match your actual API response
                  final date = record['_timestamp_'] ?? record['timestamp'] ?? 'N/A';
                  final event = record['_message_'] ?? record['message'] ?? 'N/A';
                  final status = (record['_status_'] ?? record['status'] ?? '0').toString() == '1' ? 'Present' : 'Absent';
                  
                  return [date, event, status];
                }).toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    // This allows the user to print or share (save to files) the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Attendance_${_rollController.text}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance"),
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search Section
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rollController,
                      decoration: InputDecoration(
                        labelText: 'Enter Roll Number',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      backgroundColor: const Color(0xFF6A5AE0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _fetchAttendance,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // List or Empty State
            Expanded(
              child: _isLoading 
                ? const Center(child: Text("Fetching records..."))
                : _attendanceData.isEmpty 
                  ? Center(
                      child: Text(
                        _hasSearched ? "No attendance records found." : "Enter a roll number to see details.",
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : Column(
                      children: [
                        // Results Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Records Found: ${_attendanceData.length}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            TextButton.icon(
                              onPressed: _generatePdf,
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text("Download PDF"),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        // List View
                        Expanded(
                          child: ListView.builder(
                            itemCount: _attendanceData.length,
                            itemBuilder: (context, index) {
                              final item = _attendanceData[index];
                              // Safely accessing data with fallbacks
                              final eventName = item['_message_'] ?? item['message'] ?? 'Unknown Event';
                              final date = item['_timestamp_'] ?? item['timestamp'] ?? 'Unknown Date';
                              final status = (item['_status_'] ?? item['status']).toString();
                              
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: status == '1' ? Colors.green.shade100 : Colors.red.shade100,
                                    child: Icon(
                                      status == '1' ? Icons.check : Icons.close,
                                      color: status == '1' ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(eventName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(date),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}