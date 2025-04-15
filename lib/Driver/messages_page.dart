import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:busbuddy_frontend/services/websocket_service.dart';

class MessagesPage extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String companyId;

  const MessagesPage({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.companyId,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  bool isSending = false;

  void sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => isSending = true);

    try {
      stompClient.send(
        destination: '/app/driver-message',
        body: jsonEncode({
          "companyId": widget.companyId,
          "senderName": widget.driverName,
          "contactNumber": widget.driverId,
          "message": message,
          "type": "DriverMessage",
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Message sent to company")),
      );

      _messageController.clear();
    } catch (e) {
      print("❌ Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Company"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Write your message below and it will be sent directly to your company.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isSending ? null : sendMessage,
              icon: const Icon(Icons.send),
              label: const Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
