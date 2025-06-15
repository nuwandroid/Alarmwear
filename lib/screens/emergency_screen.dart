import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final Telephony telephony = Telephony.instance;
  final List<TextEditingController> contactControllers =
  List.generate(4, (_) => TextEditingController());
  final TextEditingController messageController = TextEditingController();

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<bool> _requestPermissions() async {
    var sms = await Permission.sms.status;
    var loc = await Permission.location.status;

    if (!sms.isGranted) sms = await Permission.sms.request();
    if (!loc.isGranted) loc = await Permission.location.request();

    return sms.isGranted && loc.isGranted;
  }

  void _sendEmergencyMessage() async {
    try {
      final granted = await _requestPermissions();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissions denied')),
        );
        return;
      }

      Position position = await _getCurrentLocation();

      String locationMessage =
          'Emergency! My current location is: https://maps.google.com/?q=${position.latitude},${position.longitude}';

      String fullMessage = '${messageController.text}\n$locationMessage';

      List<String> contacts = contactControllers
          .map((c) => c.text.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one contact number.')),
        );
        return;
      }
      if (messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter an emergency message.')),
        );
        return;
      }

      for (String number in contacts) {
        await telephony.sendSms(
          to: number,
          message: fullMessage,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Messages sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    for (var c in contactControllers) c.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(
              4,
                  (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: contactControllers[i],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact Number ${i + 1}',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Emergency Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendEmergencyMessage,
        label: Text('Test'),
        icon: Icon(Icons.send),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
