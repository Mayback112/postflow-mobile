import 'package:flutter/material.dart';
import 'package:postflow/routes/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayPro',
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EFF)),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      onGenerateRoute: Routes.generateRoute, // Use the updated Routes class
    );
  }
}
