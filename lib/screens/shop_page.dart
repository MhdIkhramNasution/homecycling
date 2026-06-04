import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import 'package:flutter/material.dart';
import 'buy_voucher_page.dart';
import 'goals_page.dart';
import 'reedem_history_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {

  Future<void> redeemReward(
      BuildContext context,
      String rewardName,
      int pointsRequired,
      ) async {

    try {

      final response = await http.post(

        Uri.parse(
          "http://192.168.100.7:8000/redeem",
        ),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "username":
          UserSession.username,

          "reward_name":
          rewardName,

          "points_required":
          pointsRequired,
        }),
      );

      final data =
      jsonDecode(response.body);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            data["message"],
          ),
        ),
      );

    } catch (e) {

      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GoalsPage()),
            );
          },
        ),
      ),

      body: Column(
        children: [
          /// ================= TOP SECTION =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                chip("10.000 Points", false, context),
                chip("Redeem History", true, context),
              ],
            ),
          ),

          /// ================= VOUCHER LIST (SCROLL ONLY HERE) =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                voucherItem(
                  context,
                  "Voucher Rp5.000",
                  "Discount voucher Rp5.000",
                  "50",
                ),

                voucherItem(
                  context,
                  "Voucher Rp10.000",
                  "Discount voucher Rp10.000",
                  "100",
                ),

                voucherItem(
                  context,
                  "Voucher Rp20.000",
                  "Discount voucher Rp20.000",
                  "200",
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          /// ================= FIXED FOOTER =================
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4E4BF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Minimize expired food to earn Eco-Points.\nIf food expires without being consumed, Eco-Points will decrease.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= CHIP =================
  Widget chip(String text, bool isHistory, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isHistory) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RedeemHistoryPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isHistory ? const Color(0xFF577E24) : Colors.transparent,
          border: Border.all(color: const Color(0xFF74A830)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (isHistory)
              const Image(
                image: AssetImage("assets/icon/reedem_history_icon.png"),
                width: 16,
                height: 16,
                color: Colors.white,
              ),
            if (isHistory) const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(color: isHistory ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= VOUCHER =================
  Widget voucherItem(
    BuildContext context,
    String title,
    String desc,
    String price,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF74A830)),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(price),
            ],
          ),

          const SizedBox(height: 8),

          Text(desc, style: const TextStyle(fontSize: 12)),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF577E24),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {

                redeemReward(
                  context,
                  title,
                  int.parse(
                    price.replaceAll(".", ""),
                  ),
                );
              },
              child: const Text("Buy Now"),
            ),
          ),
        ],
      ),
    );
  }
}
