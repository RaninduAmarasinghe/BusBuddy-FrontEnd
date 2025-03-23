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

  @override
  void initState() {
    super.initState();
    fetchBuses();
  }

  Future<void> fetchBuses() async {
    try {
      final url = Uri.parse('http://localhost:8080/buses/${widget.companyId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          buses = jsonDecode(response.body);
        });
      } else {
        print('Failed to load buses');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Buses'),
        centerTitle: true,
      ),
      body: buses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: buses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading:
                        const Icon(Icons.directions_bus, color: Colors.blue),
                    title: Text(buses[index]['busNumber']),
                    subtitle: Text('Route: ${buses[index]['routeName']}'),
                  ),
                );
              },
            ),
    );
  }
}
