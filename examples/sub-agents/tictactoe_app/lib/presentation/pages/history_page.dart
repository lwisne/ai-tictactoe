import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Game History page with standard back button behavior
///
/// As specified in LWI-151, history should have a back button that returns
/// to the previous screen without confirmation.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        // Standard back button - automatically provided by Flutter
        // Uses go_router's navigation when pressed
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 100, color: Colors.orange),
            SizedBox(height: 24),
            Text(
              'Game History',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Your past games will appear here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
