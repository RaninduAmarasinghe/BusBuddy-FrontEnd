import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusDetailPage extends StatefulWidget {
  final Map<String, dynamic> bus;
  final VoidCallback onStatusChange; // Callback function to notify parent

  const BusDetailPage({
    super.key,
    required this.bus,
    required this.onStatusChange,
  });

  @override
  State<BusDetailPage> createState() => _BusDetailPageState();
}

class _BusDetailPageState extends State<BusDetailPage> {
  bool isRunning = false;

  @override
  void initState() {
    super.initState();

    // Check if busId is available
    print("Bus data: ${widget.bus}");

    // Set the initial status of the bus
    isRunning = widget.bus['status'] == 'Running';

    // Ensure 'busId' exists before proceeding
    if (widget.bus['busId'] == null) {
      print("Error: busId is null!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Bus ID is missing!")),
        );
        Navigator.pop(context); // Close the page
      });
    }
  }

  void toggleBusStatus(bool start) async {
    final busId = widget.bus['busId'];

    // Prevent API request if busId is null
    if (busId == null) {
      print("Error: Cannot update status, busId is null.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bus ID is missing, cannot update status!")),
      );
      return;
    }

    final url = Uri.parse('http://localhost:8080/bus/$busId/status');
    print("Sending request to: $url");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': start ? 'Running' : 'Stopped'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isRunning = start;
        });

        // Notify ActiveBusesPage to refresh the list
        widget.onStatusChange();

        // Show SnackBar after the frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(start ? "Bus Started" : "Bus Stopped")),
          );
        });

        // If stopping the bus, navigate back to ActiveBusesPage
        if (!start) {
          Navigator.pop(context);
        }
      } else {
        print('Failed to update bus status: ${response.body}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update status")),
          );
        });
      }
    } catch (e) {
      print("Error updating bus status: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus ${widget.bus['busNumber']} Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bus Number: ${widget.bus['busNumber']}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Route: ${widget.bus['routeName']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Capacity: ${widget.bus['capacity']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Status: ${isRunning ? 'Running' : 'Stopped'}",
                style: TextStyle(
                    fontSize: 16,
                    color: isRunning ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => toggleBusStatus(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Start"),
                ),
                ElevatedButton(
                  onPressed: () => toggleBusStatus(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
