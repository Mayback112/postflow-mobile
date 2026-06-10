import 'dart:async';

import 'package:flutter/material.dart';
import 'package:postflow/screen/authentication/widgets/auth_success_content.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _redirectTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/Home', (_) => false);
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: AuthSuccessContent(),
    );
  }
}
