import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class DashboardService {

  static const String baseUrl =
      "https://backendai-production-b126.up.railway.app";

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