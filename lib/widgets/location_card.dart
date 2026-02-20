import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.onRefresh,
    this.isFallback = false,
  });

  final String label;
  final String subtitle;
  final VoidCallback onRefresh;
  final bool isFallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      ),
      child: Row(
        children: [
          const Icon(Ionicons.navigate_circle_outline, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Location",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Row(
                  children: [
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                    if (isFallback) ...[
                      const SizedBox(width: 8),
                      Text(
                        "(using default)",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      )
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Ionicons.refresh_outline),
          ),
        ],
      ),
    );
  }
}
