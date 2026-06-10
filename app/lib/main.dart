import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'providers/user_provider.dart';
import 'providers/venue_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/login_screen.dart';

void main() {
  final apiService = MockApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(apiService)),
        ChangeNotifierProvider(create: (_) => VenueProvider(apiService)),
        ChangeNotifierProvider(create: (_) => BookingProvider(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickSlot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
