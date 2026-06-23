import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class RedeemHistoryService {

  static const String baseUrl =
      "https://backendai-production-b126.up.railway.app";

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