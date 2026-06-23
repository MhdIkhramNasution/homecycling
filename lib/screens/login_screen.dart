import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 30),

                /// BACK
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 60),

                const Text(
                  "Welcome back,\nMate!!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                /// USERNAME
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 20),

                /// LOGIN BUTTON
                Center(
                  child: SizedBox(
                    width: 353,
                    height: 53,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74A830),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: () async {

                        if (usernameController.text.isEmpty ||
                            passwordController.text.isEmpty) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );

                          return;
                        }

                        final response = await http.post(

                          Uri.parse("https://backendai-production-b126.up.railway.app/login"),

                          headers: {
                            "Content-Type": "application/json",
                          },

                          body: jsonEncode({

                            "username": usernameController.text,
                            "password": passwordController.text,
                          }),
                        );

                        final data = jsonDecode(response.body);

                        if (data["status"] == "success") {
                          UserSession.username = data["username"];
                          print(UserSession.username);
                          UserSession.email = data["email"];
                          UserSession.phone = data["phone"] ?? "";

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                          );

                        } else {

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(data["message"]),
                            ),
                          );
                        }
                      },

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFFF1F6EA),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Center(
                  child: Text("Or login in with"),
                ),

                const SizedBox(height: 20),

                /// GOOGLE FACEBOOK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Container(
                      width: 140,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.g_mobiledata, size: 28),
                          SizedBox(width: 8),
                          Text("Google"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Container(
                      width: 140,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF6B5C6B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.facebook, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Facebook",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 30),

                /// REGISTER
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [

                        const TextSpan(text: "Don't have an account? "),

                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF74A830),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

              ],
            ),
          ),
        ),
      ),
    );
  }
}