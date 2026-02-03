import 'package:flutter/material.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  FeedbackFormState createState() => FeedbackFormState();
}

class FeedbackFormState extends State<FeedbackForm> {
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();

  // List of departments for the dropdown
  final List<String> _departments = [
    'Educational Outreach',
    'Environment and Sustainability',
    'Social Development',
  ];
// Variable to hold the selected department
  String? _selectedDepartment;

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 600, // Adjust as needed for proper spacing
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.person,
                    color: Color.fromARGB(195, 1, 1, 59),
                  ),
                  hintText: 'Enter your name',
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.school,
                    color: Color.fromARGB(195, 1, 1, 59),
                  ),
                  hintText: 'Enter your roll number',
                  labelText: 'Roll number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your roll number';
                  }
                  return null;
                },
              ),
              // Dropdown menu for department
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  icon: Icon(Icons.dataset_linked,
                      color: Color.fromARGB(195, 1, 1, 59)),
                  labelText: 'Department',
                ),
                value: _selectedDepartment,
                items: _departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
                dropdownColor: Colors.white,
                menuMaxHeight:
                    200.0, // Adjust this value to control the dropdown height
              ),

              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.phone,
                    color: Color.fromARGB(195, 1, 1, 59),
                  ),
                  hintText: 'Enter a phone number',
                  labelText: 'Phone',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.mail,
                    color: Color.fromARGB(195, 1, 1, 59),
                  ),
                  hintText: 'Enter your mail Id',
                  labelText: 'E-mail',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Add spacing before feedback box
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type your feedback here...',
                        border: InputBorder.none, // Removes inner border
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide your feedback';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 1, 1, 59),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 50,
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Process data
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Form Submitted')),
                            );
                          }
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}