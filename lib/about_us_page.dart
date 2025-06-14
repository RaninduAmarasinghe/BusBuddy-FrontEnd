import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: const Text(
          'Ranindu Amarasinghe.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
