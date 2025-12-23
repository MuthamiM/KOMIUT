import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../payment/data/payment_repository.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extras;

  const BookingConfirmationScreen({super.key, required this.extras});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;

  late String sacco;
  late double amount;
  late String from;
  late String to;
  late String numberPlate;

  @override
  void initState() {
    super.initState();
    sacco = widget.extras['sacco'] as String? ?? 'KOMIUT TRANSPORT';
    amount = (widget.extras['amount'] as num?)?.toDouble() ?? 100.0;
    from = widget.extras['from'] as String? ?? 'CBD';
    to = widget.extras['to'] as String? ?? 'Destination';
    numberPlate = widget.extras['numberPlate'] as String? ?? 'KBA 123A';
  }

  String _getEstimatedTravelTime() {
    final fromLower = from.toLowerCase();
    final toLower = to.toLowerCase();
    
    final routeTimes = {
      'kisumu-nairobi': '6-7 hours',
      'nairobi-kisumu': '6-7 hours',
      'mombasa-nairobi': '8-9 hours',
      'nairobi-mombasa': '8-9 hours',
      'kitui-nairobi': '3-4 hours',
      'nairobi-kitui': '3-4 hours',
      'nakuru-nairobi': '2-3 hours',
      'nairobi-nakuru': '2-3 hours',
      'eldoret-nairobi': '5-6 hours',
      'nairobi-eldoret': '5-6 hours',
      'machakos-nairobi': '1-1.5 hours',
      'nairobi-machakos': '1-1.5 hours',
      'thika-nairobi': '45 min - 1 hour',
      'nairobi-thika': '45 min - 1 hour',
      'nyeri-nairobi': '2-3 hours',
      'nairobi-nyeri': '2-3 hours',
      'cbd-nairobi': '15-30 min',
      'garissa-nairobi': '6-7 hours',
      'nairobi-garissa': '6-7 hours',
      'mandera-nairobi': '12-14 hours',
      'nairobi-mandera': '12-14 hours',
    };
    
    final routeKey = '$fromLower-$toLower';
    return routeTimes[routeKey] ?? '2-4 hours';
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (_selectedPaymentMethod == 0) {
      final currentBalance = await ref.read(balanceProvider.future);
      if (currentBalance < amount) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient wallet balance. Please top up.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    await ref.read(paymentRepositoryProvider).earnPoints(10);

    if (_selectedPaymentMethod == 0) {
      final success = await ref.read(paymentRepositoryProvider).recordTrip(
            sacco,
            amount,
            from,
            to,
          );

      if (!success) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient wallet balance. Please top up.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    } else {
      await ref.read(paymentRepositoryProvider).recordTripWithoutDeduction(
            sacco,
            amount,
            from,
            to,
          );
    }

    ref.invalidate(loyaltyPointsProvider);
    ref.invalidate(paymentHistoryProvider);
    ref.invalidate(balanceProvider);

    if (mounted) {
      setState(() => _isProcessing = false);

      context.go('/receipt', extra: {
        'sacco': sacco,
        'amount': amount.toStringAsFixed(2),
        'from': from,
        'to': to,
        'date':
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        'paymentMethod': _selectedPaymentMethod == 0 ? 'WALLET' : 'M-PESA',
        'numberPlate': numberPlate,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navy.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              from,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.navy,
                              ),
                            ),
                            const Text(
                              'Boarding Point',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              to,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.navy,
                              ),
                            ),
                            const Text(
                              'Destination',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.navy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sacco,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.navy,
                              ),
                            ),
                            Text(
                              numberPlate,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.access_time, color: AppColors.success),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Travel Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                            Text('~${_getEstimatedTravelTime()}', style: const TextStyle(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentOption(
                    index: 0,
                    icon: Icons.account_balance_wallet,
                    title: 'Wallet',
                    subtitle: balanceAsync.when(
                      data: (balance) => 'Balance: KES ${balance.toStringAsFixed(0)}',
                      loading: () => 'Loading...',
                      error: (_, __) => 'Error',
                    ),
                    color: AppColors.navy,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    index: 1,
                    icon: Icons.phone_android,
                    title: 'M-Pesa',
                    subtitle: 'Pay with mobile money',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Fare',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'KES ${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Fee',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Text(
                        'KES 0',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'KES ${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.purple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Earn 10 loyalty points with this trip!',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPaymentMethod == 1 
                        ? Colors.green 
                        : AppColors.yellow,
                    foregroundColor: _selectedPaymentMethod == 1 
                        ? Colors.white 
                        : Colors.black,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedPaymentMethod == 1
                              ? 'Pay with M-Pesa KES ${amount.toStringAsFixed(0)}'
                              : 'Confirm & Pay KES ${amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
