import 'package:busbuddy_frontend/main_page.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back), // Corrected `Icon` (capitalized)
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MainPage()));
            }),
      ),
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),

            //logo
            Icon(Icons.lock, size: 100),

            const SizedBox(height: 50),
            // welcome back
            Text(
              "Welcome Back",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),

            const SizedBox(height: 25),
            //username
            TextField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  )),
            ),
          ],
        ),
      )),
    );
  }
}
