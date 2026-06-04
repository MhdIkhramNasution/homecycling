import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/user_session.dart';

class GoalsService {

  static Future<Map<String, dynamic>>
  getGoals() async {

    final response = await http.get(

      Uri.parse(
        "http://192.168.100.7:8000/goals/${UserSession.username}",
      ),
    );

    return jsonDecode(response.body);
  }
}