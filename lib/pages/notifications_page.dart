import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Welcome!"),
            subtitle: Text("We’ll show places near you based on GPS."),
          ),
          ListTile(
            title: Text("Tip"),
            subtitle: Text("Use category chips to filter places."),
          ),
        ],
      ),
    );
  }
}
