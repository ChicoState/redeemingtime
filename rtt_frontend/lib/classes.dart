//Header file for classes...

//Notes...
//goal = goal description
//timeCost = time taken to complete a task, allows quantified goals
//weekDay = day of week mon-sun (1-7)
//completed = allows checkboxing daily tasks and controlled task submissions
//tag = categories that each task can be assigned for later pie chart feature

class GoalsClass {
  //member variables...
  String goal;
  double timeCost;
  int weekDay;
  //int tag;
  bool completed = false;
  //int tag = 0; //0-4 [social, blitz, academic, workout, affirmations]
  //constructor
  GoalsClass({
    required this.goal,
    required this.timeCost,
    required this.weekDay,
  });
}

//Notes...
//username - displays username for friendslist
//totalHoursScore - total hours spent by user on goals
//goalComposition - tags that will help build pie charts for firends list

class FriendsClass {
  String username = '';
  double totalHoursScore = 0;
  List<int> goalComposition = [];
  List<double> weeklyHoursStats = [];
  FriendsClass({
    required this.username,
    required this.totalHoursScore,
    required this.goalComposition,
    required this.weeklyHoursStats,
  });
}

class UserClass {
  //member variables...
  String username;
  String email;
  String password;
  double totalHoursScore = 0;
  List<FriendsClass> friends = [];
  List<String> friendRequests = [];
  List<double> weeklyHoursStats = [];
  List<GoalsClass> weeklyGoals = [];
  UserClass({
    required this.username,
    required this.email,
    required this.password,
    required this.weeklyGoals,
    required this.totalHoursScore,
    required this.weeklyHoursStats,
    required this.friends,
  });
}
