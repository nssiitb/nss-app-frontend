import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nssapp/global/IPv4_address.dart';

class AddEvents extends StatefulWidget {
  const AddEvents({super.key});

  @override
  State<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final hoursController = TextEditingController();
  final aaController = TextEditingController();
  final remarksController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  String? selectedDepartment;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final List<String> departments = [
    "Campus Engagement",
    "Educational Outreach",
    "Social Development",
    "Environment & Sustainability",
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
      final now = DateTime.now();
      final dt =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      timeController.text =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
    }
  }

  void _clearFields() {
    setState(() {
      nameController.clear();
      dateController.clear();
      timeController.clear();
      hoursController.clear();
      aaController.clear();
      remarksController.clear();
      selectedDepartment = null;
      selectedDate = null;
      selectedTime = null;
    });
  }

  void saveEvent() async {
    var reqBody = {
      "name": nameController.text,
      "date": dateController.text,
      "time": timeController.text,
      "hours": hoursController.text,
      "AA": aaController.text,
      "remarks": remarksController.text,
      "department": selectedDepartment ?? "",
    };
    var response = await http.post(Uri.parse(baseURL + '/addEvent'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));

    var jsonResponse = jsonDecode(response.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(jsonResponse['message'] ?? "Unknown response"),
        duration: const Duration(seconds: 3),
      ),
    );
    _clearFields();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF344055),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF344055)),
      filled: true,
      fillColor: const Color(0xFFC7E4F8), // Light blue pastel
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF344055)),
        title: const Text(
          "Create a new Event",
          style: TextStyle(
            color: Color(0xFF344055),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration("Event Name", Icons.event_note),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: _inputDecoration("Date", Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: timeController,
                readOnly: true,
                decoration: _inputDecoration("Time", Icons.access_time),
                onTap: _pickTime,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Hours", Icons.timer),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: aaController,
                decoration:
                    _inputDecoration("Activity Associates", Icons.people_alt),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                items: departments
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                decoration: _inputDecoration("Department", Icons.apartment),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: remarksController,
                maxLines: 3,
                decoration:
                    _inputDecoration("Description", Icons.description_outlined)
                        .copyWith(hintText: "Add details..."),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: saveEvent,
                  icon: const Icon(Icons.add, color: Color(0xFF344055)),
                  label: const Text(
                    "Create Event",
                    style: TextStyle(
                      color: Color(0xFF344055),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9C9D4), // Pink pastel
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
