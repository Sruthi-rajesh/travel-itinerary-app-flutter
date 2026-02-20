import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/home_page.dart';
import 'package:travel_app/pages/favourites_page.dart';
import 'package:travel_app/pages/tickets_page.dart';
import 'package:travel_app/pages/profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.allPlaces});
  final List<Place> allPlaces;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(allPlaces: widget.allPlaces),
      FavouritesPage(allPlaces: widget.allPlaces),
      TicketsPage(),   
      const ProfilePage(),   
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Ionicons.home_outline), label: "Home"),
          NavigationDestination(icon: Icon(Ionicons.bookmark_outline), label: "Saved"),
          NavigationDestination(icon: Icon(Ionicons.ticket_outline), label: "Tickets"),
          NavigationDestination(icon: Icon(Ionicons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
