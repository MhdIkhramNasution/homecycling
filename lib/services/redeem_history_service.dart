import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class RedeemHistoryService {

  static const String baseUrl =
      "http://192.168.100.7:8000";

  static Future<List<dynamic>>
  getRedeemHistory() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/redeem-history/${UserSession.username}",
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Failed to load history",
    );
  }
}