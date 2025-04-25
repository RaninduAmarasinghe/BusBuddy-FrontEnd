import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:busbuddy_frontend/Driver/login.dart';
import 'active_buses_page.dart';
import 'schedule_page.dart';
import 'about_us_page.dart';
import 'help_support_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Location permission is required to track buses in real time. Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/bus.png",
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Bus Buddy",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.person,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Enhanced Welcome Message
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Welcome to Bus Buddy! Ready to hit the road? Tap an option below to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Raised grid of buttons
                Expanded(
                  child: Align(
                    // moved higher by increasing negative Y value
                    alignment: const Alignment(0, -0.5),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildMenuItem("assets/shedule.png", "Schedule", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchedulePage(),
                            ),
                          );
                        }),
                        _buildMenuItem("assets/activebus.png", "Active Buses",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ActiveBusesPage(),
                            ),
                          );
                        }),
                        _buildMenuItem("assets/help-desk.png", "Help & Support",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportPage(),
                            ),
                          );
                        }),
                        _buildMenuItem("assets/information.png", "About Us",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        }),
                      ],
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

  Widget _buildMenuItem(String imagePath, String title, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, width: 60, height: 60),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
