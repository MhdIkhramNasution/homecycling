import 'package:flutter/material.dart';
import 'home_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  bool agree = false;
  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

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

                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 40),

                const Text(
                  "Let's get\nstarted, Mate!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                /// USERNAME
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// EMAIL
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// MOBILE
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,

                  decoration: InputDecoration(
                    hintText: "Phone Number",

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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// CONFIRM PASSWORD
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// CHECKBOX
                Row(
                  children: [

                    Checkbox(
                      value: agree,
                      onChanged: (value) {
                        setState(() {
                          agree = value!;
                        });
                      },
                    ),

                    const Expanded(
                      child: Text(
                        "I agree with the terms and conditions",
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 20),

                /// REGISTER BUTTON
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
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );

                          return;
                        }

                        if (passwordController.text !=
                            confirmPasswordController.text) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password does not match"),
                            ),
                          );

                          return;
                        }

                        final response = await http.post(

                          Uri.parse("http://192.168.100.7:8000/register"),

                          headers: {
                            "Content-Type": "application/json",
                          },

                          body: jsonEncode({
                            "username": usernameController.text,
                            "email": emailController.text,
                            "phone": phoneController.text,
                            "password": passwordController.text,
                          }),
                        );

                        print(response.statusCode);
                        print(response.body);

                        final data = jsonDecode(response.body);

                        if (data["status"] == "success") {

                          UserSession.username =
                              usernameController.text;

                          UserSession.email =
                              emailController.text;

                          UserSession.phone =
                              phoneController.text;

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
                        "Register",
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

                /// LOGIN LINK
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [

                        const TextSpan(
                          text: "Already have an account? ",
                        ),

                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Login",
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