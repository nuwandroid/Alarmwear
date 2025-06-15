import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Text('Battery: 85%'), // Update dynamically
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Press to start your trip'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Icon(Icons.power_settings_new, size: 48),
              onPressed: () {
                // BLE connect or command trigger
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('GPS Tracking'),
              onPressed: () {
                // Enable GPS tracking
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Emergency Contacts'),
              onPressed: () => Navigator.pushNamed(context, '/emergency'),
            ),
          ],
        ),
      ),
    );
  }
}
