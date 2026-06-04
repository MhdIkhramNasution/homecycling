import 'dart:io';
import '../services/tflite_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'goals_page.dart';
import 'edit_profile_page.dart';
import 'terms_page.dart';
import 'privacy_page.dart';
import 'welcome_screen.dart';
import 'item_scanned_page.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String getItemImage(String prediction) {

    final fileName = prediction
        .toLowerCase()
        .replaceAll(" ", "_");

    return "assets/images/$fileName.png";
  }

  String username = UserSession.username;
  String? photoPath;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await AuthService.getProfile();

    setState(() {
      username = data["username"]!;
      photoPath = data["photo"];
    });
  }

  /// ================= CAMERA =================
  Future<void> openCamera() async {

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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    /// ================= PROFILE PHOTO =================
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF74A830),

                      backgroundImage:
                          photoPath != null && photoPath!.isNotEmpty
                          ? FileImage(File(photoPath!))
                          : null,

                      child: (photoPath == null || photoPath!.isEmpty)
                          ? Image.asset(
                              "assets/icon/profile_icon.png",
                              width: 40,
                            )
                          : null,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      username,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      UserSession.email,

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      UserSession.phone,

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    menuItem(
                      context,
                      "assets/icon/profile_icon.png",
                      "Account",
                      const Color(0xFF74A830),

                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );

                        loadProfile();
                      },
                    ),

                    menuItem(
                      context,
                      "assets/icon/term_and_condition_icon.png",
                      "Terms and Condition",
                      const Color(0xFF74A830),

                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsPage()),
                        );
                      },
                    ),

                    menuItem(
                      context,
                      "assets/icon/privacy_policy_icon.png",
                      "Privacy Policy",
                      Colors.red,

                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    const Align(
                      alignment: Alignment.centerLeft,

                      child: Text("Stay in touch"),
                    ),

                    const SizedBox(height: 10),

                    menuItem(
                      context,
                      "assets/icon/send_feedback_icon.png",
                      "Send Feedback",
                      Colors.purple,

                      () {},
                    ),

                    const SizedBox(height: 10),

                    menuItem(
                      context,
                      "assets/icon/sign_out_icon.png",
                      "Sign Out",
                      Colors.red,

                      () {
                        showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// ================= FLOAT CAMERA =================
      floatingActionButton: GestureDetector(
        onTap: openCamera,

        child: Container(
          height: 65,
          width: 65,

          decoration: const BoxDecoration(
            color: Color(0xFF74A830),
            shape: BoxShape.circle,
          ),

          child: const Icon(Icons.camera_alt, color: Colors.white),
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

              navItem(context, "assets/navbar/goals.png", "Goals", false, 2),

              navItem(context, "assets/navbar/profile.png", "Profile", true, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    String icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      child: Material(
        color: color.withOpacity(0.15),

        borderRadius: BorderRadius.circular(30),

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(30),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),

                  child: Center(
                    child: Image.asset(icon, width: 20, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 15),

                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Logout"),

        content: const Text("Are you sure want to log out?"),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {
              await AuthService.logout();

              Navigator.pushAndRemoveUntil(
                context,

                MaterialPageRoute(builder: (_) => const WelcomeScreen()),

                (route) => false,
              );
            },

            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Widget navItem(BuildContext context, icon, title, active, index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const InventoryPage()),
            );
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const GoalsPage()),
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
