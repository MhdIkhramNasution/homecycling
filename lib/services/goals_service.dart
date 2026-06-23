import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class GoalsService {

  static const String baseUrl =
      "https://backendai-production-b126.up.railway.app";

  // ================= GOALS =================

  static Future<Map<String, dynamic>>
  getGoals() async {

    final response =
    await http.get(

      Uri.parse(
        "$baseUrl/goals/${UserSession.username}",
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Failed to load goals",
    );
  }

  // ================= BADGES =================

  static Future<List<dynamic>>
  getBadges() async {

    final response =
    await http.get(

      Uri.parse(
        "$baseUrl/badges/${UserSession.username}",
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    return [];
  }
}