import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

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
  static const String baseUrl = 'http://192.168.8.102:8080';
  Map<String, dynamic>? busDetails;
  bool isRunning = false;

  final Location location = Location();
  LocationData? _currentLocation;
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  bool _isLocationListening = false;

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
  }

  @override
  void dispose() {
    super.dispose();
    // Don't disable location or stop trip here; driver must explicitly stop
  }

  Future<void> fetchBusDetails() async {
    final url = Uri.parse('$baseUrl/bus/details/${widget.busId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          busDetails = jsonDecode(response.body);
          isRunning = busDetails!["status"] == "Running";
          if (isRunning) _startLocationUpdates();
        });
      } else {
        setState(() => busDetails = {'error': 'Failed to load bus details'});
      }
    } catch (e) {
      setState(() => busDetails = {'error': 'Error: $e'});
    }
  }

  Future<void> _startLocationUpdates() async {
    if (_isLocationListening) return;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    await location.enableBackgroundMode(enable: true);
    location.changeSettings(interval: 5000, distanceFilter: 10);

    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (!isRunning) return;
      _currentLocation = currentLocation;

      final url = Uri.parse('$baseUrl/bus/update-location/${widget.busId}');
      try {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude,
          }),
        );
        print(
            "Location sent: ${currentLocation.latitude}, ${currentLocation.longitude}");
      } catch (e) {
        print("Error sending location: $e");
      }
    });

    _isLocationListening = true;
  }

  Future<void> startTrip() async {
    final url = Uri.parse('$baseUrl/bus/startTrip/${widget.busId}');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        setState(() => isRunning = true);
        await _startLocationUpdates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip started')),
        );
      } else {
        throw Exception("Failed to start trip");
      }
    } catch (e) {
      print("Start trip error: $e");
    }
  }

  Future<void> stopTrip() async {
    final url = Uri.parse('$baseUrl/bus/stopTrip/${widget.busId}');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        setState(() => isRunning = false);
        await location.enableBackgroundMode(enable: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip stopped')),
        );
      } else {
        throw Exception("Failed to stop trip");
      }
    } catch (e) {
      print("Stop trip error: $e");
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
    if (busDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (busDetails!.containsKey('error')) {
      return Center(
        child: Text(
          busDetails!['error'],
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: isRunning ? null : startTrip,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Start Trip"),
                        ),
                        ElevatedButton(
                          onPressed: isRunning ? stopTrip : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("Stop Trip"),
                        ),
                      ],
                    ),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        _buildDetailRow('Departure Time', route['departureTimes']?.first),
        _buildDetailRow('Arrival Time', route['arrivalTimes']?.first),
      ],
    );
  }
}
