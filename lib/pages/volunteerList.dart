import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nssapp/global/IPv4_address.dart';

class Volunteer {
  final String roll;
  final String name;
  final String mobile;
  final String dept;
  final String email;
  final int hours;

  Volunteer({
    required this.roll,
    required this.name,
    required this.mobile,
    required this.dept,
    required this.email,
    required this.hours,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      roll: json['roll'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      dept: json['dept'] ?? '',
      email: json['email'] ?? '',
      hours: json['hours'] is int
          ? json['hours']
          : int.tryParse(json['hours']?.toString() ?? '0') ?? 0,
    );
  }
}

class Volunteerlist extends StatefulWidget {
  const Volunteerlist({super.key});

  @override
  State<Volunteerlist> createState() => _VolunteerlistState();
}

class _VolunteerlistState extends State<Volunteerlist> {
  // State variables
  List<Volunteer> _allVolunteers = [];
  List<Volunteer> _filteredVolunteers = [];
  String? _selectedDept;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  // Updated department list based on your registration form
  final Map<String, String> _departments = {
    'All': 'All Departments',
    'CE': 'Campus Engagement',
    'EO': 'Educational Outreach',
    'SD': 'Social Development',
    'EnS': 'Environment and Sustainabilty',
  };

  @override
  void initState() {
    super.initState();
    fetchVolunteers();
    _searchController.addListener(_filterVolunteers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterVolunteers);
    _searchController.dispose();
    super.dispose();
  }

  /// --- Backend Integration ---
  Future<void> fetchVolunteers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(baseURL + '/sendVolunteers'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allVolunteers =
              data.map((json) => Volunteer.fromJson(json)).toList();
          _filteredVolunteers = _allVolunteers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load volunteers. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load volunteers. Check your network connection.';
        _isLoading = false;
      });
    }
  }

  /// Filters the list of volunteers based on the search query and selected department.
  void _filterVolunteers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVolunteers = _allVolunteers.where((volunteer) {
        final nameMatches = volunteer.name.toLowerCase().contains(query);
        final rollMatches = volunteer.roll.toLowerCase().contains(query);
        final deptMatches = _selectedDept == null ||
            _selectedDept == 'All' ||
            volunteer.dept == _selectedDept;

        return (nameMatches || rollMatches) && deptMatches;
      }).toList();
    });
  }

  // Helper to get the full department name from its code
  String getDeptName(String code) {
    return _departments[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Volunteer List',
          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        // Makes title and icons dark against the white background
        foregroundColor: Colors.black,
        elevation: 1.0, // Adds a subtle shadow
      ),
      body: Column(
        children: [
          // Search and Filter UI
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Name or Roll No',
                      hintStyle: const TextStyle(fontFamily: 'Raleway'),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 15.0),
                    ),
                    style: const TextStyle(fontFamily: 'Raleway'),
                  ),
                ),
                const SizedBox(width: 12),
                // Department Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDept ?? 'All',
                      hint: const Text('Dept'),
                      items: _departments.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(
                            key,
                            style: const TextStyle(fontFamily: 'Raleway'),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDept = newValue;
                          _filterVolunteers();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body Content: Loading, Error, or List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontFamily: 'Raleway'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _filteredVolunteers.isEmpty
                        ? const Center(
                            child: Text(
                              'No volunteers found.',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontFamily: 'Raleway'),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchVolunteers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _filteredVolunteers.length,
                              itemBuilder: (context, index) {
                                final volunteer = _filteredVolunteers[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade50,
                                      child: Text(
                                        volunteer.name.isNotEmpty
                                            ? volunteer.name[0]
                                            : 'V',
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Raleway'),
                                      ),
                                    ),
                                    title: Text(volunteer.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Raleway')),
                                    subtitle: Text(
                                        '${volunteer.roll} | ${getDeptName(volunteer.dept)}\n${volunteer.email}',
                                        style: const TextStyle(
                                            fontFamily: 'Raleway')),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${volunteer.hours} hrs',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.blue,
                                              fontFamily: 'Raleway'),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
