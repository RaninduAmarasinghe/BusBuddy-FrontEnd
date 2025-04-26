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
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Timer? _locationTimer;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.latitude, widget.longitude);
    _updateMarker(_currentPosition!);

    connectWebSocket(
      busId: widget.busId,
      onLocationReceived: (data) {
        final location = jsonDecode(data);
        final lat = location['latitude'];
        final lng = location['longitude'];

        if (lat != null && lng != null) {
          final newPosition = LatLng(lat, lng);
          _updateMarker(newPosition);

          if (_mapController != null) {
            _mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
          }
        }
      },
    );

    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshLocation(),
    );
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _currentPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId("bus"),
          position: position,
          infoWindow: const InfoWindow(title: "Bus Location"),
        ),
      };
    });
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
          final newPosition =
              LatLng(location['latitude'], location['longitude']);
          _updateMarker(newPosition);

          if (_mapController != null) {
            _mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
          }
        }
      }
    } catch (e) {
      debugPrint("Error refreshing location: $e");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    stompClient.deactivate();
    super.dispose();
  }

  void _showAlertDialog(String type) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final messageController = TextEditingController();

    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            type == 'MissingItem' ? 'Report Missing Item' : 'File a Complaint',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: type == 'MissingItem'
                        ? 'What did you lose?'
                        : 'What is your complaint?',
                  ),
                  maxLines: 3,
                ),
                if (isSending)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          contactController.text.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please fill all required fields')),
                          );
                        }
                        return;
                      }

                      setState(() => isSending = true);

                      try {
                        if (stompClient.connected) {
                          stompClient.send(
                            destination: '/app/alert',
                            body: jsonEncode({
                              "busId": widget.busId,
                              "companyId": widget.companyId,
                              "senderName": nameController.text.trim(),
                              "contactNumber": contactController.text.trim(),
                              "message": messageController.text.trim(),
                              "type": type,
                            }),
                          );

                          await Future.delayed(
                              const Duration(milliseconds: 500));

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Message sent successfully')),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Connection lost. Please try again')),
                            );
                          }
                        }
                      } catch (e) {
                        debugPrint('Send error: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to send message')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isSending = false);
                      }
                    },
              child: const Text('Send'),
            ),
          ],
        ),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 15,
                      ),
                      markers: _markers,
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
      ),
    );
  }
}
