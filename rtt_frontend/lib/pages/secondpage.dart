import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _goalController = TextEditingController();
  List<Map<String, String>> _goals = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // Load goals from SharedPreferences
  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedGoals = prefs.getString('goals');
    if (savedGoals != null) {
      setState(() {
        _goals = List<Map<String, String>>.from(
          jsonDecode(savedGoals).map((goal) => Map<String, String>.from(goal))
        );
      });
      print('Goals loaded: $_goals');
    }
  }

  // Save goals to SharedPreferences
  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goals', jsonEncode(_goals));
    print('Goals saved: $_goals');
  }

  // Show date picker and set selected date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Add goal with date
  void _addGoal() {
  if (_goalController.text.isNotEmpty && _selectedDate != null && _goals.length < 10) {
    setState(() {
      _goals.add({
        'goal': _goalController.text,
        'date': _selectedDate!.toIso8601String().split('T')[0],
      });
      _goalController.clear();
      _selectedDate = null;
    });

    _saveGoals().then((_) => _loadGoals()); // Load after saving
  }
}

void _removeGoal(int index) {
  setState(() {
    _goals.removeAt(index);
  });

  _saveGoals().then((_) => _loadGoals()); // Load after saving
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 17, 120, 61),
        title: const Text('Goal Page'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to your goals!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),

            // Goal Input Field
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Enter a goal',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // Date Picker Button
            Row(
              children: [
                Text(
                  _selectedDate == null 
                    ? 'No date selected' 
                    : 'Selected Date: ${_selectedDate!.toIso8601String().split('T')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set button color to green
                    foregroundColor: Colors.white,
                  )
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Add Goal Button
            ElevatedButton(
              onPressed: _addGoal,
              child: const Text('Add Goal'),
              style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set button color to green
                    foregroundColor: Colors.white,
                  )
            ),

            const SizedBox(height: 20),

            // Goals List
            Expanded(
              child: ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(_goals[index]['goal']!),
                    subtitle: Text('Due Date: ${_goals[index]['date']!}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeGoal(index),
                    ),
                  );
                },
              ),
            ),

            // Go Back Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}