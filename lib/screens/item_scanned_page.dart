import 'dart:io';
import 'package:flutter/material.dart';
import 'inventory_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/user_session.dart';

class ItemScannedPage extends StatefulWidget {

  final String imagePath;
  final String prediction;
  final double confidence;

  const ItemScannedPage({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.confidence,
  });

  @override
  State<ItemScannedPage> createState() => _ItemScannedPageState();
}

class _ItemScannedPageState extends State<ItemScannedPage> {

  late String selectedItemName;
  late DateTime selectedExpiryDate;
  bool _showBanner = true;

  static const Map<String, int> _expiryDaysMap = {
    "apple":        14,
    "banana":        7,
    "beetroot":     14,
    "bell pepper":   7,
    "cabbage":      14,
    "capsicum":      7,
    "carrot":       21,
    "cauliflower":   7,
    "chilli pepper": 14,
    "corn":          5,
    "cucumber":      7,
    "eggplant":      7,
    "garlic":       30,
    "ginger":       21,
    "grapes":        7,
    "jalepeno":     14,
    "kiwi":         14,
    "lemon":        21,
    "lettuce":       5,
    "mango":         7,
    "onion":        30,
    "orange":       14,
    "paprika":       7,
    "pear":         10,
    "peas":          5,
    "pineapple":    10,
    "pomegranate":  14,
    "potato":       30,
    "raddish":       7,
    "soy beans":    10,
    "spinach":       5,
    "sweetcorn":     5,
    "sweetpotato":  21,
    "tomato":        7,
    "turnip":       14,
    "watermelon":    7,
  };

  // ================= CATEGORY MAP =================
  static const Map<String, String> _categoryMap = {
    "apple":        "Fruit",
    "banana":       "Fruit",
    "beetroot":     "Vegetable",
    "bell pepper":  "Vegetable",
    "cabbage":      "Vegetable",
    "capsicum":     "Vegetable",
    "carrot":       "Vegetable",
    "cauliflower":  "Vegetable",
    "chilli pepper":"Vegetable",
    "corn":         "Vegetable",
    "cucumber":     "Vegetable",
    "eggplant":     "Vegetable",
    "garlic":       "Vegetable",
    "ginger":       "Spice",
    "grapes":       "Fruit",
    "jalepeno":     "Vegetable",
    "kiwi":         "Fruit",
    "lemon":        "Fruit",
    "lettuce":      "Vegetable",
    "mango":        "Fruit",
    "onion":        "Vegetable",
    "orange":       "Fruit",
    "paprika":      "Spice",
    "pear":         "Fruit",
    "peas":         "Vegetable",
    "pineapple":    "Fruit",
    "pomegranate":  "Fruit",
    "potato":       "Vegetable",
    "raddish":      "Vegetable",
    "soy beans":    "Legume",
    "spinach":      "Vegetable",
    "sweetcorn":    "Vegetable",
    "sweetpotato":  "Vegetable",
    "tomato":       "Vegetable",
    "turnip":       "Vegetable",
    "watermelon":   "Fruit",
  };


  String _calculateStatus(DateTime expiryDate) {
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    if (remaining <= 0) return "Expired";
    if (remaining <= 5) return "Almost Expired";
    return "Fresh";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Expired":       return const Color(0xFFE53935);
      case "Almost Expired":return const Color(0xFFFFA726);
      default:              return const Color(0xFF76A82A);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Expired":        return Icons.cancel_outlined;
      case "Almost Expired": return Icons.warning_amber_rounded;
      default:               return Icons.check_circle_outline;
    }
  }

  String getItemImage(String name) {
    final fileName = name.toLowerCase().replaceAll(" ", "_");
    return "assets/images/$fileName.png";
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    final words = s.split(" ");
    return words.map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(" ");
  }

  static const List<String> _allItems = [
    "Apple", "Banana", "Beetroot", "Bell Pepper", "Cabbage", "Capsicum",
    "Carrot", "Cauliflower", "Chilli Pepper", "Corn", "Cucumber", "Eggplant",
    "Garlic", "Ginger", "Grapes", "Jalepeno", "Kiwi", "Lemon", "Lettuce",
    "Mango", "Onion", "Orange", "Paprika", "Pear", "Peas", "Pineapple",
    "Pomegranate", "Potato", "Raddish", "Soy Beans", "Spinach", "Sweetcorn",
    "Sweetpotato", "Tomato", "Turnip", "Watermelon",
  ];

  @override
  void initState() {
    super.initState();
    selectedItemName = _capitalize(widget.prediction);
    final key = widget.prediction.toLowerCase();
    final days = _expiryDaysMap[key] ?? 7;
    selectedExpiryDate = DateTime.now().add(Duration(days: days));
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedExpiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF76A82A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedExpiryDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _addToInventory() async {
    final inventoryImage = getItemImage(selectedItemName);
    final expiryDays = selectedExpiryDate.difference(DateTime.now()).inDays;
    final status = _calculateStatus(selectedExpiryDate);

    final response = await http.post(
      Uri.parse("https://backendai-production-b126.up.railway.app/inventory/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username":   UserSession.username,
        "item_name":  selectedItemName,
        "image":      inventoryImage,
        "expiry_days": expiryDays,
        "status":     status,
      }),
    );

    print(response.body);
    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to inventory")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InventoryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final category = _categoryMap[selectedItemName.toLowerCase()] ?? "Other";
    final status   = _calculateStatus(selectedExpiryDate);
    final statusColor = _statusColor(status);
    final statusIcon  = _statusIcon(status);
    final inventoryImage = getItemImage(selectedItemName);
    final remainingDays = selectedExpiryDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF76A82A),
        elevation: 0,
        toolbarHeight: 55,
        automaticallyImplyLeading: false,
        title: const Text(
          "Item Scanned",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
        ),
      ),

      /// ================= BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ================= SUCCESS BANNER =================
                if (_showBanner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD6EAB0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFF76A82A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Successfully identified!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Autofilled from camera scan results.",
                                style: TextStyle(fontSize: 11.5, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showBanner = false),
                          child: const Icon(Icons.close, size: 18, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),

                if (_showBanner) const SizedBox(height: 16),

                /// ================= CONFIRMATION CARD =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ================= CARD HEADER =================
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 60, height: 60,
                              child: widget.imagePath.startsWith("assets/")
                                  ? Image.asset(
                                inventoryImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE8F5D2),
                                  child: const Icon(Icons.fastfood, color: Color(0xFF76A82A), size: 30),
                                ),
                              )
                                  : Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE8F5D2),
                                  child: const Icon(Icons.fastfood, color: Color(0xFF76A82A), size: 30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Item Confirmation",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "One more step to save your food.",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 18),

                      /// ================= ITEM NAME DROPDOWN =================
                      const Text(
                        "Item Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _allItems.contains(selectedItemName)
                                ? selectedItemName
                                : _allItems.first,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            items: _allItems
                                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final key = val.toLowerCase();
                                final days = _expiryDaysMap[key] ?? 7;
                                setState(() {
                                  selectedItemName = val;
                                  selectedExpiryDate = DateTime.now().add(Duration(days: days));
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= CATEGORY =================
                      const Text(
                        "Category",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= EXPIRY DATE =================
                      const Text(
                        "Estimated Expiration Date",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickExpiryDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(selectedExpiryDate),
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black45),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= STATUS BADGE =================
                      const Text(
                        "Freshness Status",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                                Text(
                                  remainingDays > 0
                                      ? "$remainingDays day${remainingDays == 1 ? '' : 's'} remaining"
                                      : "Already expired",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: statusColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= ADD BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _addToInventory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7A10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Add to Inventory",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ================= SCAN AGAIN BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4A7A10), width: 1.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Scan Again",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A7A10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}