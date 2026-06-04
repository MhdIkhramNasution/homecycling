import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static const String keyLogin = "isLoggedIn";

  /// ================= LOGIN =================
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLogin, true);
  }

  /// ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(keyLogin, false);

    await prefs.setBool("popupShown", false);
  }

  /// ================= CEK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLogin) ?? false;
  }
  static const String keyUsername = "username";
  static const String keyEmail = "email";
  static const String keyPhone = "phone";
  static const String keyPhoto = "photo";

  /// SAVE PROFILE
  static Future<void> saveProfile({
    required String username,
    required String email,
    required String phone,
    String? photo,
    String password = "",
  }) async {

    final response = await http.post(

      Uri.parse(
        "http://192.168.100.7:8000/update-account",
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "username":
        UserSession.username,

        "new_username":
        username,

        "email":
        email,

        "phone":
        phone,

        "new_password":
        password,
      }),
    );

    if (response.statusCode == 200) {

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        keyUsername,
        username,
      );

      await prefs.setString(
        keyEmail,
        email,
      );

      await prefs.setString(
        keyPhone,
        phone,
      );

      if (photo != null) {

        await prefs.setString(
          keyPhoto,
          photo,
        );
      }

      UserSession.username =
          username;

      UserSession.email =
          email;

      UserSession.phone =
          phone;
    }
  }

  /// GET PROFILE
  static Future<Map<String, dynamic>> getProfile() async {

    final response = await http.get(

      Uri.parse(
        "http://192.168.100.7:8000/profile/${UserSession.username}",
      ),
    );

    final data =
    jsonDecode(response.body);

    final prefs =
    await SharedPreferences.getInstance();

    return {

      "username":
      data["username"] ?? "",

      "email":
      data["email"] ?? "",

      "phone":
      data["phone"] ?? "",

      "photo":
      prefs.getString(keyPhoto) ?? "",
    };
  }
}