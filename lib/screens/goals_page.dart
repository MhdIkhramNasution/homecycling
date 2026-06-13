import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import 'dart:io';
import '../services/tflite_service.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'goals_detail_page.dart';
import 'shop_page.dart';
import 'profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'item_scanned_page.dart';
import '../services/goals_service.dart';

class GoalsPage extends StatefulWidget {

  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {

  int ecoPoints = 0;

  String badge = "";

  String nextBadge = "";

  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {

    try {

      final data =
      await GoalsService.getGoals();

      setState(() {

        ecoPoints =
            data["points"] ?? 0;

        if (ecoPoints >= 900) {

          badge = "Eco Champion";

        } else if (ecoPoints >= 500) {

          badge = "Eco Hero";

        } else {

          badge = "Eco Starter";
        }

        nextBadge =
            data["next_badge"] ?? "";

        progress =
            (data["progress"] as num)
                .toDouble();
      });

    } catch (e) {

      print("LOAD GOALS ERROR");
      print(e);
    }
  }

  String getItemImage(String prediction) {

    final fileName = prediction
        .toLowerCase()
        .replaceAll(" ", "_");

    return "assets/images/$fileName.png";
  }

  String getMainBadge() {

    if (ecoPoints >= 900) {
      return "assets/icon/Eco-Champion_Badge.png";
    }

    if (ecoPoints >= 500) {
      return "assets/icon/Eco-Hero_Badge.png";
    }

    return "assets/icon/Eco-Starter_Badge.png";
  }

  String getStarterBadge() {
    return "assets/icon/Eco-Starter_Badge.png";
  }

  String getHeroBadge() {

    if (ecoPoints >= 500) {
      return "assets/icon/Eco-Hero_Badge.png";
    }

    return "assets/icon/Eco-Hero_Badge.png";
  }

  String getChampionBadge() {

    if (ecoPoints >= 1000) {
      return "assets/icon/Eco-Champion_Badge.png";
    }

    return "assets/icon/Eco-Champion_Badge.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    /// ================= BADGE =================
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF74A830), Colors.white],

                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),

                        borderRadius: BorderRadius.circular(20),

                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),

                      child: Column(
                        children: [
                          Image.asset(
                            getMainBadge(),
                            height: 80,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            badge,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// ================= PROGRESS =================
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),

                            child: Stack(
                              children: [
                                Container(height: 15, color: Colors.grey[300]),

                                FractionallySizedBox(
                                  widthFactor: progress,

                                  child: Container(
                                    height: 15,
                                    color: const Color(0xFF577E24),
                                  ),
                                ),

                                Positioned.fill(
                                  child: Center(
                                    child: Text(
                                      "$ecoPoints EXP",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= POINT =================
                    Container(
                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF74A830)),

                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [

                          const Text("Your Points"),

                          Text(
                            ecoPoints.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= BADGE PROGRESSION =================
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GoalsDetailPage(),
                          ),
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF74A830)),

                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "Badge Progression",

                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,

                              children: [
                                badgeItem(
                                  getStarterBadge(),
                                  "Eco-Starter",
                                ),

                                badgeItem(
                                  getHeroBadge(),
                                  "Eco-Hero",
                                ),

                                badgeItem(
                                  getChampionBadge(),
                                  "Eco-Champion",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= REDEEM =================
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ShopPage()),
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF74A830)),

                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: const [
                                Text(
                                  "Redeem Rewards",

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),

                            const SizedBox(height: 5),

                            const Text("Use your points for perks"),

                            const SizedBox(height: 15),

                            Container(
                              width: double.infinity,
                              height: 50,

                              decoration: BoxDecoration(
                                color: const Color(0xFF577E24),

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: const [
                                  Image(
                                    image: AssetImage(
                                      "assets/icon/gift_goals_icon.png",
                                    ),

                                    width: 24,
                                    height: 24,
                                  ),

                                  SizedBox(width: 10),

                                  Text(
                                    "Redeem Rewards",

                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// ================= FLOAT CAMERA =================
      floatingActionButton: Container(
        height: 65,
        width: 65,

        decoration: const BoxDecoration(
          color: Color(0xFF74A830),
          shape: BoxShape.circle,
        ),

        child: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.white),

          onPressed: () async {

            try {

              final picker = ImagePicker();

              final XFile? capturedImage =
              await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 100,
              );

              if (capturedImage != null) {

                print("IMAGE PICKED");

                final result =
                await TFLiteService.predict(
                  File(capturedImage.path),
                );

                print(result);

                final prediction =
                    result["prediction"] ?? "Unknown";

                final imageAsset =
                getItemImage(prediction);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemScannedPage(
                      imagePath: imageAsset,
                      prediction: prediction,
                      confidence:
                      (result["confidence"] ?? 0)
                          .toDouble(),
                    ),
                  ),
                );
              }

            } catch (e) {

              print("PREDICT ERROR");
              print(e);
            }
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// ================= NAVBAR =================
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: SizedBox(
          height: 65,

          child: Row(
            children: [
              navItem(context, "assets/navbar/home.png", "Home", false, 0),

              navItem(
                context,
                "assets/navbar/inventory.png",
                "Inventory",
                false,
                1,
              ),

              const SizedBox(width: 40),

              navItem(context, "assets/navbar/goals.png", "Goals", true, 2),

              navItem(
                context,
                "assets/navbar/profile.png",
                "Profile",
                false,
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= BADGE ITEM =================
  Widget badgeItem(image, title) {
    return Column(
      children: [
        Image.asset(image, height: 50),
        const SizedBox(height: 5),

        Text(title, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  /// ================= NAV =================
  Widget navItem(BuildContext context, icon, title, active, index) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        splashColor: const Color(0xFF74A830).withOpacity(0.2),

        onTap: () {
          if (index == 0 && !active) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1 && !active) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const InventoryPage()),
            );
          } else if (index == 2 && !active) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GoalsPage()),
            );
          } else if (index == 3 && !active) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,

              color: active ? const Color(0xFF74A830) : Colors.black,
            ),

            const SizedBox(height: 5),

            Text(
              title,

              style: TextStyle(
                fontSize: 12,

                color: active ? const Color(0xFF74A830) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}