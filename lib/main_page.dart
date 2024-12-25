import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Buddy"),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 15),
          child: Image(
            image: AssetImage("assets/bus.png"),
          ),
        ),
        actions: [IconButton(icon: Icon(Icons.person), onPressed: () {})],
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              // First Row
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print("Schedule clicked");
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: AssetImage("assets/shedule.png"),
                        ),
                      ),
                    ),
                    Text("Schedule"),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print("Active Buses clicked");
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: AssetImage("assets/activebus.png"),
                        ),
                      ),
                    ),
                    Text("Active Buses"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20), // Add spacing between rows
            Row(
              // Second Row
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print("Schedule clicked");
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: AssetImage("assets/help-desk.png"),
                        ),
                      ),
                    ),
                    Text("Help & Support"),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print("Location clicked");
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: AssetImage("assets/information.png"),
                        ),
                      ),
                    ),
                    Text("About Us"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
