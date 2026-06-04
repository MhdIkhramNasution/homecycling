import 'package:flutter/material.dart';


class ExpiringPopup extends StatelessWidget {
  const ExpiringPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// HEADER IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/header_image_popup.png",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 15),

            /// TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Expiring Soon",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "The following archive entries are nearing their peak freshness. Actions recommended to minimize waste.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            /// ITEM 1
            item(
              "assets/icon/organic_milk_icon.png",
              "Organic Milk",
              "EXPIRES TODAY",
              Colors.red,
            ),

            const SizedBox(height: 10),

            /// ITEM 2
            item(
              "assets/icon/baby_spinach_icon.png",
              "Baby Spinach",
              "1 DAY LEFT",
              Colors.orange,
            ),

            const SizedBox(height: 20),

            /// BUTTON VIEW ALL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF577E24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// DISMISS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Dismiss",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget item(String icon, String title, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE5F0DA),
              shape: BoxShape.circle,
            ),
            child: Image.asset(icon, width: 20),
          ),

          const SizedBox(width: 10),

          /// TEXT
          Expanded(
            child: Text(title),
          ),

          /// STATUS
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}