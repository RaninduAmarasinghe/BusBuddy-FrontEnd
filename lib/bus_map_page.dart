import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String busId; // <-- Add this!

  const BusMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.busId,
  });

  @override
  State<BusMapPage> createState() => _BusMapPageState();
}

class _BusMapPageState extends State<BusMapPage> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.latitude, widget.longitude);
  }

  Future<void> _refreshLocation() async {
    final url =
        Uri.parse("http://192.168.8.101:8080/bus/details/${widget.busId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['location'];
        if (location != null &&
            location['latitude'] != null &&
            location['longitude'] != null) {
          setState(() {
            _currentPosition =
                LatLng(location['latitude'], location['longitude']);
            _mapController
                .animateCamera(CameraUpdate.newLatLng(_currentPosition!));
          });
        }
      } else {
        print("Failed to fetch updated location.");
      }
    } catch (e) {
      print("Error refreshing location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
          ),
        ],
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("bus"),
                  position: _currentPosition!,
                  infoWindow: const InfoWindow(title: "Bus"),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}
