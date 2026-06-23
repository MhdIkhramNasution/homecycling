import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class NotificationService {

  static const String baseUrl =
      "https://backendai-production-b126.up.railway.app";

  static Future<List<dynamic>>
  getNotifications() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/notifications/${UserSession.username}",
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