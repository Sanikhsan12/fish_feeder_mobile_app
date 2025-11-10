import 'package:flutter/material.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password Page'),
      ),
      body: const Center(
        child: Text('This is the forgot password page'),
      ),
    );
  }
}
