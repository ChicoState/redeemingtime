import 'package:flutter/material.dart';
import '../classes.dart';
import 'goalpage.dart';
import 'profiles.dart';
import 'login.dart'; // for fetchGoals
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final UserClass user;
  final bool refreshGoals;

  HomePage({required this.user, this.refreshGoals = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GoalsClass> _todayGoals = [];

  @override
  void initState() {
    super.initState();
    if (widget.refreshGoals) {
      _refreshGoalsFromServer();
    } else {
      _loadTodayGoals();
    }
  }

  void refreshTodayGoals() {
    _loadTodayGoals();
  }

  void _loadTodayGoals() {
    int today = DateTime.now().weekday % 7; // Adjust for Sunday
    List<GoalsClass> tempGoals = [];

    for (GoalsClass goal in widget.user.weeklyGoals) {
      if (goal.weekDay == today && goal.completed == false) {
        tempGoals.add(goal);
      }
    }

    setState(() {
      _todayGoals = tempGoals;
    });
  }

  Future<void> _refreshGoalsFromServer() async {
    try {
      List<GoalsClass> updatedGoals =
          await fetchGoals(widget.user.username, widget.user.password);
      if (!mounted) return;
      widget.user.weeklyGoals = updatedGoals;
      _loadTodayGoals();
    } catch (e) {
      print("Failed to refresh goals: $e");
    }
  }

  List<double> buildWeeklyStats(List<GoalsClass> goals) {
    List<double> stats = List.filled(7, 0.0); // Monday to Sunday
    for (var goal in goals) {
      if (goal.completed) {
        int index = goal.weekDay % 7;
        stats[index] += goal.timeCost/60;
      }
    }
    return stats;
  }

  Future<void> _confirmLogout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        leading: Container(
          padding: const EdgeInsets.all(6.0),
          child: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalPage(user: widget.user),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Goals',
          ),
        ),
        actions: [
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
                ),
              );
            },
            icon: const Icon(Icons.people, color: Colors.white),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Week Statistics...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: BarChartWidget(data: buildWeeklyStats(widget.user.weeklyGoals)),
            ),
            const Text(
              'Daily Goals...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _todayGoals.isEmpty
                ? const Text(
                    'No goals set for today!',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _todayGoals.length,
                      itemBuilder: (context, index) {
                        return DailyGoalTile(
                          goal: _todayGoals[index],
                          user: widget.user,
                          onGoalUpdated: refreshTodayGoals,
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

class BarChartWidget extends StatelessWidget {
  final List<double> data;

  const BarChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${_dayLabels[group.x]}\n${rod.toY.toInt()} hour',
                const TextStyle(color: Colors.white),
              ),
            ),
          ),
          barGroups: _buildBarGroups(),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
              ),
              axisNameWidget: const Text('Hours', style: TextStyle(fontSize: 12)),
              axisNameSize: 30,
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return Text(
                    _dayLabels[index % 7],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: const Color.fromARGB(255, 48, 112, 76),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}

const List<String> _dayLabels = [
  'Sun','Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
];

class DailyGoalTile extends StatefulWidget {
  final GoalsClass goal;
  final UserClass user;
  final VoidCallback onGoalUpdated;

  const DailyGoalTile({Key? key, required this.goal, required this.user, required this.onGoalUpdated}) : super(key: key);

  @override
  _DailyGoalTileState createState() => _DailyGoalTileState();
}

class _DailyGoalTileState extends State<DailyGoalTile> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.goal.completed;
  }

  Future<void> deleteGoalFromServer(String goalName) async {
    final String baseUrl = "http://localhost:8000";
    final username = widget.user.username;
    final password = widget.user.password;
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final encodedName = Uri.encodeComponent(goalName);
    final url = Uri.parse('$baseUrl/goals/$encodedName/');

    final response = await http.delete(url, headers: {
      "Authorization": basicAuth,
    });

    if (response.statusCode != 204) {
      throw Exception("Failed to delete goal");
    }
  }

  Future<void> saveGoalToServer(GoalsClass goal) async {
    final String baseUrl = "http://localhost:8000";
    final username = widget.user.username;
    final password = widget.user.password;
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
        "timeCost": (goal.timeCost).toInt(),
        "weekday": goal.weekDay,
        "completed": goal.completed,
        "tag": "none",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save goal");
    }
  }

  void _toggleCompletion() async {
    setState(() {
      _isCompleted = !_isCompleted;
      widget.goal.completed = _isCompleted;
    });

    try {
      await deleteGoalFromServer(widget.goal.goal);
      await saveGoalToServer(widget.goal);
      widget.onGoalUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Goal updated: ${widget.goal.goal}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating goal. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 48, 112, 76),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        title: Text(
          widget.goal.goal,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "Time Cost: ${widget.goal.timeCost} minutes",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: Icon(
            _isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.white,
          ),
          onPressed: _toggleCompletion,
        ),
      ),
    );
  }
}
