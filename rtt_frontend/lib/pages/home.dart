import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'goalpage.dart';
import 'sharepage.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _todayGoals = [];
  @override
  void initState() {
    super.initState();
    _loadTodayGoals();
  }
  Future<void> _loadTodayGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedGoals = prefs.getString('goals');
    if (savedGoals != null) {
      List<Map<String, String>> allGoals = List<Map<String, String>>.from(
        jsonDecode(savedGoals).map((goal) => Map<String, String>.from(goal))
      );
      String todayDate = DateTime.now().toIso8601String().split('T')[0];
      List<Map<String, String>> todayGoals = allGoals.where((goal) {
        return goal['date'] == todayDate;
      }).toList();

      setState(() {
        _todayGoals = todayGoals;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 17, 120, 61),
        title: const Text('RTT'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        leading: 
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalPage()),
              );
            },
          ),
          actions: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SharePage()),
                  );
                },
              ),
            )
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Goals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _todayGoals.isEmpty
                ? const Text('No goals for today!', style: TextStyle(fontSize: 18))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _todayGoals.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.arrow_forward, color: Colors.green),
                          title: Text(_todayGoals[index]['goal']!),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 20),
            const Text(
              'See topright to send to friends! :)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}