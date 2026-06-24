import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/websocket_service.dart';
import 'inventory_page.dart';
import 'goals_page.dart';
import 'profile_page.dart';
import 'popup_expiring.dart';
import 'item_scanned_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/tflite_service.dart';
import '../services/dashboard_service.dart';
import '../services/history_service.dart';
import 'package:homecycling/screens/notification_page.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "Username";
  String photo = "";
  int totalItems = 0;
  List<dynamic> historyList = [];
  int notificationCount = 0;
  int freshItems = 0;
  int almostExpiredItems = 0;
  int expiredItems = 0;
  int ecoPoints = 0;
  int badgeCount = 0;

  double progressValue = 0;

  String badgeImage =
      "assets/icon/Eco-Starter_Badge.png";
  String getItemImage(String prediction) {

    final fileName = prediction
        .toLowerCase()
        .replaceAll(" ", "_");

    return "assets/images/$fileName.png";
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    loadProfile();
    loadDashboard();
    loadHistory();
    loadNotificationCount();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPopup();
    });
  }

  /// ================= LOAD PROFILE =================
  Future<void> loadProfile() async {

    final data =
    await AuthService.getProfile();

    setState(() {

      username =
      data["username"]!;

      photo =
      data["photo"]!;
    });

    // ================= WEBSOCKET =================

    WebSocketService.connect(

      username,

          (notification) {

        if (!mounted) return;

        showDialog(

          context: context,

          builder: (_) => ExpiringPopup(
            notifications: [
              notification,
            ],
          ),
        );
      },
    );
  }

  ///================== LOAD DASHBOARD ==============
  Future<void> loadDashboard() async {

    try {

      final data =
      await DashboardService
          .getDashboardStats();

      setState(() {

        totalItems =
            data["total_items"] ?? 0;

        freshItems =
            data["fresh"] ?? 0;

        almostExpiredItems =
            data["almost_expired"] ?? 0;

        expiredItems =
            data["expired"] ?? 0;

        ecoPoints =
            data["points"] ?? 0;

        badgeCount =
            data["badges"] ?? 0;

        // ================= BADGE =================

        if (ecoPoints >= 150) {

          badgeImage =
          "assets/icon/Eco-Champion_Badge.png";

          progressValue =
              (ecoPoints / 300)
                  .clamp(0.0, 1.0);

        } else if (ecoPoints >= 50) {

          badgeImage =
          "assets/icon/Eco-Hero_Badge.png";

          progressValue =
              (ecoPoints / 150)
                  .clamp(0.0, 1.0);

        } else {

          badgeImage =
          "assets/icon/Eco-Starter_Badge.png";

          progressValue =
              (ecoPoints / 50)
                  .clamp(0.0, 1.0);
        }
      });

    } catch (e) {

      print(e);
    }
  }

  ///================== LOAD HISTORY ==============

  Future<void> loadHistory() async {

    try {

      final data =
      await HistoryService
          .getHistory();

      setState(() {

        historyList = data;
      });

    } catch (e) {

      print(e);
    }
  }

  ///================== LOAD NOTIFICATION ==============
  Future<void> loadNotificationCount() async {

    try {

      final data =
      await NotificationService
          .getNotifications();

      setState(() {

        notificationCount =
            data.length;
      });

    } catch (e) {

      print(e);
    }
  }

  /// ================= UPLOAD IMAGE TO AI =================
  Future<void> uploadImage(String imagePath) async {
    print("UPLOAD IMAGE CALLED");

    final result = await TFLiteService.predict(
      File(imagePath),
    );

    String prediction =
        result["prediction"] ?? "Unknown";

    double confidence =
    (result["confidence"] ?? 0).toDouble();

    await http.post(

      Uri.parse(
        "https://backendai-production-b126.up.railway.app/scan/save",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({

        "username":
        UserSession.username,

        "image":
        imagePath,

        "prediction":
        prediction,

        "confidence":
        confidence.toString(),
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Prediction: $prediction (${(confidence * 100).toStringAsFixed(0)}%)",
        ),
      ),
    );
  }

  /// ================= OPEN CAMERA =================
  Future<void> openCamera() async {

    try {

      final picker = ImagePicker();

      final XFile? capturedImage =
      await picker.pickImage(
        source: ImageSource.camera,
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

  /// ================= POPUP CONTROL =================
  void checkPopup() async {

    final prefs =
    await SharedPreferences.getInstance();

    bool alreadyShown =
        prefs.getBool("popupShown") ?? false;

    if (alreadyShown) return;

    try {

      final notifications =
      await NotificationService
          .getNotifications();

      if (notifications.isEmpty) {
        return;
      }

      if (!mounted) return;

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      showDialog(

        context: context,

        barrierDismissible: false,

        builder: (_) => ExpiringPopup(
          notifications: notifications,
        ),
      );

      await prefs.setBool(
        "popupShown",
        true,
      );

    } catch (e) {

      print(
        "Popup Error: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF74A830)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          Row(

                            children: [

                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey,

                                backgroundImage:
                                photo.isNotEmpty
                                    ? FileImage(
                                  File(photo),
                                )
                                    : null,

                                child: photo.isEmpty
                                    ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                )
                                    : null,
                              ),

                              const SizedBox(width: 10),

                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    "Hi! $username",

                                    style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),

                                  const Text(
                                    "11 March 2026",
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Stack(
                            children: [

                              IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Color(0xFF74A830),
                                  size: 28,
                                ),

                                onPressed: () async {

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const NotificationPage(),
                                    ),
                                  );

                                  loadNotificationCount();
                                },
                              ),

                              if (notificationCount > 0)

                                Positioned(
                                  right: 8,
                                  top: 8,

                                  child: Container(
                                    padding:
                                    const EdgeInsets.all(4),

                                    decoration:
                                    const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),

                                    child: Text(
                                      notificationCount
                                          .toString(),

                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      const Text("Level Up"),

                      const SizedBox(height: 8),

                      /// ================= PROGRESS BAR =================
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GoalsPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 20,
                                      color: const Color(0xFFD7C9C9),
                                    ),

                                    FractionallySizedBox(
                                      widthFactor: progressValue,
                                      child: Container(
                                        height: 20,
                                        color: const Color(0xFF5E7D1E),
                                      ),
                                    ),

                                    Positioned.fill(
                                      child: Center(
                                        child: Text(
                                          "$ecoPoints Points",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Image.asset(
                              badgeImage,
                              width: 40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= GREEN CARD =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF577E24),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Let’s Reduce Food Waste Today",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Scan groceries, manage your food inventory.",
                      style: TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: openCamera,
                      child: const Text("Start Scanning"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= MENU =================
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InventoryPage(),
                          ),
                        );
                      },
                      child: menuCard(
                        "assets/icon/inventory_dashboard.png",
                        "Inventory",
                        "$totalItems Items Stored",
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GoalsPage()),
                        );
                      },
                      child: menuCard(
                        "assets/icon/eco_point_dashboard.png",
                        "Eco Points",
                        "$ecoPoints Points",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ================= HISTORY =================
              const Text(
                "Recent History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              historyList.isEmpty

                  ? const Padding(
                padding: EdgeInsets.all(20),

                child: Center(
                  child: Text(
                    "No recent activity",
                  ),
                ),
              )

                  : ListView.builder(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemCount: historyList.length,

                itemBuilder: (context, index) {

                  final item =
                  historyList[index];

                  return historyItem(

                    "assets/icon/chest_dashboard.png",

                    item["activity"],

                    item["time"],
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      /// ================= FLOAT CAMERA =================
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF74A830),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: openCamera,
          icon: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 30,
          ),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(context, "assets/navbar/home.png", "Home", true, 0),

              navItem(
                context,
                "assets/navbar/inventory.png",
                "Inventory",
                false,
                1,
              ),

              const SizedBox(width: 40),

              navItem(context, "assets/navbar/goals.png", "Goals", false, 2),

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

  Widget menuCard(icon, title, subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Image.asset(icon, width: 40),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget historyItem(icon, title, subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget statItem(
      String value,
      String title,
      Color color,
      ) {

    return Column(

      children: [

        Text(
          value,

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        Text(title),
      ],
    );
  }

  Widget navItem(BuildContext context, icon, title, active, index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const InventoryPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GoalsPage()),
            );
          } else if (index == 3) {
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
