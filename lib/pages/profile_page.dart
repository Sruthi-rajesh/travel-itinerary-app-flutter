import 'package:flutter/material.dart';
import 'package:travel_app/services/favourites_store.dart';
import 'package:travel_app/services/location_service.dart';
import 'package:travel_app/services/weather_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _displayName = "Guest User";
  String _homeCity = "Not set";

  final _loc = LocationService();
  final _weather = WeatherService();

  late Future<LocationResult> _locFuture;
  Future<WeatherResult>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _reloadLocationAndWeather();
  }

  void _reloadLocationAndWeather() {
    _locFuture = _loc.getLocationWithLabel();
    _weatherFuture = _locFuture.then((loc) => _weather.fetchWeather(loc.lat, loc.lng));
    setState(() {});
  }

  Future<void> _editField({
    required String title,
    required String currentValue,
    required void Function(String) onSave,
    String hint = "",
  }) async {
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              Navigator.pop(context, v.isEmpty ? currentValue : v);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() => onSave(result));
    }
  }

  Future<void> _confirmClearSaved() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear saved places?"),
        content: const Text("This will remove all your saved places."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (ok == true) {
      FavouritesStore.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved places cleared ✅")),
      );
    }
  }

  Widget _card(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _reloadLocationAndWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavouritesStore.favIds, // ✅ correct
        builder: (context, favIds, _) {
          final savedCount = favIds.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                context,
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_displayName, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text("Saved places: $savedCount", style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: "Edit name",
                      onPressed: () => _editField(
                        title: "Edit name",
                        currentValue: _displayName,
                        hint: "Enter your name",
                        onSave: (v) => _displayName = v,
                      ),
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _card(
                context,
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Home city", style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(_homeCity, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: "Edit home city",
                      onPressed: () => _editField(
                        title: "Home city",
                        currentValue: _homeCity,
                        hint: "e.g., Melbourne",
                        onSave: (v) => _homeCity = v,
                      ),
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ✅ Location + Weather
              FutureBuilder<LocationResult>(
                future: _locFuture,
                builder: (context, locSnap) {
                  final loc = locSnap.data ??
                      const LocationResult(
                        lat: LocationService.fallbackLat,
                        lng: LocationService.fallbackLng,
                        label: LocationService.fallbackLabel,
                        isFallback: true,
                      );

                  return _card(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your area", style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          loc.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<WeatherResult>(
                          future: _weatherFuture,
                          builder: (context, wSnap) {
                            if (wSnap.connectionState == ConnectionState.waiting) {
                              return const Row(
                                children: [
                                  SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 10),
                                  Text("Loading weather..."),
                                ],
                              );
                            }
                            if (wSnap.hasError || !wSnap.hasData) {
                              return const Text("Could not load weather right now.");
                            }

                            final w = wSnap.data!;
                            final advice = _weather.clothingSuggestion(w.tempC, w.rainProb);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Temperature: ${w.tempC.toStringAsFixed(1)}°C"),
                                Text("Rain chance: ${w.rainProb}%"),
                                const SizedBox(height: 6),
                                Text(advice),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 54,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: savedCount == 0 ? null : _confirmClearSaved,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Clear saved places"),
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
