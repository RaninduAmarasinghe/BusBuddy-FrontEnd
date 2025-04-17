import 'package:flutter/material.dart';
import 'package:busbuddy_frontend/models/bus_schedule.dart';
import 'package:busbuddy_frontend/services/schedule_api.dart'; // adjust path

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // Transparent AppBar for a modern, futuristic look.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Dark gradient background.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // SafeArea ensures content is not hidden by system overlays.
        child: SafeArea(
          child: FutureBuilder<List<BusSchedule>>(
            future: fetchBusSchedules(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              } else {
                // Add extra top padding so that the list appears lower (adjust as needed).
                return ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 16, right: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    BusSchedule schedule = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(4, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          title: Text(
                            '${schedule.busNumber} - ${schedule.routeNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'From ${schedule.startPoint} to ${schedule.endPoint}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            '${schedule.departureTime} - ${schedule.arrivalTime}',
                            style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
