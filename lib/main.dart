import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:travel_app/data/places_repository.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/welcome_page.dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<List<Place>> _loadPlaces() {
    return PlacesRepository().loadMelbournePlaces();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        textTheme: GoogleFonts.mulishTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: FutureBuilder<List<Place>>(
        future: _loadPlaces(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _Splash();
          }
          if (snap.hasError || !snap.hasData) {
            return _ErrorScreen(error: snap.error.toString());
          }
          return WelcomePage(allPlaces: snap.data!);
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text("Failed to load places.\n\n$error"),
        ),
      ),
    );
  }
}
