import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TripStatus { completed, failed }

class Trip {
  final String id;
  final String routeName;
  final DateTime date;
  final double fare;
  final TripStatus status;

  Trip({
    required this.id,
    required this.routeName,
    required this.date,
    required this.fare,
    required this.status,
  });
}

class TripNotifier extends StateNotifier<List<Trip>> {
  TripNotifier() : super([]);

  void addTrip(Trip trip) {
    if (state.any((t) => t.id == trip.id)) return;
    state = [trip, ...state];
  }
}

final tripListProvider = StateNotifierProvider<TripNotifier, List<Trip>>((ref) {
  return TripNotifier();
});
