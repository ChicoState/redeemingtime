import 'package:flutter/material.dart';
import '../classes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'goalpage.dart';
import 'profiles.dart';

class HomePage extends StatefulWidget {
  final UserClass user;
  HomePage({required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GoalsClass> _todayGoals = [];

  @override
  void initState() {
    _loadTodayGoals();
    super.initState();
  }

  void submitCompleted() {
    List<GoalsClass> completed = [];
    for (GoalsClass goal in _todayGoals) {
      if (goal.completed == true) {
        completed.add(goal);
      }
    }
    //call api weekend ----------------
  }

  void _loadTodayGoals() {
    int today = DateTime.now().weekday;
    List<GoalsClass> tempGoals = [];

    for (GoalsClass goal in widget.user.weeklyGoals) {
      if (goal.weekDay == today) {
        tempGoals.add(goal);
      }
    }

    setState(() {
      _todayGoals.addAll(tempGoals);
    });
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
        leading: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context); // First, go back
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalPage(user: widget.user),
                    ),
                  ); // Then, navigate to GoalPage
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ), // use bar_chart for the next icon for stat page
              ),
            ),
            Container(
              //other icons...
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(6.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context); // First, go back
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user),
                  ),
                );
              },
              icon: Icon(Icons.people, color: Colors.white),
            ),
          ),
          Container(
            padding: EdgeInsets.all(6.0),
            child: IconButton(
              onPressed: () {
                //newpage
              },
              icon: Icon(Icons.menu, color: Colors.white),
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
              '10-Week Statistics...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  16.0,
                ), // Adjust radius as needed
              ),
              child: BarChartWidget(
                data: widget.user.weeklyHoursStats,
              ), // Sample data
            ),
            Text(
              'Daily Goals...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Use _todayGoals directly, removing Builder and the redundant list
            _todayGoals.isEmpty
                ? const Text(
                  'No goals set for today!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: _todayGoals.length,
                    itemBuilder: (context, index) {
                      return DailyGoalTile(goal: _todayGoals[index]);
                    },
                  ),
                ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    48,
                    112,
                    76,
                  ), // Background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: ElevatedButton(
                  onPressed: () {
                    //call submit function
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyGoalTile extends StatefulWidget {
  final GoalsClass goal;

  const DailyGoalTile({Key? key, required this.goal}) : super(key: key);

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

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
      widget.goal.completed = _isCompleted;
    });
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
          "Time Cost: ${widget.goal.timeCost} hours",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: Icon(
            _isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
            color: _isCompleted ? Colors.white : Colors.white,
          ),
          onPressed: _toggleCompletion, // Toggle the checkbox on click
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
              getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
            ),
          ),
          barGroups: _buildBarGroups(),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Week ${value.toInt() + 1}"),
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
