import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://your-backend-url.com/api';
}

//Eventual json formatting...
/*
{
  "date": "2025-03-06",
  "username": Christian-U,
  "friends": [
    {
      "username": Trevor-S,
      "phonenumber": ***-***-****,
      "goals": [
        { "goal_id": 1, "title": "Morning workout", "completed_at": "07:30 AM" },
        { "goal_id": 2, "title": "Read 10 pages", "completed_at": "09:15 AM" }
      ]
    },
    {
      "username": Jesus-V,
      "phonenumber": "Bob",
      "goals": [
        { "goal_id": 1, "title": "Morning workout", "completed_at": "07:30 AM" },
        { "goal_id": 2, "title": "Read 10 pages", "completed_at": "09:15 AM" }
      ]
    }
  ]
}
*/
