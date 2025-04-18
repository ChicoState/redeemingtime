import 'package:flutter/material.dart';
import '../classes.dart';
import 'home.dart';
import 'package:pie_chart/pie_chart.dart';

class ProfilePage extends StatefulWidget {
  final UserClass user;
  ProfilePage({required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<FriendsClass> _friends = [];

  @override
  void initState() {
    _loadFriends();
    super.initState();
  }

  void _loadFriends() {
    setState(() {
      _friends.addAll(widget.user.friends);
    });
  }

  void _saveChanges() {
    widget.user.friends = _friends;
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
            //button for leaderboard
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      //leaderboard dropdown menu
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
                        "LeaderBoard",
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
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: PersonalProfileWidget(
                  username: widget.user.username,
                  email: widget.user.email,
                  password: widget.user.password,
                  totalHoursScore: widget.user.totalHoursScore,
                ),
              ),
            ),
            //widget for friendsList
            //const SizedBox(height: 10),
            _friends.isEmpty
                ? const Text(
                  'No friends set!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      return FriendsProfileWidget(
                        friend: _friends[index],
                        onDelete: () {
                          setState(() {
                            _friends.removeAt(
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

class PersonalProfileWidget extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final double totalHoursScore;

  const PersonalProfileWidget({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
    required this.totalHoursScore,
  }) : super(key: key);

  @override
  _PersonalProfileWidgetState createState() => _PersonalProfileWidgetState();
}

class _PersonalProfileWidgetState extends State<PersonalProfileWidget> {
  //example pie chart represents task tag data: pomodo, affirmations, blitz, academic, workout, social.
  Map<String, double> dataMap = {
    "Social": 1,
    "Blitz": 1,
    "Academic": 1,
    "Workout": 1,
    "Affirmations": 1,
  };

  String censorString(String input) {
    return input.isEmpty ? input : input[0] + '*' * (input.length - 1);
  }

  get decoration => null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        height: 200,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 48, 112, 76),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.person, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Your Profile', style: TextStyle(color: Colors.white)),
                  Text(
                    'Username: ${widget.username}\nEmail: ${widget.email}\nPassword: ${censorString(widget.password)}\nScore: ${widget.totalHoursScore}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  print('edit button pressed.');
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: 300,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: PieChart(
                chartType: ChartType.ring,
                centerText: "Example Data",
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//friend widget
class FriendsProfileWidget extends StatefulWidget {
  final FriendsClass friend;
  final VoidCallback onDelete;

  const FriendsProfileWidget({
    Key? key,
    required this.friend,
    required this.onDelete,
  }) : super(key: key);

  @override
  _FriendsProfileWidgetState createState() => _FriendsProfileWidgetState();
}

class _FriendsProfileWidgetState extends State<FriendsProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color.fromARGB(255, 48, 112, 76),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            leading: Icon(Icons.person, color: Colors.white),
            title: Text(
              widget.friend.username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Score: ${widget.friend.totalHoursScore}',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.white),
              onPressed: widget.onDelete,
            ),
          ),
        ),
      ),
    );
  }
}
