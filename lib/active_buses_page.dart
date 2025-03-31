import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'driver/bus_detail_page.dart'; // Import the missing BusDetailPage

class ActiveBusesPage extends StatefulWidget {
  const ActiveBusesPage({super.key});

  @override
  _ActiveBusesPageState createState() => _ActiveBusesPageState();
}

class _ActiveBusesPageState extends State<ActiveBusesPage> {
  List<Map<String, dynamic>> activeBuses = [];

  @override
  void initState() {
    super.initState();
    fetchActiveBuses();
  }

  Future<void> fetchActiveBuses() async {
    final url = Uri.parse('http://localhost:8080/bus/active');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          activeBuses =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        setState(() {
          activeBuses = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch active buses")),
        );
      }
    } catch (e) {
      setState(() {
        activeBuses = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Active Buses")),
      body: RefreshIndicator(
        onRefresh: fetchActiveBuses,
        child: activeBuses.isEmpty
            ? const Center(child: Text("No active buses available"))
            : ListView.builder(
                itemCount: activeBuses.length,
                itemBuilder: (context, index) {
                  final bus = activeBuses[index];
                  return ListTile(
                    title: Text("Bus ${bus['busNumber']}"),
                    subtitle: Text("Route: ${bus['routeName']}"),
                    trailing: Text(bus['status'],
                        style: TextStyle(color: Colors.green)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusDetailPage(
                          bus: bus,
                          onStatusChange: fetchActiveBuses,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
