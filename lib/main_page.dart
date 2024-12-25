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
          //3
          children: [
            Row(
              //3
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Ensures spacing
              children: [
                Column(
                  //2
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image(
                        image: AssetImage("assets/shedule.png"),
                      ),
                    ),
                    Text("Schedule"), // Fixed typo
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image(
                        image: AssetImage("assets/location.png"),
                      ),
                    ),
                    Text("Location"),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image(
                        image: AssetImage("assets/bus.png"),
                      ),
                    ),
                    Text("Bus"),
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
