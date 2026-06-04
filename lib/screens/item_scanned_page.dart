import 'dart:io';
import 'package:flutter/material.dart';
import 'inventory_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/user_session.dart';

class ItemScannedPage extends StatelessWidget {

  final String imagePath;
  final String prediction;
  final double confidence;

  const ItemScannedPage({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.confidence,
  });

  /// ================= AUTO IMAGE =================
  String getItemImage(String prediction) {

    final fileName = prediction
        .toLowerCase()
        .replaceAll(" ", "_");

    return "assets/images/$fileName.png";
  }

  @override
  Widget build(BuildContext context) {

    String description = "";

    /// ================= AUTO DESCRIPTION =================
    if (prediction.toLowerCase() == "banana") {

      description =
      "Bananas are a healthy fruit rich in potassium, vitamin B6, vitamin C, and fiber, which help support heart health, digestion, and provide quick energy.";

    } else if (prediction.toLowerCase() == "apple") {

      description =
      "Apples are nutritious fruits rich in antioxidants and fiber that help improve digestion and maintain heart health.";

    } else if (prediction.toLowerCase() == "broccoli") {

      description =
      "Broccoli contains vitamins K and C, antioxidants, and fiber that are beneficial for immunity and overall health.";

    } else if (prediction.toLowerCase() == "carrot") {

      description =
      "Carrots are rich in beta carotene and vitamin A, which are important for eye health and immunity.";

    } else {

      description =
      "This food item was detected using AI image recognition.";
    }

    /// ================= AUTO ASSET =================
    final inventoryImage = getItemImage(prediction);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF76A82A),
        elevation: 0,
        toolbarHeight: 55,
        automaticallyImplyLeading: false,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),

      /// ================= BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),

            child: Column(
              children: [

                /// ================= IMAGE =================
                Container(
                  width: double.infinity,
                  height: 190,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.grey.shade300,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),

                    child: imagePath.startsWith("assets/")
                        ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// ================= AI RESULT =================
                Text(
                  prediction,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF76A82A),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    "Confidence ${(confidence * 100).toStringAsFixed(0)}%",

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// ================= DESCRIPTION =================
                Text(
                  description,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.7,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 28),

                /// ================= ADD BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    onPressed: () async {
                      print(UserSession.username);

                      final response = await http.post(

                        Uri.parse(
                            "http://192.168.100.7:8000/inventory/add"
                        ),

                        headers: {
                          "Content-Type": "application/json",
                        },

                        body: jsonEncode({

                          "username": UserSession.username,

                          "item_name": prediction,

                          "image": inventoryImage,

                          "expiry_days": 5,

                          "status": "Fresh",
                        }),
                      );
                      print(response.body);

                      final data = jsonDecode(response.body);

                      if (data["status"] == "success") {

                        ScaffoldMessenger.of(context).showSnackBar(

                          const SnackBar(
                            content: Text(
                              "Added to inventory",
                            ),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const InventoryPage(),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF76A82A),
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      "Add to Inventory",

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// ================= CANCEL BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF76A82A),
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      "Cancel",

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}