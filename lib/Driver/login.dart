import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:busbuddy_frontend/components/my_button.dart';
import 'package:busbuddy_frontend/components/mytextfield.dart';
import 'package:busbuddy_frontend/main_page.dart';
import 'package:busbuddy_frontend/Driver/home_page.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  // Change this to StatefulWidget
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Function to make POST request for driver login
  Future<void> loginDriver() async {
    final url = Uri.parse(
        'http://localhost:8080/driver/login'); // URL of your Spring Boot backend

    final body = jsonEncode({
      'driverEmail': usernameController.text,
      'driverPassword': passwordController.text,
    });

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        print('Login successful');
        // Navigate to the next page after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('Invalid email or password');
        // Optionally show an alert dialog to the user
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Icon(Icons.lock, size: 100),
              const SizedBox(height: 50),
              Text(
                "Welcome Back",
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: usernameController,
                hintText: "Email",
                obsecureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obsecureText: true,
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: loginDriver,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
