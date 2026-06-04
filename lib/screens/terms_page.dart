import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Our App Terms & Conditions\n\n"
              "By using this application, you agree to the following terms:\n\n"
              "- You agree to use the app responsibly.\n"
              "- You will not misuse any feature.\n"
              "- Points and rewards cannot be exchanged for cash.\n\n"
              "More detailed terms can be added here.",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}