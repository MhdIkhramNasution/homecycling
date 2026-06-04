import 'dart:io';
import 'package:flutter/material.dart';

class DetailItemPage extends StatelessWidget {
  final String title;
  final String image;

  const DetailItemPage({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 70,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: image.startsWith("/")
                  ? Image.file(
                      File(image),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),

              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Center(
                child: Text(
                  "2 Days Left",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),

              decoration: BoxDecoration(
                color: const Color(0xFFF1F4E8),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "Stock Available: 3",

                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Reduce Stock    -",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
