import 'package:flutter/material.dart';
import '../classes.dart';
import 'home.dart';

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

  void _saveChanges() {
    widget.user.weeklyGoals = _goals;
    //use api to update server with new schedule//
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 112, 76),
        title: const Text('RTT'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // First, go back
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(user: widget.user),
              ),
            ); // Then, navigate to GoalPage
          },
          icon: Icon(
            Icons.home,
            color: Colors.white,
          ), // use bar_chart for the next icon for stat page
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(6.0),
            child: IconButton(
              onPressed: () {
                _saveChanges();
              },
              icon: Icon(Icons.save_alt_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a Goal...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            //widget goes here...
            AddGoalWidget(
              onAddGoal: (newGoal) {
                setState(() {
                  _goals.add(newGoal);
                });
              },
            ),
            //return AddGoalWidget()
            Text(
              'Your Goals...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Use _todayGoals directly, removing Builder and the redundant list
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
                        onDelete: () {
                          setState(() {
                            _goals.removeAt(
                              index,
                            ); // Removes goal at this index
                          });
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
  final VoidCallback onDelete; // Accepts a function for deletion

  const GoalTile({Key? key, required this.goal, required this.onDelete})
    : super(key: key);

  //biggest mcabe's complexity c = 7
  String _getdaystr() {
    return [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ][goal.weekDay - 1];
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
          "Time Cost: ${goal.timeCost} hours, ${_getdaystr()}",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: onDelete, // Calls the function passed from the parent
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
  int _selectedDay = 1; // Default to Monday

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
          // Goal Input
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

          // Time Cost Input
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

          // Day Selector Dropdown
          DropdownButton<int>(
            value: _selectedDay,
            dropdownColor: Color.fromARGB(255, 48, 112, 76), // Match theme
            style: const TextStyle(color: Colors.white),
            items: List.generate(7, (index) {
              return DropdownMenuItem<int>(
                value: index + 1,
                child: Text(
                  [
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday",
                    "Sunday",
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

          // Add Goal Button
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
                  );
                  widget.onAddGoal(newGoal);

                  // Clear input fields
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
