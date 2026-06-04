import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryService {
  static List<Map<String, dynamic>> items = [];

  static const String key = "inventory_items";

  /// LOAD DATA
  static Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data != null) {
      items = List<Map<String, dynamic>>.from(jsonDecode(data));
    }
  }

  /// SAVE DATA
  static Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  /// ADD ITEM
  static Future<void> addItem(Map<String, dynamic> item) async {
    items.insert(0, item);
    await saveItems();
  }

  /// DELETE ITEM
  static Future<void> deleteItem(int index) async {
    items.removeAt(index);
    await saveItems();
  }
}