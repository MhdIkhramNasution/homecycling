import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import 'shop_page.dart';
import 'voucher_detail_page.dart';

class RedeemHistoryPage extends StatefulWidget {
  const RedeemHistoryPage({super.key});

  @override
  State<RedeemHistoryPage> createState() =>
      _RedeemHistoryPageState();
}

class _RedeemHistoryPageState
    extends State<RedeemHistoryPage> {

  List<dynamic> rewards = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRewardHistory();
  }

  Future<void> loadRewardHistory() async {

    try {

      final response = await http.get(

        Uri.parse(
            "https://backendai-production-b126.up.railway.app/redeem-history/${UserSession.username}"
        ),
      );

      print(response.body);

      final data =
      jsonDecode(response.body);

      setState(() {

        rewards = data;
        isLoading = false;
      });

    } catch (e) {

      print("LOAD REWARD ERROR");
      print(e);

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(

        backgroundColor: const Color(0xFF74A830),

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(
                builder: (_) => const ShopPage(),
              ),
            );
          },
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            /// FILTER
            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                filterChip("All", true),

                filterChip("Available", false),

                filterChip("Used", false),

                filterChip("Expired", false),
              ],
            ),

            const SizedBox(height: 20),

            /// SUMMARY
            Container(

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(

                border: Border.all(
                  color: const Color(0xFF74A830),
                ),

                borderRadius:
                BorderRadius.circular(20),

                color: Colors.white,
              ),

              child: Column(

                children: [

                  Row(

                    children: [

                      Image.asset(
                        "assets/icon/mdi_voucher.png",
                        width: 30,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "Total Vouchers Redeemed: ${rewards.length}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(

                    children: [

                      Image.asset(
                        "assets/icon/icon_leaf_voucher.png",
                        width: 30,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "Eco-Points Spent: ${calculateTotalPoints()}",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST HISTORY
            Expanded(
              child: isLoading
                  ? const Center(
                child:
                CircularProgressIndicator(),
              )
                  : rewards.isEmpty
                  ? const Center(
                child: Text(
                  "No redeem history yet",
                ),
              )
                  : ListView.builder(
                itemCount:
                rewards.length,
                itemBuilder:
                    (context, index) {
                  final reward =
                  rewards[index];
                  return voucherItem(

                    context,

                    reward["voucher_id"],

                    "assets/images/voucher_a_images.png",

                    reward["voucher_name"].toString(),

                    reward["redeemed_at"]
                        .toString()
                        .split(" ")
                        .first,

                    "Redeemed",

                    reward["status"].toString(),

                    reward["status"] == "available"
                        ? const Color(0xFF577E24)
                        : Colors.grey,

                    "assets/images/voucher_a_full_images.png",

                    reward["points_used"].toString(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int calculateTotalPoints() {

    int total = 0;

    for (var reward in rewards) {

      total += int.tryParse(
        reward["points_used"]
            .toString(),
      ) ??
          0;
    }

    return total;
  }

  Widget filterChip(
      String text,
      bool active,
      ) {

    return Expanded(

      child: Container(

        margin: const EdgeInsets.symmetric(
          horizontal: 3,
        ),

        padding:
        const EdgeInsets.symmetric(
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: active
              ? const Color(0xFF74A830)
              : Colors.transparent,

          border: Border.all(
            color: const Color(
              0xFF74A830,
            ),
          ),

          borderRadius:
          BorderRadius.circular(10),
        ),

        child: Center(

          child: Text(

            text,

            style: TextStyle(

              color: active
                  ? Colors.white
                  : Colors.black,

              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget voucherItem(

      BuildContext context,

      int voucherId,

      String image,

      String title,

      String date,

      String expire,

      String status,

      Color statusColor,

      String detailImage,

      String points
      ) {

    return GestureDetector(

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VoucherDetailPage(

              voucherId: voucherId,

              title: title,

              image: detailImage,

              points: int.tryParse(points) ?? 0,
            ),
          ),
        );
      },

      child: Container(

        margin: const EdgeInsets.only(
          bottom: 15,
        ),

        padding: const EdgeInsets.all(
          10,
        ),

        decoration: BoxDecoration(

          border: Border.all(
            color: const Color(
              0xFF74A830,
            ),
          ),

          borderRadius:
          BorderRadius.circular(20),

          color: Colors.white,
        ),

        child: Row(

          children: [

            ClipRRect(

              borderRadius:
              BorderRadius.circular(10),

              child: Image.asset(

                image,

                width: 70,

                height: 70,

                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    title,

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  Text(
                    date,
                    style:
                    const TextStyle(
                      fontSize: 12,
                    ),
                  ),

                  Text(
                    expire,
                    style:
                    const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Column(

              crossAxisAlignment:
              CrossAxisAlignment.end,

              children: [

                Container(

                  padding:
                  const EdgeInsets.symmetric(

                    horizontal: 10,

                    vertical: 5,
                  ),

                  decoration: BoxDecoration(

                    color: statusColor,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(

                    status,

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontSize: 10,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  "$points Pts",
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}