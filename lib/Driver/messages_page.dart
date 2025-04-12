import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "No messages available.",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
