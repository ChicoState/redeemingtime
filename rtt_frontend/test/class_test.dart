// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:test/test.dart';
import '../lib/classes.dart';

void main() {
  group('UserClass Init', () {
    test('should initialize with proper values and empty friendRequests', () {
      final user = UserClass(
        username: 'christian',
        email: 'christian@example.com',
        password: 'password',
        totalHoursScore: 5.0,
        friends: [
          FriendsClass(
            username: 'jesus',
            totalHoursScore: 3.0,
            goalComposition: [1, 2],
            weeklyHoursStats: [1.0, 1.5],
          ),
        ],
        weeklyGoals: [
          GoalsClass(goal: 'walk', timeCost: 2.0, weekDay: 1, tag: 2),
        ],
        weeklyHoursStats: [2.0, 1.0],
      );

      expect(user.username, equals('christian'));
      expect(user.friends.length, equals(1));
      expect(user.friends[0].username, equals('jesus'));
      expect(user.weeklyGoals[0].goal, equals('walk'));
      expect(user.weeklyGoals[0].completed, isFalse);
      expect(user.friendRequests, isEmpty);
    });

    test('should add friend', () {
      final user = UserClass(
        username: 'trevor',
        email: 'trevor@example.com',
        password: 'password',
        totalHoursScore: 0.0,
        friends: [],
        weeklyGoals: [],
        weeklyHoursStats: [],
      );

      user.friendRequests.add('jesus');
      expect(user.friendRequests.length, equals(1));
      expect(user.friendRequests.first, equals('jesus'));
    });
  });

  group('GoalsClass Init', () {
    test('should default completed to false', () {
      final goal = GoalsClass(
        goal: 'workout',
        timeCost: 1.5,
        weekDay: 3,
        tag: 3,
      );

      expect(goal.completed, isFalse);
      expect(goal.goal, equals('workout'));
      expect(goal.weekDay, equals(3));
    });

    test('goal can be true', () {
      final goal = GoalsClass(
        goal: 'leetcode',
        timeCost: 0.5,
        weekDay: 0,
        tag: 4,
        completed: true,
      );

      expect(goal.completed, true);
    });
  });

  group('FriendsClass Init', () {
    test('checks all fields of FriendsClass', () {
      final friend = FriendsClass(
        username: 'jesus',
        totalHoursScore: 8.0,
        goalComposition: [0, 1, 2],
        weeklyHoursStats: [1.0, 2.0, 3.0],
      );

      expect(friend.username, equals('jesus'));
      expect(friend.goalComposition.length, equals(3));
      expect(friend.weeklyHoursStats[2], equals(3.0));
    });
  });
}
