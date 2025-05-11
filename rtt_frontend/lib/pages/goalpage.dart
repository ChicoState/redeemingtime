import 'package:flutter/material.dart';
import '../classes.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoalPage extends StatefulWidget {
  final UserClass user;
  GoalPage({required this.user});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  List<GoalsClass> _goals = [];

  @override
  void initState() {
    _loadGoals();
    super.initState();
  }

  void _loadGoals() {
    setState(() {
      _goals.addAll(widget.user.weeklyGoals);
    });
  }

  Future<void> saveGoalToServer(GoalsClass goal) async {
    final String baseUrl = "http://localhost:8000";
    final String username = widget.user.username;
    final String password = widget.user.password;

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final response = await http.post(
      Uri.parse("$baseUrl/goals/"),
      headers: {
        "Authorization": basicAuth,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": goal.goal,
        "description": goal.goal,
        "timeCost": (goal.timeCost*60).toInt(),
        "weekday": goal.weekDay,
        "completed": goal.completed,
        "tag": "none",
      }),
    );

    if (response.statusCode == 200) {
      print("Goal saved: ${goal.goal}");
    } else if (response.statusCode == 406) {
      print("Duplicate goal, skipped: ${goal.goal}");
    } else {
      throw Exception("Failed to save goal: ${goal.goal}");
    }
  }

  Future<void> deleteGoalFromServer(GoalsClass goal) async {
    final String baseUrl = "http://localhost:8000";
    final String username = widget.user.username;
    final String password = widget.user.password;

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final encodedGoalName = Uri.encodeComponent(goal.goal);

    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$encodedGoalName/'),
      headers: {
        "Authorization": basicAuth,
      },
    );

    if (response.statusCode == 204) {
      print("Goal deleted: ${goal.goal}");
    } else {
      print("Failed to delete goal: ${goal.goal}, Status: ${response.statusCode}");
    }
  }

  void _saveChanges() async {
    int successful = 0;
    int skipped = 0;

    try {
      for (GoalsClass goal in _goals) {
        try {
          await saveGoalToServer(goal);
          successful++;
        } catch (e) {
          skipped++;
        }
      }

      widget.user.weeklyGoals = _goals;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved: $successful goals. Skipped: $skipped goals.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save goals. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 112, 76),
        title: const Text('RTT'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
         onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(user: widget.user, refreshGoals: true),
    ),
  );
}
,
          icon: const Icon(Icons.home, color: Colors.white),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(6.0),
            child: IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
              tooltip: 'Save Goals',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a Goal...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            AddGoalWidget(
              onAddGoal: (newGoal) {
                setState(() {
                  _goals.add(newGoal);
                });
              },
            ),
            const Text(
              'Your Goals...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _goals.isEmpty
                ? const Text(
                    'No goals set!',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        return GoalTile(
                          goal: _goals[index],
                          onDelete: () async {
                            GoalsClass deletedGoal = _goals[index];
                            setState(() {
                              _goals.removeAt(index);
                            });
                            await deleteGoalFromServer(deletedGoal);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class GoalTile extends StatelessWidget {
  final GoalsClass goal;
  final VoidCallback onDelete;

  const GoalTile({Key? key, required this.goal, required this.onDelete}) : super(key: key);

  String _getDayStr() {
    return [
      "Sunday","Monday", "Tuesday", "Wednesday",
      "Thursday", "Friday", "Saturday"
    ][goal.weekDay];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 48, 112, 76),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        title: Text(
          goal.goal,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "Time Cost: ${goal.timeCost < 10 ? (goal.timeCost * 60).toInt() : goal.timeCost.toInt()} minutes, ${_getDayStr()}",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class AddGoalWidget extends StatefulWidget {
  final Function(GoalsClass) onAddGoal;

  const AddGoalWidget({Key? key, required this.onAddGoal}) : super(key: key);

  @override
  _AddGoalWidgetState createState() => _AddGoalWidgetState();
}

class _AddGoalWidgetState extends State<AddGoalWidget> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _timeCostController = TextEditingController();
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 48, 112, 76),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _goalController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Goal Description",
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _timeCostController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Time Cost (hours)",
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButton<int>(
            value: _selectedDay,
            dropdownColor: const Color.fromARGB(255, 48, 112, 76),
            style: const TextStyle(color: Colors.white),
            items: List.generate(7, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  [
                    "Sunday", "Monday", "Tuesday", "Wednesday",
                    "Thursday", "Friday", "Saturday"
                  ][index],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }),
            onChanged: (value) {
              setState(() {
                _selectedDay = value!;
              });
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
              onPressed: () {
                if (_goalController.text.isNotEmpty &&
                    _timeCostController.text.isNotEmpty) {
                  GoalsClass newGoal = GoalsClass(
                    goal: _goalController.text,
                    timeCost: double.tryParse(_timeCostController.text) ?? 0,
                    weekDay: _selectedDay,
                    tag: 0,
                  );
                  widget.onAddGoal(newGoal);

                  _goalController.clear();
                  _timeCostController.clear();
                  setState(() {
                    _selectedDay = 1;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
