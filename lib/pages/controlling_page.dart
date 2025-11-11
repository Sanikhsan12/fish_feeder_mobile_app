import 'package:flutter/material.dart';

class ControllingPage extends StatelessWidget {
  const ControllingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controlling Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Controlling Page!'),
      ),
    );
  }
}
