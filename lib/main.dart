import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bus_provider.dart'; // Ensure this path is correct
import 'package:busbuddy_frontend/main_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BusProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // Customize the theme here
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: MainPage(), // Ensure MainPage is correctly imported and used
    );
  }
}
