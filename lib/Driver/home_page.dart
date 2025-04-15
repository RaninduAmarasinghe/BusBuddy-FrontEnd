import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:busbuddy_frontend/Driver/buses_page.dart';
import 'package:busbuddy_frontend/Driver/notifications_page.dart';
import 'package:busbuddy_frontend/Driver/messages_page.dart';
import 'package:busbuddy_frontend/Driver/profile_page.dart';
import 'package:busbuddy_frontend/services/websocket_service.dart';

class HomePage extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String companyName;
  final String busId;
  final String companyId;

  const HomePage({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.companyName,
    required this.busId,
    required this.companyId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasNewAlert = false;

  @override
  void initState() {
    super.initState();
    print('🚀 HomePage init - connecting WebSocket...');
    connectWebSocket(
      busId: widget.busId,
      onAlertReceived: (data) {
        print("📥 Received alert on HomePage: $data");
        final alert = jsonDecode(data);
        final type = (alert['type']?.toLowerCase().replaceAll(' ', '') ?? '');
        if (type == 'missingitem' || type == 'complaint') {
          setState(() {
            hasNewAlert = true;
            print("🔴 Red dot activated");
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildGridMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.companyName.isEmpty ? 'Loading...' : widget.companyName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.driverName.isEmpty
                ? 'Loading...'
                : "Hi, ${widget.driverName}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildCardButton(
            icon: Icons.account_circle,
            label: "Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    driverId: widget.driverId,
                    driverName: widget.driverName,
                    driverEmail: widget.driverEmail,
                    companyName: widget.companyName,
                    busId: widget.busId,
                  ),
                ),
              );
            },
          ),
          _buildCardButton(
            icon: Icons.directions_bus,
            label: "Buses",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusesPage(
                    companyId: widget.companyId,
                    busId: widget.busId,
                  ),
                ),
              );
            },
          ),
          _buildCardButton(
            icon: Icons.notifications,
            label: "Notifications",
            onTap: () {
              setState(() => hasNewAlert = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(
                    companyId: widget.companyId,
                    busId: widget.busId,
                  ),
                ),
              );
            },
            showDot: hasNewAlert,
          ),
          _buildCardButton(
            icon: Icons.message,
            label: "Messages",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesPage(
                    driverId: widget.driverId,
                    companyId: widget.companyId,
                    driverName: widget.driverName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Icon(icon, size: 50, color: Colors.blueAccent),
                  if (showDot)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
