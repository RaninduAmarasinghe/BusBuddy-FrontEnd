import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusesPage extends StatefulWidget {
  final String companyId;
  final String busId;

  const BusesPage({
    super.key,
    required this.companyId,
    required this.busId,
  });

  @override
  _BusesPageState createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  Map<String, dynamic>? busDetails;

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
  }

  Future<void> fetchBusDetails() async {
    final url = Uri.parse('http://localhost:8080/bus/details/${widget.busId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => busDetails = jsonDecode(response.body));
      } else {
        setState(() => busDetails = {'error': 'Failed to load bus details'});
      }
    } catch (e) {
      setState(() => busDetails = {'error': 'Error: $e'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Details'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (busDetails == null) return const Center(child: CircularProgressIndicator());
    
    if (busDetails!.containsKey('error')) {
      return Center(child: Text(busDetails!['error'], 
               style: const TextStyle(color: Colors.red, fontSize: 16)));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Bus ID', busDetails!['busId']),
                    _buildDetailRow('Bus Number', busDetails!['busNumber']),
                    _buildRouteDetails(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', 
               style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildRouteDetails() {
    final routes = busDetails!['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      return const Text('No route information available');
    }

    final route = routes.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Route Number', route['routeNumber']),
        _buildDetailRow('Start Point', route['startPoint']),
        _buildDetailRow('End Point', route['endPoint']),
        _buildDetailRow('Departure Time', 
            route['departureTimes']?.first?.toString()),
        _buildDetailRow('Arrival Time', 
            route['arrivalTimes']?.first?.toString()),
      ],
    );
  }
}