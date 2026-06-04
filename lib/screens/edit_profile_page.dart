import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_page.dart';
import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;

  final picker = ImagePicker();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// LOAD DATA LAMA
  Future<void> loadProfile() async {
    final data = await AuthService.getProfile();

    setState(() {
      usernameController.text = data["username"]!;
      emailController.text = data["email"]!;
      phoneController.text = data["phone"]!;
      imagePath = data["photo"];

      if (imagePath != null && imagePath!.isNotEmpty) {
        _image = File(imagePath!);
      }
    });
  }

  /// PICK IMAGE
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imagePath = pickedFile.path;
      });
    }
  }

  /// SAVE PROFILE
  Future<void> saveProfile() async {
    await AuthService.saveProfile(
      username: usernameController.text,
      email: emailController.text,
      phone: phoneController.text,
      photo: imagePath,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      /// APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF74A830),
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Image.asset("assets/icon/profile_icon.png", width: 50)
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/icon/edit_profile_icon.png",
                        width: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ================= INPUT =================
            inputField(
              "Username",
              "assets/icon/user_profile_icon.png",
              controller: usernameController,
            ),

            inputField(
              "E-mail",
              "assets/icon/mail_profile_icon.png",
              controller: emailController,
            ),

            inputField(
              "Phone",
              "assets/icon/phone_profile_icon.png",
              controller: phoneController,
            ),

            inputField(
              "Password",
              "assets/icon/biometric_profile_icon.png",
              controller: passwordController,
              obscure: true,
            ),

            const SizedBox(height: 30),

            /// ================= BUTTON SAVE =================
            GestureDetector(
              onTap: saveProfile,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF577E24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Save Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputField(
    String hint,
    String icon, {
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 20),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
