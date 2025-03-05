import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//impliment this...

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  List<String> usernames = [];

  @override
  void initState(){
    _loadFriends();
    super.initState();
  }

  Future<void> _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      usernames = prefs.getStringList('usernames') ?? []; // Load stored usernames
    });
  }

  Future<void> addUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usernames.add(username); // Add new username to list
    await prefs.setStringList('usernames', usernames); // Save list in storage
    setState(() {}); // Refresh UI
  }

  Future<void> clearUsernames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('usernames');
    setState(() {
      usernames = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Usernames"),
        backgroundColor: const Color.fromARGB(255, 17, 120, 61),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
          actions: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.settings_input_antenna,
                  color: Colors.white,
                ),
                onPressed: () {
                  print('temp: sent button pressed'); //make api for this (send_status.dart)
                },
              ),
            )
          ]
      ),




      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter Username",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addUsername(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: usernames.isEmpty
                ? Center(child: Text("No usernames saved."))
                : ListView.builder(
                    itemCount: usernames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(usernames[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: clearUsernames,
        child: Icon(Icons.delete),
        tooltip: "Clear All",
      ),
    );
  }
}