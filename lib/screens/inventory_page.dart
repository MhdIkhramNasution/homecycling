import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';
import 'goals_page.dart';
import 'profile_page.dart';
import 'detail_item_page.dart';
import 'item_scanned_page.dart';
import '../services/inventory_service.dart';
import 'manual_add_page.dart';
import '../services/user_session.dart';
import '../services/tflite_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String getItemImage(String prediction) {

    final fileName = prediction
        .toLowerCase()
        .replaceAll(" ", "_");

    return "assets/images/$fileName.png";
  }
  String searchText = "";
  String selectedStatus = "All";

  List<Map<String, dynamic>> items = [];

  void reduceStock(int index) {

    setState(() {

      items[index]["stock"]--;

      if (items[index]["stock"] <= 0) {

        final deletedItem = items[index];

        items.removeAt(index);

        InventoryService.items.removeWhere(
              (item) =>
          item["title"] ==
              deletedItem["title"],
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  /// ================= LOAD INVENTORY =================
  Future<void> loadInventory() async {

    try {

      final response = await http.get(

        Uri.parse(
            "http://192.168.100.7:8000/inventory/${UserSession.username}"
        ),
      );

      print(response.body);

      final data = jsonDecode(response.body);

      setState(() {

        items = List<Map<String, dynamic>>.from(

          data.map((item) => {

            "id": item["id"],

            "image": item["image"],

            "title": item["title"],

            "subtitle": item["subtitle"],

            "badge": item["badge"],

            "status": item["status"],

            "stock": item["stock"],

            "color": item["color"] ?? 0xFF4CAF50,

            "progress":
            (item["progress"] ?? 1.0).toDouble(),
          }),
        );
      });

      print(items);

    } catch (e) {

      print("LOAD INVENTORY ERROR");
      print(e);
    }
  }

  /// ================= CAMERA =================
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

        print(prediction);

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

  /// ================= ADD ITEM POPUP =================
  void showAddItemPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),

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

              const SizedBox(height: 25),

              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Add New Item",

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= MANUAL INPUT =================
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManualAddPage(),
                    ),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4E8),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [

                      Container(
                        width: 50,
                        height: 50,

                        decoration: const BoxDecoration(
                          color: Color(0xFF74A830),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 15),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Manual Input",

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Enter product details manually",

                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// ================= SCAN ITEM =================
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  openCamera();
                },

                child: Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4E8),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [

                      Container(
                        width: 50,
                        height: 50,

                        decoration: const BoxDecoration(
                          color: Color(0xFF74A830),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 15),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Scan Item",

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Use camera scanner",

                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74A830),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    "Cancel",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// ================= FILTER =================
  void showFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 5,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Filter",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Sort by",

                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4E8),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 20),

                        SizedBox(width: 10),

                        Text(
                          "Expiration Date",

                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Status",

                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  filterItem(setModalState, Colors.lightGreen, "Fresh"),

                  const SizedBox(height: 10),

                  filterItem(setModalState, Colors.orange, "Almost Expired"),

                  const SizedBox(height: 10),

                  filterItem(setModalState, Colors.redAccent, "Expired"),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,

                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedStatus = "All";
                              });

                              Navigator.pop(context);
                            },

                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF74A830)),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: const Text(
                              "Reset",

                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: SizedBox(
                          height: 45,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF74A830),

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: const Text(
                              "Apply",

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget filterItem(StateSetter setModalState, Color color, String text) {
    bool selected = selectedStatus == text;

    return GestureDetector(
      onTap: () {
        setModalState(() {
          selectedStatus = text;
        });

        setState(() {});
      },

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),

        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F2D9) : const Color(0xFFF1F4E8),

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: selected ? const Color(0xFF74A830) : Colors.transparent,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,

              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(width: 12),

            Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  /// ================= STATUS BADGE =================
  Widget statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List filteredItems = items.where((item) {
      final matchSearch = item["title"].toLowerCase().contains(
        searchText.toLowerCase(),
      );

      final matchFilter = selectedStatus == "All"
          ? true
          : item["status"] == selectedStatus;

      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  /// ================= HEADER CARD =================
                  Container(
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(color: const Color(0xFF74A830)),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "57 Foods & Ingredients Collected",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "Monitor your food and grocery stocks to ensure they don't expire.",
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            statusBadge("Fresh 12", const Color(0xFF4CAF50)),

                            statusBadge(
                              "Almost Expired 7",
                              const Color(0xFFFF9800),
                            ),

                            statusBadge("Expired 2", const Color(0xFFF44336)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },

                          decoration: InputDecoration(
                            hintText: "Search...",
                            prefixIcon: const Icon(Icons.search),

                            filled: true,
                            fillColor: const Color(0xFFE3E7DD),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      GestureDetector(
                        onTap: showFilter,

                        child: Container(
                          height: 50,
                          width: 60,

                          decoration: BoxDecoration(
                            color: const Color(0xFFE3E7DD),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(Icons.filter_alt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                itemCount: filteredItems.length,

                itemBuilder: (context, index) {
                  var item = filteredItems[index];

                  return inventoryItem(
                    index,
                    item["image"],
                    item["title"],
                    item["subtitle"],
                    item["badge"],
                    item["color"],
                    item["progress"],
                    item["stock"],
                  );
                },
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
          onPressed: showAddItemPopup,

          icon: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,


      /// ================= NAVBAR =================
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: SizedBox(
          height: 70,

          child: Row(
            children: [
              navItem(context, "assets/navbar/home.png", "Home", false, 0),

              navItem(
                context,
                "assets/navbar/inventory.png",
                "Inventory",
                true,
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

  Widget inventoryItem(
      int index,
      image,
      title,
      subtitle,
      badge,
      color,
      progress,
      stock,
      )  {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,

          builder: (_) => DetailItemPage(title: title, image: image),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: const Color(0xFFE3E7DD),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: image.toString().startsWith("/")
                  ? Image.file(
                      File(image),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Expanded(
                        child: Text(
                          title,

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Color(color).withOpacity(0.2),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          badge,

                          style: TextStyle(
                            color: Color(color),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(subtitle, style: const TextStyle(fontSize: 12)),

                  const SizedBox(height: 5),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),

                    child: Stack(
                      children: [
                        Container(height: 6, color: Colors.grey.shade300),

                        FractionallySizedBox(
                          widthFactor: progress,

                          child: Container(height: 6, color: Color(color)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(
    BuildContext context,
    String icon,
    String title,
    bool active,
    int index,
  ) {
    return Expanded(
      child: InkWell(
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

            const SizedBox(height: 4),

            Text(
              title,

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,

                color: active ? const Color(0xFF74A830) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
