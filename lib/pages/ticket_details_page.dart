import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:travel_app/models/ticket.dart';

class TicketDetailsPage extends StatelessWidget {
  const TicketDetailsPage({super.key, required this.ticket});
  final Ticket ticket;

  static Future<void> _openStopInMaps(TicketStop s) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${s.lat},${s.lng}",
    );
    await launchUrl(url, webOnlyWindowName: '_blank');
  }

  static Uri _routeUrl(List<TicketStop> stops) {
    final origin = "${stops.first.lat},${stops.first.lng}";
    final destination = "${stops.last.lat},${stops.last.lng}";

    final waypoints = stops.length <= 2
        ? null
        : stops
            .sublist(1, stops.length - 1)
            .map((s) => "${s.lat},${s.lng}")
            .join("|");

    return Uri.parse("https://www.google.com/maps/dir/?api=1").replace(
      queryParameters: {
        "origin": origin,
        "destination": destination,
        if (waypoints != null && waypoints.isNotEmpty) "waypoints": waypoints,
        "travelmode": "walking",
      },
    );
  }

  Future<void> _export(BuildContext context) async {
    final text = ticket.exportText();
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard ✅")),
    );
  }

  Future<void> _openRoute(BuildContext context) async {
    if (ticket.stops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Need at least 2 stops to open a route.")),
      );
      return;
    }
    final url = _routeUrl(ticket.stops);
    await launchUrl(url, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.title),
        actions: [
          IconButton(
            tooltip: "Copy / Export",
            icon: const Icon(Icons.ios_share),
            onPressed: () => _export(context),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.subtitle,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text("${ticket.whenLabel} • ${ticket.stopCount} stops",
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openRoute(context),
                    icon: const Icon(Icons.directions),
                    label: const Text("Open full route in Google Maps"),
                    style:
                        OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text("Stops", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(ticket.stops.length, (i) {
            final s = ticket.stops[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openStopInMaps(s),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.10),
                        ),
                        child: Text("${i + 1}"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const Icon(Icons.open_in_new),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _export(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text("Share / Export"),
              style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
            ),
          ),
        ),
      ),
    );
  }
}
