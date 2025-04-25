import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class BusesPage extends StatefulWidget {
  final String companyId;
  final String busId;

  const BusesPage({super.key, required this.companyId, required this.busId});

  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> with TickerProviderStateMixin {
  static const String baseUrl = 'https://busbuddy.ngrok.app';

  Map<String, dynamic>? busDetails;
  bool isRunning = false;

  final Location location = Location();
  LocationData? _currentLocation;
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  bool _isLocationListening = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    fetchBusDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await fetchBusDetails();
  }

  // Networking
  Future<void> fetchBusDetails() async {
    setState(() => busDetails = null);
    final url = Uri.parse('$baseUrl/bus/details/${widget.busId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          busDetails = data;
          isRunning = data["status"] == "Running";
        });
        if (isRunning) _startLocationUpdates();
      } else {
        setState(() => busDetails = {'error': 'Failed to load bus details'});
      }
    } catch (e) {
      setState(() => busDetails = {'error': 'Error: $e'});
    } finally {
      _fadeController.forward(from: 0);
    }
  }

  // Location services
  Future<void> _startLocationUpdates() async {
    if (_isLocationListening) return;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled && !(await location.requestService())) return;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied &&
        (await location.requestPermission()) != PermissionStatus.granted) {
      return;
    }

    await location.enableBackgroundMode(enable: true);
    location.changeSettings(
        interval: 5000, accuracy: LocationAccuracy.high, distanceFilter: 0);

    location.onLocationChanged.listen((currentLocation) {
      if (!isRunning) return;
      _currentLocation = currentLocation;
      http.post(
        Uri.parse('$baseUrl/bus/update-location/${widget.busId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        }),
      );
    });

    _isLocationListening = true;
  }

  // Trip control
  Future<void> startTrip() async {
    try {
      final resp =
          await http.post(Uri.parse('$baseUrl/bus/startTrip/${widget.busId}'));
      if (resp.statusCode == 200) {
        setState(() => isRunning = true);
        await _startLocationUpdates();
        _showSnack('Trip started');
      } else {
        throw Exception();
      }
    } catch (_) {
      _showSnack('Error starting trip');
    }
  }

  Future<void> stopTrip() async {
    try {
      final resp =
          await http.post(Uri.parse('$baseUrl/bus/stopTrip/${widget.busId}'));
      if (resp.statusCode == 200) {
        setState(() => isRunning = false);
        await location.enableBackgroundMode(enable: false);
        _showSnack('Trip stopped');
      } else {
        throw Exception();
      }
    } catch (_) {
      _showSnack('Error stopping trip');
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // UI
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Bus Details'),
        centerTitle: true,
        backgroundColor: cs.primary,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: 80,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildBody(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isRunning
            ? FloatingActionButton.extended(
                key: const ValueKey('stop'),
                onPressed: stopTrip,
                backgroundColor: cs.error,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Trip'),
              )
            : FloatingActionButton.extended(
                key: const ValueKey('start'),
                onPressed: startTrip,
                backgroundColor: cs.secondary,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Trip'),
              ),
      ),
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

    return ListView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        _buildAnimatedCard(_buildHeaderCard()),
        const SizedBox(height: 16),
        _buildAnimatedCard(_buildRouteCard()),
        if (isRunning && _currentLocation != null) ...[
          const SizedBox(height: 16),
          _buildAnimatedCard(_buildLocationCard()),
        ],
      ],
    );
  }

  Widget _buildAnimatedCard(Widget child) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: child,
    );
  }

  //
  // Cards
  Widget _buildHeaderCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _detailTile('Bus ID', busDetails!['busId'], Icons.badge),
            const Divider(height: 24),
            _detailTile('Bus Number', busDetails!['busNumber'],
                Icons.directions_bus_filled),
            const Divider(height: 24),
            _detailTile('Status', busDetails!['status'], Icons.timelapse,
                valueColor: isRunning ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard() {
    final routes = busDetails!['routes'] as List?;
    if (routes == null || routes.isEmpty) return const SizedBox.shrink();
    final route = routes.first;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route Details',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            _detailTile('Route Number', route['routeNumber'], Icons.alt_route),
            const SizedBox(height: 12),
            _detailTile('Start Point', route['startPoint'], Icons.trip_origin),
            const SizedBox(height: 12),
            _detailTile('End Point', route['endPoint'], Icons.flag),
            const SizedBox(height: 12),
            _detailTile('Departure Time', route['departureTimes']?.first,
                Icons.schedule),
            const SizedBox(height: 12),
            _detailTile('Arrival Time', route['arrivalTimes']?.first,
                Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: const Icon(Icons.my_location, size: 32),
        title: const Text('Current Location',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${_currentLocation!.latitude?.toStringAsFixed(5)}, '
          '${_currentLocation!.longitude?.toStringAsFixed(5)}',
        ),
      ),
    );
  }

  //
  // Helpers
  Widget _detailTile(String label, dynamic value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon,
              size: 24,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text(
          value?.toString() ?? 'N/A',
          style: TextStyle(color: valueColor ?? Colors.grey[800], fontSize: 16),
        ),
      ],
    );
  }
}
