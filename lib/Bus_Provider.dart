import 'package:flutter/material.dart';
import 'package:location/location.dart';
// Adjust this import path to where your BusProvider is defined

class BusProvider with ChangeNotifier {
  LocationData? _currentLocation;
  Map<String, dynamic>? _currentBus;

  void updateBusLocation(LocationData location, Map<String, dynamic> bus) {
    _currentLocation = location;
    _currentBus = bus;
    notifyListeners();
  }

  LocationData? get currentLocation => _currentLocation;
  Map<String, dynamic>? get currentBus => _currentBus;
}
