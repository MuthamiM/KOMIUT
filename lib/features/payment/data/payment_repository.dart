import 'package:flutter_riverpod/flutter_riverpod.dart';

class Payment {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isTopUp;

  Payment({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.isTopUp = false,
  });
}

class PaymentRepository {
  double _balance = 2450.0;
  int _loyaltyPoints = 15;
  
  final List<Payment> _history = [
      Payment(
        id: '1',
        title: 'Wallet Top-up',
        amount: 1000.0,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isTopUp: true,
      ),
      Payment(
        id: '2',
        title: 'Bus Fare - Nairobi to Thika',
        amount: 150.0,
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Payment(
        id: '3',
        title: 'Bus Fare - Nairobi to Nakuru',
        amount: 800.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
  ];

  Future<double> getBalance() async {
    return _balance;
  }

  Future<int> getLoyaltyPoints() async {
    return _loyaltyPoints;
  }

  Future<void> topUp(double amount, {String? method, String? phone}) async {
    await Future.delayed(const Duration(seconds: 1));
    _balance += amount;
    
    final title = method == 'M-Pesa' ? 'M-Pesa Top-up (${phone ?? 'Default'})' : 'Card Top-up';
    
    _history.insert(0, Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        isTopUp: true,
    ));
  }
  
  Future<void> recordTrip(String saccoName, double amount, String from, String to) async {
      await Future.delayed(const Duration(milliseconds: 200));
      _balance -= amount;
      
      
      final earned = (amount / 100).ceil();
      _loyaltyPoints += earned;
      
      _history.insert(0, Payment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '$saccoName - $from to $to',
          amount: amount,
          date: DateTime.now(),
          isTopUp: false
      ));
  }

  Future<void> earnPoints(int points) async {
    _loyaltyPoints += points;
  }

  Future<bool> redeemPoints() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_loyaltyPoints >= 200) {
      _loyaltyPoints -= 200;
      _balance += 50; 
      
      _history.insert(0, Payment(
         id: DateTime.now().millisecondsSinceEpoch.toString(),
         title: 'Loyalty Redemption',
         amount: 50.0,
         date: DateTime.now(),
         isTopUp: true,
      ));
      
      return true;
    }
    return false;
  }

  Future<List<Payment>> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_history);
  }
}

final paymentRepositoryProvider = Provider((ref) => PaymentRepository());

final balanceProvider = FutureProvider((ref) {
  return ref.watch(paymentRepositoryProvider).getBalance();
});

final loyaltyPointsProvider = FutureProvider((ref) {
  return ref.watch(paymentRepositoryProvider).getLoyaltyPoints();
});

final paymentHistoryProvider = FutureProvider((ref) {
  return ref.watch(paymentRepositoryProvider).getPaymentHistory();
});

final balanceVisibilityProvider = StateProvider<bool>((ref) => true);
