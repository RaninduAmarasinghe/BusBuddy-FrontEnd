import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String driverName;
  final String companyName;

  const ProfilePage({
    super.key,
    required this.driverName,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Profile"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/profile.png'), // You can update this to a network image if needed
            ),
            const SizedBox(height: 20),
            Text(
              driverName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Company: $companyName",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 20),

            // Example Profile Info
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text("Mobile Number"),
              subtitle: const Text("+94 712345678"), // Replace if needed
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: const Text("driver@example.com"), // Replace if needed
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text("Assigned Bus"),
              subtitle: const Text("B2290"), // Replace dynamically if available
            ),
          ],
        ),
      ),
    );
  }
}
