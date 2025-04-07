import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:busbuddy_frontend/bus_map_page.dart'; // Update the path if needed

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
    final url = Uri.parse('http://192.168.8.101:8080/bus/active');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          activeBuses =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        setState(() => activeBuses = []);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch active buses")),
        );
      }
    } catch (e) {
      setState(() => activeBuses = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Buses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchActiveBuses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchActiveBuses,
        child: activeBuses.isEmpty
            ? const Center(child: Text("No active buses available"))
            : ListView.builder(
                itemCount: activeBuses.length,
                itemBuilder: (context, index) {
                  final bus = activeBuses[index];
                  final route = (bus['routes'] as List?)?.isNotEmpty == true
                      ? bus['routes'][0]
                      : null;
                  final location = bus['location'];
                  final busId = bus['busId'];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text("Bus Number: ${bus['busNumber'] ?? 'N/A'}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Route Number: ${route?['routeNumber'] ?? 'N/A'}"),
                          Text(
                              "From ${route?['startPoint'] ?? '-'} to ${route?['endPoint'] ?? '-'}"),
                        ],
                      ),
                      trailing: Text(bus['status'] ?? '',
                          style: const TextStyle(color: Colors.green)),
                      onTap: () {
                        if (location != null &&
                            location['latitude'] != null &&
                            location['longitude'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusMapPage(
                                latitude: location['latitude'],
                                longitude: location['longitude'],
                                busId: busId,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("No location available for this bus"),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
