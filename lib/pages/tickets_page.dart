import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:travel_app/models/ticket.dart';
import 'package:travel_app/pages/ticket_details_page.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  List<Ticket> _demoTickets() {
    return [
      Ticket(
        id: 't1',
        title: 'Melbourne CBD Day Plan',
        subtitle: 'Food + Shopping',
        whenLabel: 'Today',
        stops: [
          TicketStop(name: 'State Library Victoria', lat: -37.8098, lng: 144.9652),
          TicketStop(name: 'Emporium Melbourne', lat: -37.8122, lng: 144.9631),
          TicketStop(name: 'Chinatown Melbourne', lat: -37.8109, lng: 144.9692),
          TicketStop(name: 'ACMI (Fed Square)', lat: -37.8179, lng: 144.9691),
          TicketStop(name: 'NGV International', lat: -37.8226, lng: 144.9689),
          TicketStop(name: 'Bourke Street Mall', lat: -37.8136, lng: 144.9631),
        ],
      ),
      Ticket(
        id: 't2',
        title: 'St Kilda Sunset Walk',
        subtitle: 'Attractions',
        whenLabel: 'Tomorrow',
        stops: [
          TicketStop(name: 'St Kilda Beach', lat: -37.8676, lng: 144.9740),
          TicketStop(name: 'St Kilda Pier', lat: -37.8672, lng: 144.9793),
          TicketStop(name: 'Acland Street', lat: -37.8678, lng: 144.9813),
        ],
      ),
    ];
  }

  void _openTicket(BuildContext context, Ticket t) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TicketDetailsPage(ticket: t)),
    );
  }

  Future<void> _exportAll(BuildContext context, List<Ticket> tickets) async {
    final text = tickets.map((t) => t.exportText()).join("\n\n---\n\n");
    await Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied tickets to clipboard ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _demoTickets();

    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final t = tickets[i];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openTicket(context, t),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.confirmation_number_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${t.subtitle} • ${t.stopCount} stops',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(t.whenLabel,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      const Icon(Icons.chevron_right),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _exportAll(context, tickets),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share / Export'),
              style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
            ),
          ),
        ),
      ),
    );
  }
}
