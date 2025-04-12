import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String companyName;
  final String busId;

  const ProfilePage({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.companyName,
    required this.busId,
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
              backgroundImage: AssetImage('assets/profile.png'),
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
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text("Driver ID"),
              subtitle: Text(driverId),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text("Email"),
              subtitle: Text(driverEmail),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text("Assigned Bus ID"),
              subtitle: Text(busId),
            ),
          ],
        ),
      ),
    );
  }
}
