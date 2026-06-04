import 'package:flutter/material.dart';
import 'shop_page.dart';
import 'voucher_detail_page.dart';

class RedeemHistoryPage extends StatelessWidget {
  const RedeemHistoryPage({super.key});

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

            /// ================= FILTER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filterChip("All", true),
                filterChip("Available", false),
                filterChip("Used", false),
                filterChip("Expired", false),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= SUMMARY =================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF74A830)),
                borderRadius: BorderRadius.circular(20),
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
                      const Text("Total Vouchers Redeemed: 4"),
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
                      const Text("Eco-Points Spent: 4.000"),
                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= LIST =================
            Expanded(
              child: ListView(
                children: [

                  voucherItem(
                    context,
                    "assets/images/voucher_a_images.png",
                    "Voucher A",
                    "1 January 2026",
                    "Expires 2027",
                    "Used",
                    const Color(0xFF577E24),
                    "assets/images/voucher_a_full_images.png", // 🔥 detail image
                  ),

                  voucherItem(
                    context,
                    "assets/images/voucher_b_images.png",
                    "Voucher B",
                    "1 March 2026",
                    "Expires 2027",
                    "Available",
                    const Color(0xFF74A830),
                    "assets/images/voucher_b_full_images.png",
                  ),

                  voucherItem(
                    context,
                    "assets/images/voucher_c_images.png",
                    "Voucher C",
                    "1 February 2026",
                    "Expires 2027",
                    "Expired",
                    Colors.red,
                    "assets/images/voucher_c_full_images.png",
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  /// ================= FILTER CHIP =================
  Widget filterChip(String text, bool active) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF74A830) : Colors.transparent,
          border: Border.all(color: const Color(0xFF74A830)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= VOUCHER ITEM =================
  Widget voucherItem(
      BuildContext context,
      String image,
      String title,
      String date,
      String expire,
      String status,
      Color statusColor,
      String detailImage,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VoucherDetailPage(
              title: title,
              image: detailImage,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF74A830)),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Row(
          children: [

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 10),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(date, style: const TextStyle(fontSize: 12)),
                  Text(expire, style: const TextStyle(fontSize: 12)),

                ],
              ),
            ),

            /// STATUS + POINT
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10),
                  ),
                ),

                const SizedBox(height: 10),

                const Text("1.000 Pts", style: TextStyle(fontSize: 12)),

              ],
            )

          ],
        ),
      ),
    );
  }
}