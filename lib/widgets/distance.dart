import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';

class Distance extends StatelessWidget {
  const Distance({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Info",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.place_outlined, size: 18),
              ),
              const SizedBox(width: 10),

              // Address text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Category",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Category chip
              _CategoryChip(label: place.category),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isEmpty ? "OTHER" : label.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
