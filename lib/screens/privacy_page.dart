import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Privacy Policy",
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
          "We respect your privacy and are committed to protecting your personal information.\n\n"
              "This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.\n\n"
              "Information We Collect:\n"
              "- User data\n"
              "- App usage data\n\n"
              "Your data is सुरक्षित and not shared without permission.",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}