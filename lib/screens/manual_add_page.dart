import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';

class ManualAddPage extends StatefulWidget {
  const ManualAddPage({super.key});

  @override
  State<ManualAddPage> createState() => _ManualAddPageState();
}

class _ManualAddPageState extends State<ManualAddPage> {

  String? selectedItem;
  DateTime? selectedExpiryDate;

  final TextEditingController notesController = TextEditingController();

  // ================= ITEM LIST (dari labels.txt) =================
  static const List<String> _allItems = [
    "Apple", "Banana", "Beetroot", "Bell Pepper", "Cabbage", "Capsicum",
    "Carrot", "Cauliflower", "Chilli Pepper", "Corn", "Cucumber", "Eggplant",
    "Garlic", "Ginger", "Grapes", "Jalepeno", "Kiwi", "Lemon", "Lettuce",
    "Mango", "Onion", "Orange", "Paprika", "Pear", "Peas", "Pineapple",
    "Pomegranate", "Potato", "Raddish", "Soy Beans", "Spinach", "Sweetcorn",
    "Sweetpotato", "Tomato", "Turnip", "Watermelon",
  ];

  // ================= EXPIRY DAYS =================
  static const Map<String, int> _expiryDaysMap = {
    "apple":         14,
    "banana":         7,
    "beetroot":      14,
    "bell pepper":    7,
    "cabbage":       14,
    "capsicum":       7,
    "carrot":        21,
    "cauliflower":    7,
    "chilli pepper": 14,
    "corn":           5,
    "cucumber":       7,
    "eggplant":       7,
    "garlic":        30,
    "ginger":        21,
    "grapes":         7,
    "jalepeno":      14,
    "kiwi":          14,
    "lemon":         21,
    "lettuce":        5,
    "mango":          7,
    "onion":         30,
    "orange":        14,
    "paprika":        7,
    "pear":          10,
    "peas":           5,
    "pineapple":     10,
    "pomegranate":   14,
    "potato":        30,
    "raddish":        7,
    "soy beans":     10,
    "spinach":        5,
    "sweetcorn":      5,
    "sweetpotato":   21,
    "tomato":         7,
    "turnip":        14,
    "watermelon":     7,
  };

  // ================= CATEGORY MAP =================
  static const Map<String, String> _categoryMap = {
    "apple":         "Fruit",
    "banana":        "Fruit",
    "beetroot":      "Vegetable",
    "bell pepper":   "Vegetable",
    "cabbage":       "Vegetable",
    "capsicum":      "Vegetable",
    "carrot":        "Vegetable",
    "cauliflower":   "Vegetable",
    "chilli pepper": "Vegetable",
    "corn":          "Vegetable",
    "cucumber":      "Vegetable",
    "eggplant":      "Vegetable",
    "garlic":        "Vegetable",
    "ginger":        "Spice",
    "grapes":        "Fruit",
    "jalepeno":      "Vegetable",
    "kiwi":          "Fruit",
    "lemon":         "Fruit",
    "lettuce":       "Vegetable",
    "mango":         "Fruit",
    "onion":         "Vegetable",
    "orange":        "Fruit",
    "paprika":       "Spice",
    "pear":          "Fruit",
    "peas":          "Vegetable",
    "pineapple":     "Fruit",
    "pomegranate":   "Fruit",
    "potato":        "Vegetable",
    "raddish":       "Vegetable",
    "soy beans":     "Legume",
    "spinach":       "Vegetable",
    "sweetcorn":     "Vegetable",
    "sweetpotato":   "Vegetable",
    "tomato":        "Vegetable",
    "turnip":        "Vegetable",
    "watermelon":    "Fruit",
  };

  // ================= STATUS LOGIC =================
  String _calculateStatus(DateTime expiryDate) {
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    if (remaining <= 0) return "Expired";
    if (remaining <= 5) return "Almost Expired";
    return "Fresh";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Expired":        return const Color(0xFFE53935);
      case "Almost Expired": return const Color(0xFFFFA726);
      default:               return const Color(0xFF76A82A);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Expired":        return Icons.cancel_outlined;
      case "Almost Expired": return Icons.warning_amber_rounded;
      default:               return Icons.check_circle_outline;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
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

  Future<void> saveItem() async {
    if (selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih item terlebih dahulu")),
      );
      return;
    }

    if (selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal kadaluarsa")),
      );
      return;
    }

    try {
      final key = selectedItem!.toLowerCase();
      final imagePath = "assets/images/${key.replaceAll(' ', '_')}.png";
      final expiryDays = selectedExpiryDate!.difference(DateTime.now()).inDays;
      final status = _calculateStatus(selectedExpiryDate!);
      final category = _categoryMap[key] ?? "Other";

      final response = await http.post(
        Uri.parse("https://backendai-production-b126.up.railway.app/manual-add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username":   UserSession.username,
          "item_name":  selectedItem,
          "category":   category,
          "expiry_date": _formatDate(selectedExpiryDate!),
          "notes":      notesController.text,
        }),
      );

      // Juga kirim ke endpoint /inventory/add agar expiry_days & status tersimpan
      await http.post(
        Uri.parse("https://backendai-production-b126.up.railway.app/inventory/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username":   UserSession.username,
          "item_name":  selectedItem,
          "image":      imagePath,
          "expiry_days": expiryDays,
          "status":     status,
        }),
      );

      print(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item berhasil ditambahkan")),
      );

      Navigator.pop(context);

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan item")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final key = selectedItem?.toLowerCase();
    final category = key != null ? (_categoryMap[key] ?? "Other") : null;
    final status = selectedExpiryDate != null ? _calculateStatus(selectedExpiryDate!) : null;
    final statusColor = status != null ? _statusColor(status) : null;
    final statusIcon  = status != null ? _statusIcon(status)  : null;
    final remainingDays = selectedExpiryDate?.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF76A82A),
        elevation: 0,
        toolbarHeight: 55,
        title: const Text(
          "Manual Input",
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

                /// ================= FORM CARD =================
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

                      /// ================= ITEM NAME DROPDOWN =================
                      _fieldTitle("Item Name"),
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
                            value: selectedItem,
                            isExpanded: true,
                            hint: const Text(
                              "Select an item",
                              style: TextStyle(
                                fontSize: 14.5,
                                color: Colors.black38,
                              ),
                            ),
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
                                final k = val.toLowerCase();
                                final days = _expiryDaysMap[k] ?? 7;
                                setState(() {
                                  selectedItem = val;
                                  selectedExpiryDate = DateTime.now().add(Duration(days: days));
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= CATEGORY (auto) =================
                      _fieldTitle("Category"),
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
                          category ?? "Auto-filled after selecting item",
                          style: TextStyle(
                            fontSize: 14.5,
                            color: category != null ? Colors.black87 : Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= EXPIRY DATE (auto + bisa ubah) =================
                      _fieldTitle("Estimated Expiration Date"),
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
                                selectedExpiryDate != null
                                    ? _formatDate(selectedExpiryDate!)
                                    : "Auto-filled after selecting item",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: selectedExpiryDate != null
                                      ? Colors.black87
                                      : Colors.black38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black45),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= STATUS (muncul setelah item dipilih) =================
                      if (status != null) ...[
                        _fieldTitle("Freshness Status"),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: statusColor!.withOpacity(0.08),
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
                                    remainingDays != null && remainingDays > 0
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
                        const SizedBox(height: 16),
                      ],

                      /// ================= NOTES =================
                      _fieldTitle("Notes (Optional)"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Add notes...",
                          hintStyle: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.black38,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF76A82A), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= SAVE BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7A10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Save Item",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

  Widget _fieldTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
        color: Colors.black87,
      ),
    );
  }
}