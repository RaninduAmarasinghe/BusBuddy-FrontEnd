import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:busbuddy_frontend/services/websocket_service.dart';

class BusMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String busId;
  final String companyId;

  const BusMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.busId,
    required this.companyId,
  });

  @override
  State<BusMapPage> createState() => _BusMapPageState();
}

class _BusMapPageState extends State<BusMapPage> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.latitude, widget.longitude);

    connectWebSocket(
      busId: widget.busId,
      onLocationReceived: (data) {
        final location = jsonDecode(data);
        final lat = location['latitude'];
        final lng = location['longitude'];

        if (lat != null && lng != null) {
          setState(() {
            _currentPosition = LatLng(lat, lng);
            _mapController.animateCamera(
              CameraUpdate.newLatLng(_currentPosition!),
            );
          });
        }
      },
    );

    _locationTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshLocation(),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    stompClient.deactivate();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    final url =
        Uri.parse("https://busbuddy.ngrok.app/bus/details/${widget.busId}");
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
            _mapController.animateCamera(
              CameraUpdate.newLatLng(_currentPosition!),
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Error refreshing location: $e");
    }
  }

  void _showAlertDialog(String type) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            type == 'MissingItem' ? 'Report Missing Item' : 'File a Complaint'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: type == 'MissingItem'
                      ? 'What did you lose?'
                      : 'What is your complaint?',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  contactController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all required fields')),
                );
                return;
              }

              stompClient.send(
                destination: '/app/alert',
                body: jsonEncode({
                  "busId": widget.busId,
                  "companyId": widget.companyId,
                  "senderName": nameController.text,
                  "contactNumber": contactController.text,
                  "message": messageController.text,
                  "type": type,
                }),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent successfully')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Bus Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
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
                        infoWindow: const InfoWindow(title: "Bus Location"),
                      )
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.report_problem),
                    label: const Text("Complaint"),
                    onPressed: () => _showAlertDialog("Complaint"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.warning),
                    label: const Text("Missing Item"),
                    onPressed: () => _showAlertDialog("MissingItem"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
