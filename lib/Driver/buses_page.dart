import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bus_detail_page.dart'; // Import the new page

class BusesPage extends StatefulWidget {
  final String companyId;

  const BusesPage({super.key, required this.companyId});

  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  List<dynamic> buses = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBuses();
  }

  Future<void> fetchBuses() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final url =
          Uri.parse('http://localhost:8080/bus/company/${widget.companyId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          buses = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to load buses (Error: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Buses'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchBuses,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 50),
                          const SizedBox(height: 10),
                          Text(errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: fetchBuses,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  )
                : buses.isEmpty
                    ? const Center(
                        child: Text("No buses available for this company."))
                    : ListView.separated(
                        itemCount: buses.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: const Icon(Icons.directions_bus,
                                  color: Colors.blue),
                              title: Text(
                                  "Bus Number: ${buses[index]['busNumber']}"),
                              subtitle:
                                  Text("Route: ${buses[index]['routeName']}"),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BusDetailPage(
                                      bus: buses[index],
                                      onStatusChange:
                                          fetchBuses, // Pass function to refresh bus list
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
