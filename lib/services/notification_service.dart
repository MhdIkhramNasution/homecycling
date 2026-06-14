import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class NotificationService {

  static const String baseUrl =
      "http://192.168.100.7:8000";

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