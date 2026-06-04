import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'home_page.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Color backgroundColor = Colors.white;
  bool showCircle = false;
  bool finalScreen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    startAnimation();
  }

  Future<void> startAnimation() async {

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      showCircle = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      backgroundColor = AppColors.primaryGreen;
      finalScreen = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    bool isLogin = await AuthService.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
        isLogin ? const HomePage() : const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: showCircle
                  ? AppColors.primaryGreen
                  : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                finalScreen
                    ? "assets/images/logo_white.png"
                    : "assets/images/logo_green.png",
                width: 130,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}