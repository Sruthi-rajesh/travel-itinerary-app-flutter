import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/itinerary_page.dart';
import 'package:travel_app/services/weather_service.dart';
import 'package:travel_app/services/favourites_store.dart';
import 'package:travel_app/widgets/distance.dart';
import 'package:travel_app/widgets/place_map.dart';

class TouristDetailsPage extends StatefulWidget {
  const TouristDetailsPage({
    Key? key,
    required this.place,
  }) : super(key: key);

  final Place place;

  @override
  State<TouristDetailsPage> createState() => _TouristDetailsPageState();
}

class _TouristDetailsPageState extends State<TouristDetailsPage> {
  final _weather = WeatherService();
  late final Future<WeatherResult> _weatherFuture =
      _weather.fetchWeather(widget.place.lat, widget.place.lng);

  bool get _isFav => FavouritesStore.isFavourite(widget.place.id);

  void _toggleFav() {
    setState(() => FavouritesStore.toggle(widget.place.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFav ? "Saved to favourites ✅" : "Removed from favourites ❌"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Messaging coming soon 💬"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final w = MediaQuery.of(context).size.width;
    final bool wide = w >= 800;
    final double topHeight = wide ? 280 : 240;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            wide
                ? Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: topHeight,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(place.image, fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.05),
                                        Colors.black.withOpacity(0.25),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.80),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => Navigator.pop(context),
                                          iconSize: 20,
                                          icon: const Icon(Ionicons.chevron_back),
                                        ),
                                        IconButton(
                                          iconSize: 20,
                                          onPressed: _toggleFav,
                                          icon: Icon(
                                            _isFav ? Ionicons.heart : Ionicons.heart_outline,
                                            color: _isFav ? Colors.red : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: topHeight,
                            child: PlaceMap(lat: place.lat, lng: place.lng),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: topHeight,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(place.image, fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.05),
                                      Colors.black.withOpacity(0.25),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.80),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        iconSize: 20,
                                        icon: const Icon(Ionicons.chevron_back),
                                      ),
                                      IconButton(
                                        iconSize: 20,
                                        onPressed: _toggleFav,
                                        icon: Icon(
                                          _isFav ? Ionicons.heart : Ionicons.heart_outline,
                                          color: _isFav ? Colors.red : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: PlaceMap(lat: place.lat, lng: place.lng),
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(place.address, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openMessage,
                  iconSize: 20,
                  icon: const Icon(Ionicons.chatbubble_ellipses_outline),
                ),
                Column(
                  children: [
                    Text(place.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall),
                    Icon(Ionicons.star, color: Colors.yellow[800], size: 15),
                  ],
                )
              ],
            ),

            const SizedBox(height: 16),
            Text("Location", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(place.address, style: Theme.of(context).textTheme.bodySmall),

            const SizedBox(height: 12),

            FutureBuilder<WeatherResult>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _WeatherCard.loading();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const _WeatherCard.error("Could not load weather");
                }

                final ww = snapshot.data!;
                final advice = _weather.clothingSuggestion(ww.tempC, ww.rainProb);

                return _WeatherCard(tempC: ww.tempC, rainProb: ww.rainProb, advice: advice);
              },
            ),

            const SizedBox(height: 14),
            Distance(place: place),
            const SizedBox(height: 90),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ItineraryPage(place: place)),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text("Build itinerary for this place"),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.tempC,
    required this.rainProb,
    required this.advice,
  }) : _state = _CardState.normal;

  const _WeatherCard.loading()
      : tempC = 0,
        rainProb = 0,
        advice = "Loading weather...",
        _state = _CardState.loading;

  const _WeatherCard.error(this.advice)
      : tempC = 0,
        rainProb = 0,
        _state = _CardState.error;

  final double tempC;
  final int rainProb;
  final String advice;
  final _CardState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      ),
      child: _state == _CardState.loading
          ? const Row(
              children: [
                SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 10),
                Text("Loading weather..."),
              ],
            )
          : _state == _CardState.error
              ? Text(advice)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Weather now", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text("Temperature: ${tempC.toStringAsFixed(1)}°C"),
                    Text("Rain chance: $rainProb%"),
                    const SizedBox(height: 8),
                    Text(advice),
                  ],
                ),
    );
  }
}

enum _CardState { normal, loading, error }
