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

  Future<void> loginDriver() async {
    final url = Uri.parse('http://192.168.8.101:8080/driver/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'driverEmail': usernameController.text.trim(),
      'driverPassword': passwordController.text.trim(),
    });

    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        print('✅ Login successful');

        final data = jsonDecode(response.body);

        // Fallbacks in case fields are missing
        final driverId = data['driverId']?.toString() ?? '';
        final driverName = data['driverName'] ?? '';
        final driverEmail = data['driverEmail'] ?? '';
        final companyId = data['companyId'] ?? '';
        final companyName = data['companyName'] ?? '';
        final busId = data['busId'] ?? '';

        print("📦 Decoded login data:");
        print("driverId: $driverId");
        print("driverName: $driverName");
        print("driverEmail: $driverEmail");
        print("companyId: $companyId");
        print("companyName: $companyName");
        print("busId: $busId");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              driverId: driverId,
              driverName: driverName,
              driverEmail: driverEmail,
              companyId: companyId,
              companyName: companyName,
              busId: busId,
            ),
          ),
        );
      } else {
        _showErrorDialog("Login Failed", "Invalid email or password.");
      }
    } catch (e) {
      print('❌ Error during login: $e');
      _showErrorDialog(
          "Error", "Something went wrong. Please try again later.");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Icon(Icons.lock, size: 100),
                      const SizedBox(height: 40),
                      Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.grey[700], fontSize: 18),
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
                      const SizedBox(height: 30),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
