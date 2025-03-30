import 'package:flutter/material.dart';
import 'package:busbuddy_frontend/Driver/buses_page.dart';

class HomePage extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String driverName;

  const HomePage({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.driverName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Company and Driver Info)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.companyName.isEmpty
                          ? 'Loading...'
                          : widget.companyName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.driverName.isEmpty
                          ? 'Loading...'
                          : "Hi, ${widget.driverName}",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Spacer
            SizedBox(height: 30),

            // Buttons Section (Grid of actions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildCardButton(
                    icon: Icons.account_circle,
                    label: "Profile",
                    onTap: () {
                      // Navigate to Profile Page (Add Profile page later)
                      print("Profile button clicked");
                    },
                  ),
                  _buildCardButton(
                    icon: Icons.directions_bus,
                    label: "Buses",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BusesPage(companyId: widget.companyId),
                        ),
                      );
                    },
                  ),
                  _buildCardButton(
                    icon: Icons.notifications,
                    label: "Notifications",
                    onTap: () {
                      print("Notifications button clicked");
                      // Navigate to Notifications page
                    },
                  ),
                  _buildCardButton(
                    icon: Icons.message,
                    label: "Messages",
                    onTap: () {
                      print("Messages button clicked");
                      // Navigate to Messages page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create a card button
  Widget _buildCardButton({
    required IconData icon,
    required String label,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
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