import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class DashboardService {

  static const String baseUrl =
      "http://192.168.100.7:8000";

  static Future<Map<String, dynamic>>
  getDashboardStats() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/dashboard-stats/${UserSession.username}",
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Failed to load dashboard stats",
    );
  }
}