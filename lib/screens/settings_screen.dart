import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BluetoothDevice? selectedDevice;
  List<BluetoothDevice> devicesList = [];
  StreamSubscription<List<ScanResult>>? scanSubscription;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  void _scanDevices() async {
    devicesList.clear();
    scanSubscription?.cancel();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final device = result.device;
        if (!devicesList.any((d) => d.remoteId == device.remoteId)) {
          setState(() {
            devicesList.add(device);
          });
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.platformName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              child: Text('Scan for Bluetooth Devices'),
              onPressed: _scanDevices,
            ),
            SizedBox(height: 16),
            DropdownButton<BluetoothDevice>(
              hint: Text('Select Bluetooth Device'),
              value: selectedDevice,
              onChanged: (BluetoothDevice? value) {
                setState(() {
                  selectedDevice = value;
                });
                if (value != null) {
                  _connectToDevice(value);
                }
              },
              items: devicesList
                  .map((device) => DropdownMenuItem(
                value: device,
                child: Text(
                  device.platformName.isNotEmpty
                      ? device.platformName
                      : device.remoteId.str,
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
