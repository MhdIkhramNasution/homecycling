import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/tflite_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  try {

    print("LOAD MODEL START");

    await TFLiteService.loadModel();

    print("LOAD MODEL SUCCESS");

  } catch (e) {

    print("LOAD MODEL FAILED");
    print(e);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}