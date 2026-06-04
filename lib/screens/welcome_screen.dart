import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../screens/home_page.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),

        child: Column(
          children: [

            const SizedBox(height: 50),

            Image.asset(
              "assets/images/logo_green.png",
              width: 264,
            ),

            const SizedBox(height: 0),

            const Text(
              "Smart Food Tracker\nTurning Groceries\ninto Sustainable\nHabits",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Track what you buy, monitor expiration dates, and\n"
                  " manage your food smarter. Turn everyday meals into\n"
                  " sustainable habits and reduce unnecessary waste.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const Spacer(),

            /// ================= LOGIN =================
            SizedBox(
              width: 353,
              height: 53,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF74A830),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
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

            const SizedBox(height: 21),

            /// ================= REGISTER =================
            SizedBox(
              width: 353,
              height: 53,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF74A830),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
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
                    color: Color(0xFFF1F6EA),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),

          ],
        ),
      ),
    );
  }
}