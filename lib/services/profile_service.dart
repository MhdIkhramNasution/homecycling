import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {

  static Future<Map<String, dynamic>>
  getProfile(String username) async {

    final response = await http.get(

      Uri.parse(
        "https://backendai-production-b126.up.railway.app/profile/$username",
      ),
    );

    return jsonDecode(response.body);
  }
}