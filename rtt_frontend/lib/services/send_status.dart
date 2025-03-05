/*import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class sendTo {
  final String baseUrl = "http://your-backend-url.com/api"; //discover this

  Future<bool> shareStatus(List<String?> goals, List<String?> usernames) async {
  
  if(goals != null or usernames != null)


  final response = await http.post(
    Uri.parse('$baseUrl/items'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'quantity': quantity}),
  );
  return response.statusCode == 201;
  }
}*/