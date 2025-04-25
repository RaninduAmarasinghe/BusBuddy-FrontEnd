import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    connectWebSocket(
      busId: widget.busId,
      onAlertReceived: (data) {
        final alert = jsonDecode(data);
        final type = (alert['type']?.toLowerCase().replaceAll(' ', '') ?? '');
        if (type == 'missingitem' || type == 'complaint') {
          setState(() => hasNewAlert = true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: scheme.primary,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome, ${widget.driverName}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: scheme.onPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [scheme.primaryContainer, scheme.primary],
                    radius: 1.2,
                    center: Alignment(-0.5, -0.6),
                  ),
                ),
                padding: const EdgeInsets.only(left: 24, bottom: 48),
                alignment: Alignment.bottomLeft,
                child: Text(
                  widget.companyName,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                _MenuItem(
                  icon: Icons.account_circle,
                  label: 'Profile',
                  scheme: scheme,
                  onTap: () => _navigateTo(
                    ProfilePage(
                      driverId: widget.driverId,
                      driverName: widget.driverName,
                      driverEmail: widget.driverEmail,
                      companyName: widget.companyName,
                      busId: widget.busId,
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.directions_bus,
                  label: 'Buses',
                  scheme: scheme,
                  onTap: () => _navigateTo(
                    BusesPage(
                      companyId: widget.companyId,
                      busId: widget.busId,
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.notifications,
                  label: 'Alerts',
                  scheme: scheme,
                  showDot: hasNewAlert,
                  onTap: () {
                    setState(() => hasNewAlert = false);
                    _navigateTo(
                      NotificationsPage(
                        companyId: widget.companyId,
                        busId: widget.busId,
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.message,
                  label: 'Messages',
                  scheme: scheme,
                  onTap: () => _navigateTo(
                    MessagesPage(
                      driverId: widget.driverId,
                      companyId: widget.companyId,
                      driverName: widget.driverName,
                    ),
                  ),
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDot;
  final ColorScheme scheme;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.scheme,
    this.showDot = false,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: widget.scheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.scheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: widget.scheme.primary.withOpacity(0.1),
                    child: Icon(widget.icon,
                        size: 32, color: widget.scheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.scheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (widget.showDot)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.scheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
