import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import 'package:flutter/material.dart';
import '../services/voucher_service.dart';
import 'goals_page.dart';
import 'reedem_history_page.dart';
import 'buy_voucher_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {

  List<dynamic> vouchers = [];

  bool isLoading = true;

  int userPoints = 0;

  Future<void> loadVouchers() async {

    try {

      final data =
      await VoucherService.getVouchers();

      setState(() {

        vouchers = data;

        isLoading = false;
      });

    } catch (e) {

      print(e);

      setState(() {

        isLoading = false;
      });
    }
  }

  Future<void> loadUserPoints() async {

    try {

      final response = await http.get(

        Uri.parse(
          "https://backendai-production-b126.up.railway.app/${UserSession.username}",
        ),
      );

      final data =
      jsonDecode(response.body);

      setState(() {

        userPoints =
            data["points"] ?? 0;
      });

    } catch (e) {

      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    loadVouchers();

    loadUserPoints();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const GoalsPage(),
              ),
            );
          },
        ),
      ),

      body: Column(
        children: [

          /// TOP SECTION
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [

                chip(
                  "$userPoints Points",
                  false,
                  context,
                ),

                chip(
                  "Redeem History",
                  true,
                  context,
                ),
              ],
            ),
          ),

          /// LIST VOUCHER
          Expanded(
            child: isLoading

                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                : ListView.builder(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              itemCount:
              vouchers.length,

              itemBuilder:
                  (context, index) {

                final voucher =
                vouchers[index];

                return voucherItem(
                  context,
                  voucher,
                );
              },
            ),
          ),

          /// FOOTER
          Container(
            margin:
            const EdgeInsets.all(15),

            padding:
            const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color:
              const Color(0xFFD4E4BF),

              borderRadius:
              BorderRadius.circular(12),
            ),

            child: const Text(
              "Minimize expired food to earn Eco-Points.\nIf food expires without being consumed, Eco-Points will decrease.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CHIP
  Widget chip(
      String text,
      bool isHistory,
      BuildContext context,
      ) {

    return GestureDetector(
      onTap: () {

        if (isHistory) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const RedeemHistoryPage(),
            ),
          );
        }
      },

      child: Container(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: isHistory
              ? const Color(0xFF577E24)
              : Colors.transparent,

          border: Border.all(
            color:
            const Color(0xFF74A830),
          ),

          borderRadius:
          BorderRadius.circular(20),
        ),

        child: Row(
          children: [

            if (isHistory)
              const Image(
                image: AssetImage(
                  "assets/icon/reedem_history_icon.png",
                ),
                width: 16,
                height: 16,
                color: Colors.white,
              ),

            if (isHistory)
              const SizedBox(width: 5),

            Text(
              text,
              style: TextStyle(
                color: isHistory
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// VOUCHER ITEM
  Widget voucherItem(
      BuildContext context,
      dynamic voucher,
      ) {

    final title =
    voucher["title"];

    final desc =
    voucher["description"];

    final points =
    voucher["points"];

    final voucherId =
    voucher["voucher_id"];

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const EdgeInsets.all(15),

      decoration: BoxDecoration(

        border: Border.all(
          color:
          const Color(0xFF74A830),
        ),

        borderRadius:
        BorderRadius.circular(15),

        color: Colors.white,

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              Text(
                title,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              Text(
                "$points Pts",
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment:
            Alignment.centerRight,

            child: ElevatedButton(

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF577E24),

                foregroundColor:
                Colors.white,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyVoucherPage(
                      voucherId: voucherId,
                      title: title,
                      points: points,
                      image: "assets/images/${voucher["image"]}",
                    ),
                  ),
                );
              },

              child:
              const Text("Buy Now"),
            ),
          ),
        ],
      ),
    );
  }
}