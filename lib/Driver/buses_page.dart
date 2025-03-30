import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    fetchBuses();
  }

  Future<void> fetchBuses() async {
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
        print('Failed to load buses: ${response.statusCode}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        hasError = true;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to fetch buses. Try again."))
              : buses.isEmpty
                  ? const Center(
                      child: Text("No buses available for this company."))
                  : ListView.builder(
                      itemCount: buses.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const Icon(Icons.directions_bus,
                                color: Colors.blue),
                            title: Text(
                                "Bus Number: ${buses[index]['busNumber']}"),
                            subtitle:
                                Text("Route: ${buses[index]['routeName']}"),
                          ),
                        );
                      },
                    ),
    );
  }
}
