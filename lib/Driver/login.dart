import 'package:busbuddy_frontend/components/my_button.dart';
import 'package:busbuddy_frontend/components/mytextfield.dart';
import 'package:busbuddy_frontend/main_page.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  Login({super.key});

//text editing controllers

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method

  void signUserIn() {}
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
            MyTextField(
              controller: usernameController,
              hintText: "Username",
              obsecureText: false,
            ),
            const SizedBox(height: 10),
            //password
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obsecureText: true,
            ),

            //Login button
            const SizedBox(height: 25),
            MyButton(
              onTap: signUserIn,
            ),
          ],
        ),
      )),
    );
  }
}
