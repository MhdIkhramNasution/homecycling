import 'dart:convert';
import 'package:http/http.dart' as http;

class VoucherService {

  static const String baseUrl =
      "http://192.168.100.7:8000";

  /// ================= GET ALL VOUCHERS =================

  static Future<List<dynamic>> getVouchers() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/vouchers",
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Failed to load vouchers",
    );
  }
}