import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:busbuddy_frontend/components/my_button.dart';
import 'package:busbuddy_frontend/components/mytextfield.dart';
import 'package:busbuddy_frontend/main_page.dart';
import 'package:busbuddy_frontend/Driver/home_page.dart';

class Login extends StatefulWidget {
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

        // Parse the response body and extract the necessary data
        var data = jsonDecode(response.body);
        String companyId = data['companyId'];
        String companyName = data['companyName'];
        String driverName = data['driverName'];
        String busId = data['busId']; // Changed from busNumber to busId

        // Navigate to HomePage with the extracted data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              companyId: companyId,
              companyName: companyName,
              driverName: driverName,
              busId: busId, // Changed from busNumber to busId
            ),
          ),
        );
      } else {
        // Show error dialog if login fails
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Login Failed"),
            content: Text("Invalid email or password"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Invalid email or password');
      }
    } catch (e) {
      // Show error dialog if there is a network issue or any exception
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Something went wrong. Please try again later."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
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
                onTap: loginDriver, // Trigger login function on tap
              ),
            ],
          ),
        ),
      ),
    );
  }
}
