import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: const Text(
          'Bus Schedule goes here.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
