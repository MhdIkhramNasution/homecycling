import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';

class VoucherDetailPage extends StatelessWidget {
  final int voucherId;
  final String title;
  final String image;
  final int points;

  const VoucherDetailPage({
    super.key,
    required this.voucherId,
    required this.title,
    required this.image,
    required this.points,
  });

  Future<void> redeemVoucher(
      BuildContext context,
      ) async {

    try {

      final response = await http.post(

        Uri.parse(
          "http://192.168.100.7:8000/redeem-voucher",
        ),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "username":
          UserSession.username,

          "voucher_id":
          voucherId,
        }),
      );

      final data =
      jsonDecode(response.body);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(

            data["message"] ??
                data["status"],
          ),
        ),
      );

    } catch (e) {

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Builder(
                builder: (context) {

                  print("IMAGE PATH = $image");

                  return Image.asset(
                    image,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            /// SUB INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Special Discount",
                  style: TextStyle(color: Color(0xFF74A830)),
                ),
                Text(
                  "Valid Until 1 Jan 2027",
                  style: TextStyle(color: Color(0xFF74A830)),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// ================= VOUCHER CODE =================
            Center(
              child: Column(
                children: [

                  const Text(
                    "Voucher Code",
                    style: TextStyle(
                      color: Color(0xFF74A830),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF74A830)),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        "F O 5 N 3 M",
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= HOW TO USE =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF74A830)),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "How to Use",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  rowCheck("Use during checkout"),
                  rowCheck("Valid before expiration"),
                  rowCheck("One-time using only"),

                  const Divider(height: 25),

                  const Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  rowDot("Not exchangeable for cash"),
                  rowDot("Cannot be combined with other promotions"),

                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFF577E24),

                  foregroundColor:
                  Colors.white,
                ),

                onPressed: () {

                  redeemVoucher(
                    context,
                  );
                },

                child: Text(
                  "Redeem ($points pts)",
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// CHECK ITEM
  Widget rowCheck(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF74A830), size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  /// DOT ITEM
  Widget rowDot(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF74A830)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}