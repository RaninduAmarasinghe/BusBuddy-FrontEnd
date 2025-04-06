import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const BusMapPage(
      {super.key, required this.latitude, required this.longitude});

  @override
  State<BusMapPage> createState() => _BusMapPageState();
}

class _BusMapPageState extends State<BusMapPage> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  late String busId; // You can pass this via constructor if needed

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.latitude, widget.longitude);
  }

  void _refreshLocation() async {
    final url = Uri.parse(
        "http://192.168.8.102:8080/bus/details/YOUR_BUS_ID"); // replace with actual
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
      }
    } catch (e) {
      print("Failed to refresh location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshLocation,
          )
        ],
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("bus"),
                  position: _currentPosition!,
                  infoWindow: InfoWindow(title: "Bus"),
                )
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}
