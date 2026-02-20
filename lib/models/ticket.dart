class Ticket {
  final String id;
  final String title;
  final String subtitle;     
  final String whenLabel;    
  final List<TicketStop> stops;

  Ticket({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.whenLabel,
    required this.stops,
  });

  int get stopCount => stops.length;

  
  String exportText() {
    final b = StringBuffer();
    b.writeln(title);
    b.writeln(subtitle);
    b.writeln('$whenLabel • $stopCount stops');
    b.writeln('');

    for (var i = 0; i < stops.length; i++) {
      final s = stops[i];
      b.writeln('${i + 1}. ${s.name} (${s.lat}, ${s.lng})');
    }
    return b.toString().trim();
  }
}

class TicketStop {
  final String name;
  final double lat;
  final double lng;

  TicketStop({
    required this.name,
    required this.lat,
    required this.lng,
  });
}
