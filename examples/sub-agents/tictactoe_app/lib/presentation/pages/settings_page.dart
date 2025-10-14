import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings page with standard back button behavior
///
/// As specified in LWI-151, settings should have a back button that returns
/// to the previous screen without confirmation.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Standard back button - automatically provided by Flutter
        // Uses go_router's navigation when pressed
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 100, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Game settings will be configured here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
