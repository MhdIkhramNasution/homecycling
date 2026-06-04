import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {

  static Future<Map<String, dynamic>>
  getProfile(String username) async {

    final response = await http.get(

      Uri.parse(
        "http://192.168.100.7:8000/profile/$username",
      ),
    );

    return jsonDecode(response.body);
  }
}