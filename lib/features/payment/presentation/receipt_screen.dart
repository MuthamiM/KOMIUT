import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/constants.dart';
import '../../activity/data/trip_repository.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extras;

  const ReceiptScreen({super.key, required this.extras});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _isCompleted = false;
  bool _canComplete = false;
  int _countdown = 5;
  late String _tripId;

  @override
  void initState() {
    super.initState();
    _tripId = widget.extras['tripId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    _checkIfCompleted();
    _startTripTimer();
  }

  void _startTripTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canComplete = true;
        }
      });
      return _countdown > 0;
    });
  }

  Future<void> _checkIfCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('trip_completed_$_tripId') ?? false;
    if (mounted) {
      setState(() {
        _isCompleted = completed;
        if (completed) _canComplete = true;
      });
    }
  }

  Future<void> _markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trip_completed_$_tripId', true);
    
    final from = widget.extras['from'] as String? ?? 'N/A';
    final to = widget.extras['to'] as String? ?? 'N/A';
    final amountStr = widget.extras['amount'] as String? ?? '0.00';
    final amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
    
    ref.read(tripListProvider.notifier).addTrip(Trip(
      id: _tripId,
      routeName: '$from to $to',
      date: DateTime.now(),
      fare: amount,
      status: TripStatus.completed,
    ));
    
    if (mounted) setState(() => _isCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.extras['date'] as String? ?? 'N/A';
    final from = widget.extras['from'] as String? ?? 'N/A';
    final to = widget.extras['to'] as String? ?? 'N/A';
    final amount = widget.extras['amount'] as String? ?? '0.00';
    final paymentMethod = widget.extras['paymentMethod'] as String? ?? 'WALLET';
    final sacco = widget.extras['sacco'] as String? ?? 'KOMIUT TRANSPORT';
    final numberPlate = widget.extras['numberPlate'] as String? ?? 'KBA 123A';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                   BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                   ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    sacco.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: _thermalStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CASH/RECEIPT',
                    textAlign: TextAlign.center,
                    style: _thermalStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildDashedLine(),
                  const SizedBox(height: 24),

                  _buildRow('DATE', date),
                  const SizedBox(height: 12),
                  _buildRow('TIME', _getCurrentTime()),
                  const SizedBox(height: 12),
                  _buildRow('VEHICLE', numberPlate.toUpperCase()),
                  const SizedBox(height: 12),
                  _buildRow('FROM', from.toUpperCase()),
                  const SizedBox(height: 12),
                  _buildRow('TO', to.toUpperCase()),
                  const SizedBox(height: 12),
                  _buildRow('METHOD', paymentMethod),
                  
                  const SizedBox(height: 24),
                  _buildDashedLine(),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AMOUNT', style: _thermalStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('KES $amount', style: _thermalStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    'THANK YOU FOR RIDING WITH US',
                    textAlign: TextAlign.center,
                    style: _thermalStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TRX: ${DateTime.now().millisecondsSinceEpoch}',
                    textAlign: TextAlign.center,
                    style: _thermalStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(40, (index) {
                        return Container(
                          width: index % 3 == 0 ? 2 : 4,
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: Colors.black87,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${from.toUpperCase()} > ${to.toUpperCase()} | KES $amount | $date',
                    textAlign: TextAlign.center,
                    style: _thermalStyle(fontSize: 8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '*** CUSTOMER COPY ***',
                    textAlign: TextAlign.center,
                    style: _thermalStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (!_canComplete || _isCompleted) ? null : () async {
                    await _markComplete();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trip Completed. Rating submitted.')),
                      );
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) context.go('/');
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canComplete ? AppColors.success : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _isCompleted ? AppColors.success.withOpacity(0.7) : Colors.grey.shade300,
                    disabledForegroundColor: _isCompleted ? Colors.white : Colors.grey.shade600,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_isCompleted 
                      ? 'Completed' 
                      : (_canComplete ? 'Complete Trip' : 'Trip in progress... ($_countdown s)')),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _thermalStyle()),
        Expanded(
          child: Text(
            value, 
            style: _thermalStyle(fontWeight: FontWeight.bold), 
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(150 ~/ 3, (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.transparent : Colors.black54,
          height: 1.5,
        ),
      )),
    );
  }

  TextStyle _thermalStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(
      fontFamily: 'Courier New',
      package: null,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: Colors.black87,
      letterSpacing: 1.2,
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }
}
