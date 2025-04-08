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
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
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
            _mapController.animateCamera(
              CameraUpdate.newLatLng(_currentPosition!),
            );
          });
        }
      }
    } catch (e) {
      print("Error refreshing location: $e");
    }
  }

  void _showAlertForm({required String type}) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final messageController = TextEditingController();

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title:
              Text(type == "MissingItem" ? "Missing Item Alert" : "Complaint"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Your Name')),
                TextField(
                    controller: contactController,
                    decoration: InputDecoration(labelText: 'Contact Number')),
                TextField(
                    controller: messageController,
                    decoration: InputDecoration(labelText: 'Details')),
                if (isSubmitting)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);

                      try {
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

                        await Future.delayed(
                            Duration(milliseconds: 500)); // smooth out
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Alert sent successfully')),
                        );
                      } catch (e) {
                        print("WebSocket send error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to send alert')),
                        );
                      } finally {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: Text("Submit"),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Location"),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshLocation),
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
                        infoWindow: const InfoWindow(title: "Bus"),
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAlertForm(type: "MissingItem"),
                    icon:
                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                    label: Text("Missing Item"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAlertForm(type: "Complaint"),
                    icon: Icon(Icons.report_problem, color: Colors.white),
                    label: Text("Complaint"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
