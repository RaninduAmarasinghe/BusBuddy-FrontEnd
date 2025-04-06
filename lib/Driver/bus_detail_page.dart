import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:busbuddy_frontend/Bus_Provider.dart'; // Ensure this path is correct

class BusDetailPage extends StatefulWidget {
  final Map<String, dynamic> bus;
  final VoidCallback onStatusChange; // Adding the callback here

  const BusDetailPage({
    super.key,
    required this.bus,
    required this.onStatusChange, // Ensure this is required or provide a default value
  });

  @override
  _BusDetailPageState createState() => _BusDetailPageState();
}

class _BusDetailPageState extends State<BusDetailPage> {
  bool isRunning = false;
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
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

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
      Provider.of<BusProvider>(context, listen: false)
          .updateBusLocation(currentLocation, widget.bus);
    });
  }

  void toggleBusStatus(bool start) {
    setState(() {
      isRunning = start;
    });
    // Here you would also handle other logic related to starting or stopping the bus
  }

  void startTrip() async {
    if (!_serviceEnabled || _permissionGranted != PermissionStatus.granted) {
      await _checkLocationPermission();
    }

    if (_serviceEnabled && _permissionGranted == PermissionStatus.granted) {
      location.enableBackgroundMode(enable: true);
      toggleBusStatus(true);
    }
  }

  void stopTrip() {
    location.enableBackgroundMode(enable: false);
    toggleBusStatus(false);
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Route: ${widget.bus['routeName']}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Capacity: ${widget.bus['capacity']}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Status: ${isRunning ? 'Running' : 'Stopped'}",
                style: TextStyle(
                    fontSize: 16,
                    color: isRunning ? Colors.green : Colors.red)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startTrip,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Start Trip"),
                ),
                ElevatedButton(
                  onPressed: stopTrip,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Stop Trip"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
