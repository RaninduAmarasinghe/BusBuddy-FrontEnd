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
      body: const Center(
        child: Text("Welcome to Bus Buddy"),
      ),
    );
  }
}
