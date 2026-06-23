import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class HistoryService {

  static const String baseUrl =
      "https://backendai-production-b126.up.railway.app";

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