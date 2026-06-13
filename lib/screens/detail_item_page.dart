import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailItemPage extends StatefulWidget {
  final int itemId;
  final String title;
  final String image;
  final int stock;
  final int expiryDays;

  const DetailItemPage({
    super.key,
    required this.itemId,
    required this.title,
    required this.image,
    required this.stock,
    required this.expiryDays,
  });

  @override
  State<DetailItemPage> createState() =>
      _DetailItemPageState();
}

class _DetailItemPageState
    extends State<DetailItemPage> {

  late int stock;

  @override
  void initState() {
    super.initState();
    stock = widget.stock;
  }

  Future<void> reduceStock() async {
    try {
      final response = await http.put(
        Uri.parse(
          "http://192.168.100.7:8000/inventory/reduce-stock/${widget.itemId}",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {
          if (stock > 0) {
            stock--;
          }
        });

        if (stock <= 0 && mounted) {
          Navigator.pop(
            context,
            true,
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

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
                borderRadius:
                BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(20),

              child: widget.image.startsWith("/")
                  ? Image.file(
                File(widget.image),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                widget.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,

                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Image.asset(
                    "assets/images/apple.png",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.symmetric(
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color: widget.expiryDays <= 2
                    ? Colors.redAccent
                    : widget.expiryDays <= 5
                    ? Colors.orange
                    : Colors.green,

                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Center(
                child: Text(
                  "${
                      widget.expiryDays
                  } Days Left",

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: const Color(
                  0xFFF1F4E8,
                ),

                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Expanded(
                    child: Text(
                      widget.title,

                      style:
                      const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    "Stock Available: $stock",

                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF6B8E23,
                  ),

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                onPressed: reduceStock,

                child: const Text(
                  "Reduce Stock  -",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w500,
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