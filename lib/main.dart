import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(AlarmwareApp());

class AlarmwareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarmware',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/home': (context) => HomeScreen(),
        '/emergency': (context) => EmergencyScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
