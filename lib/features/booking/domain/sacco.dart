class Sacco {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final double price;
  final int seatsAvailable;
  final DateTime departureTime;
  final bool hasNTSAYellowLine; 

  const Sacco({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.price,
    required this.seatsAvailable,
    required this.departureTime,
    this.hasNTSAYellowLine = true,
  });
}
