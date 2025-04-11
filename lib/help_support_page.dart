import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: const Text(
          'Help and Support information goes here.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
