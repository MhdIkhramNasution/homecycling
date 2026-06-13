import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';

class ManualAddPage extends StatefulWidget {
  const ManualAddPage({super.key});

  @override
  State<ManualAddPage> createState() => _ManualAddPageState();
}

class _ManualAddPageState extends State<ManualAddPage> {

  final TextEditingController itemController =
  TextEditingController();

  final TextEditingController categoryController =
  TextEditingController();

  final TextEditingController dateController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  Future<void> saveItem() async {

    if (itemController.text.isEmpty) {
      return;
    }

    try {

      final response = await http.post(

        Uri.parse(
          "http://192.168.100.7:8000/inventory/manual-add",
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode({

          "username":
          UserSession.username,

          "item_name":
          itemController.text,

          "category":
          categoryController.text,

          "expiry_date":
          dateController.text,

          "notes":
          notesController.text,
        }),
      );

      print(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Item berhasil ditambahkan",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Gagal menambahkan item",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        title: const Text(
          "Manual Input",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            fieldTitle("Item Name"),
            customField(
              controller: itemController,
              hint: "Select an item",
            ),

            const SizedBox(height: 20),

            fieldTitle("Category"),
            customField(
              controller: categoryController,
              hint: "Select category",
            ),

            const SizedBox(height: 20),

            fieldTitle("Estimated Expiration Date"),
            customField(
              controller: dateController,
              hint: "mm/dd/yyyy",
            ),

            const SizedBox(height: 20),

            fieldTitle("Notes (Optional)"),
            customField(
              controller: notesController,
              hint: "Add notes...",
              maxLines: 5,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF577E24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: saveItem,
                child: const Text(
                  "Save Item",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget customField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F5EA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}