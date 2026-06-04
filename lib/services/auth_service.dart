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
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(keyUsername, username);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyPhone, phone);

    if (photo != null) {
      await prefs.setString(keyPhoto, photo);
    }
  }

  /// GET PROFILE
  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "username": prefs.getString(keyUsername) ?? "Username",
      "email": prefs.getString(keyEmail) ?? "-",
      "phone": prefs.getString(keyPhone) ?? "-",
      "photo": prefs.getString(keyPhoto) ?? "",
    };
  }
}