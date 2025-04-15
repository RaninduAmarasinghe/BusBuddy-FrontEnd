import 'package:flutter/material.dart';
import 'package:busbuddy_frontend/models/bus_schedule.dart';
import 'package:busbuddy_frontend/services/schedule_api.dart'; // adjust path

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<BusSchedule>>(
        future: fetchBusSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                BusSchedule schedule = snapshot.data![index];
                return ListTile(
                  title:
                      Text('${schedule.busNumber} - ${schedule.routeNumber}'),
                  subtitle: Text(
                      'From ${schedule.startPoint} to ${schedule.endPoint}'),
                  trailing: Text(
                      '${schedule.departureTime} - ${schedule.arrivalTime}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
