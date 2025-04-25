import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String companyName;
  final String busId;

  const ProfilePage({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.companyName,
    required this.busId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Driver Profile'),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        foregroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                driverName,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                companyName,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                icon: Icons.badge_outlined,
                title: 'Driver ID',
                value: driverId,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: driverEmail,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.directions_bus_outlined,
                title: 'Bus ID',
                value: busId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
