import 'dart:async';
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
  Timer? _timer; // Timer for auto-refresh

  @override
  void initState() {
    super.initState();
    fetchActiveBuses();
    // Auto-refresh every 30 seconds (adjust as needed)
    _timer = Timer.periodic(
        const Duration(seconds: 30), (Timer t) => fetchActiveBuses());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to avoid memory leaks
    super.dispose();
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
      extendBodyBehindAppBar: true,
      // Transparent AppBar with white icon theme (affecting the back button)
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Active Buses",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchActiveBuses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        // Dark gradient background for a futuristic vibe
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchActiveBuses,
          color: Colors.white,
          child: activeBuses.isEmpty
              ? const Center(
                  child: Text(
                    "No active buses available",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: kToolbarHeight + 60,
                    bottom: 20,
                  ),
                  itemCount: activeBuses.length,
                  itemBuilder: (context, index) {
                    final bus = activeBuses[index];
                    // Get the first route if available
                    final route = (bus['routes'] as List?)?.isNotEmpty == true
                        ? bus['routes'][0]
                        : null;
                    final location = bus['location'];
                    final busId = bus['busId'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: GestureDetector(
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
                                  companyId: bus['companyId'], // pass companyId
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            title: Text(
                              "Bus Number: ${bus['busNumber'] ?? 'N/A'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Route Number: ${route?['routeNumber'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  "From ${route?['startPoint'] ?? '-'} to ${route?['endPoint'] ?? '-'}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            trailing: Text(
                              bus['status'] ?? '',
                              style: const TextStyle(color: Colors.greenAccent),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
