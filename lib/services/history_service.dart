import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class HistoryService {

  static const String baseUrl =
      "http://192.168.100.7:8000";

  static Future<List<dynamic>>
  getHistory() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/history/${UserSession.username}",
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