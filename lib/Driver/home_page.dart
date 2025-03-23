import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:busbuddy_frontend/Driver/buses_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String companyName = "";
  String driverName = "";
  String companyId = ""; // Store company ID

  // Example: Login API endpoint for driver authentication
  Future<void> fetchDriverData(
      String driverEmail, String driverPassword) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/driver/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'driverEmail': driverEmail,
        'driverPassword': driverPassword,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        companyName = data['companyName']; // Use companyName from the response
        driverName = data['driverName']; // Use driverName from the response
        companyId = data['companyId']; // Get company ID from response
      });
    } else {
      print('Failed to login: ${response.body}');
      setState(() {
        companyName = 'Error fetching data';
        driverName = 'Error';
      });
    }
  }

  // Fetching buses by company ID (you can call this after login)
  Future<void> fetchBusesByCompany(String companyId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/bus/company/$companyId'),
    );

    if (response.statusCode == 200) {
      List buses = json.decode(response.body);
      print(buses); // Print the list of buses
    } else {
      print('Failed to fetch buses: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDriverData('dr@gmail.com', 'password123'); // Example login credentials
  }

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
            // Top Section
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
                      companyName.isEmpty
                          ? 'Loading...'
                          : companyName, // Show loading text
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      driverName.isEmpty
                          ? 'Loading...'
                          : "Hi, $driverName", // Show loading text
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

            // Buttons Section
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
                      // Navigate to Profile page
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
                          builder: (context) => BusesPage(companyId: companyId),
                        ),
                      );
                    },
                  ),
                  _buildCardButton(
                    icon: Icons.notifications,
                    label: "Notifications",
                    onTap: () {
                      // Navigate to Notifications page
                      print("Notifications button clicked");
                    },
                  ),
                  _buildCardButton(
                    icon: Icons.message,
                    label: "Messages",
                    onTap: () {
                      // Navigate to Messages page
                      print("Messages button clicked");
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
