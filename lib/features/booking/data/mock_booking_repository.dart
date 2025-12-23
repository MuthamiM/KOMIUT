import 'package:komiut_app/features/booking/domain/sacco.dart';

class MockBookingRepository {
  Future<List<Sacco>> getAvailableVehicles(String origin, String destination) async {
    await Future.delayed(const Duration(seconds: 1)); 

    final originLower = origin.toLowerCase().trim();
    final destLower = destination.toLowerCase().trim();
    
    if (originLower.contains('kitui') && (destLower.contains('nairobi') || destLower.contains('cbd'))) {
      return [
        _createSacco('Kinatwa Sacco', origin, destination, 500, 10, 45),
        _createSacco('Makos Sacco', origin, destination, 450, 8, 30),
        _createSacco('Eastern Express', origin, destination, 480, 12, 60),
      ];
    }
    
    if (originLower.contains('mombasa') && (destLower.contains('nairobi') || destLower.contains('cbd'))) {
      return [
        _createSacco('Mash Poa', origin, destination, 1500, 20, 120),
        _createSacco('Coast Bus', origin, destination, 1400, 15, 130),
        _createSacco('Modern Coast', origin, destination, 1600, 25, 140),
      ];
    }
    
    if (originLower.contains('kisumu') && (destLower.contains('nairobi') || destLower.contains('cbd'))) {
      return [
        _createSacco('Easy Coach', origin, destination, 1650, 25, 150),
        _createSacco('Guardian Angel', origin, destination, 1400, 18, 160),
      ];
    }
    
    if (destLower.contains('mombasa') || destLower.contains('diani') || destLower.contains('malindi')) {
      return [
        _createSacco('Mash Poa', origin, destination, 1500, 20, 120),
        _createSacco('Coast Bus', origin, destination, 1400, 15, 130),
        _createSacco('Modern Coast', origin, destination, 1600, 25, 140),
        _createSacco('Tahmeed Coach', origin, destination, 1450, 10, 150),
      ];
    }
    
    if (destLower.contains('kisumu') || destLower.contains('kakamega') || destLower.contains('busia')) {
      return [
        _createSacco('Easy Coach', origin, destination, 1650, 25, 150),
        _createSacco('Guardian Angel', origin, destination, 1400, 18, 160),
        _createSacco('Ena Coach', origin, destination, 1500, 12, 170),
      ];
    }

    if (destLower.contains('eldoret') || destLower.contains('nakuru')) {
      return [
        _createSacco('North Rift Shuttle', origin, destination, 800, 8, 30),
        _createSacco('2NK Sacco', origin, destination, 700, 10, 40),
        _createSacco('Eldoret Shuttle', origin, destination, 850, 12, 50),
        _createSacco('Guardian Angel', origin, destination, 1000, 20, 180),
      ];
    }

    if (destLower.contains('kitui') || destLower.contains('machakos')) {
      return [
        _createSacco('Kinatwa Sacco', origin, destination, 500, 10, 45),
        _createSacco('Makos Sacco', origin, destination, 450, 8, 30),
      ];
    }

    if (destLower.contains('mandera') || destLower.contains('wajir') || destLower.contains('garissa')) {
      return [
        _createSacco('Moyale Liner', origin, destination, 2500, 30, 300),
        _createSacco('Makkah Bus', origin, destination, 2300, 25, 320),
        _createSacco('E_Coach', origin, destination, 2400, 20, 310),
      ];
    }

    return [
       _createSacco('Super Metro', origin, destination, 80, 5, 2),
       _createSacco('KBS', origin, destination, 70, 22, 5),
       _createSacco('Citi Hoppa', origin, destination, 60, 15, 8),
       _createSacco('Embassava', origin, destination, 50, 3, 10),
       _createSacco('Lopha Travels', origin, destination, 100, 8, 15),
    ];
  }

  Sacco _createSacco(String name, String origin, String dest, double price, int seats, int minutesWait) {
    return Sacco(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        origin: origin,
        destination: dest,
        price: price,
        seatsAvailable: seats,
        departureTime: DateTime.now().add(Duration(minutes: minutesWait)),
    );
  }
}
