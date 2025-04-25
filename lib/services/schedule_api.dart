import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:busbuddy_frontend/models/bus_schedule.dart'; // Adjust import path

Future<List<BusSchedule>> fetchBusSchedules() async {
  final response = await http.get(Uri.parse(
      'https://busbuddy.ngrok.app/bus/schedules')); // Use correct IP and port

  if (response.statusCode == 200) {
    List<dynamic> schedulesJson = jsonDecode(response.body);
    return schedulesJson.map((json) => BusSchedule.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bus schedules');
  }
}
