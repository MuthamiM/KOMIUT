import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../data/payment_repository.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isToppingUp = false;
  bool _isRedeeming = false;

  void _showTopUpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TopUpModal(),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        _processTopUp(result['amount'], result['method'], result['phone']);
      }
    });
  }

  void _processTopUp(double amount, String method, String? phone) async {
    setState(() => _isToppingUp = true);
    await ref.read(paymentRepositoryProvider).topUp(amount, method: method, phone: phone);
    if (mounted) {
      setState(() => _isToppingUp = false);
      ref.invalidate(balanceProvider);
      ref.invalidate(paymentHistoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$method top-up of KES ${amount.toStringAsFixed(0)} Successful!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleRedeemPoints() async {
    setState(() => _isRedeeming = true);
    final success = await ref.read(paymentRepositoryProvider).redeemPoints();
    if (mounted) {
      setState(() => _isRedeeming = false);
      if (success) {
        ref.invalidate(balanceProvider);
        ref.invalidate(loyaltyPointsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Points Redeemed! KES 50 added to wallet.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough points to redeem.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);
    final pointsAsync = ref.watch(loyaltyPointsProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBalanceSummary(balanceAsync),
                const SizedBox(height: 16),
                _buildLoyaltyCard(pointsAsync),
                const SizedBox(height: 32),
                _buildTopUpSection(context),
                const SizedBox(height: 32),
                Text(
                  'Payment History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.navy,
                      ),
                ),
                const SizedBox(height: 16),
                _buildHistorySection(context, historyAsync, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSummary(AsyncValue<double> balanceAsync) {
    final isVisible = ref.watch(balanceVisibilityProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => ref.read(balanceVisibilityProvider.notifier).state = !isVisible,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          balanceAsync.when(
            data: (balance) => Text(
              isVisible ? 'KES ${balance.toStringAsFixed(2)}' : 'KES ****',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const SizedBox(
              height: 44,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (err, stack) => const Text(
              'KES 0.00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(AsyncValue<int> pointsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loyalty Points',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                pointsAsync.when(
                  data: (points) => Text(
                    '$points Pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (err, stack) => const Text(
                    '0 Pts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: _isRedeeming
                  ? null
                  : (pointsAsync.value != null && pointsAsync.value! >= 20)
                      ? _handleRedeemPoints
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white24,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isRedeeming
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Redeem'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Need more credit?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Top up your wallet with M-Pesa or card',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isToppingUp ? null : _showTopUpModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.navy,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isToppingUp
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.navy,
                    ),
                  )
                : const Text(
                    'Top Up Wallet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
      BuildContext context, AsyncValue<List<Payment>> historyAsync, bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.navy;
    final subtleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No transaction history yet.'),
            ),
          );
        }
        return Column(
          children: history
              .map((payment) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: payment.isTopUp
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            payment.isTopUp ? Icons.add : Icons.remove,
                            color: payment.isTopUp ? AppColors.success : AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                                style: TextStyle(color: subtleColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${payment.isTopUp ? '+' : '-'} KES ${payment.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: payment.isTopUp ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      error: (err, stack) => const Center(child: Text('Failed to load history')),
    );
  }
}

class TopUpModal extends StatefulWidget {
  const TopUpModal({super.key});

  @override
  State<TopUpModal> createState() => _TopUpModalState();
}

class _TopUpModalState extends State<TopUpModal> {
  int _selectedMethod = 0;
  final _amountController = TextEditingController(text: '1000');
  final _phoneController = TextEditingController(text: '0114945842');
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String? _error;
  String? _detectedBank;

  @override
  void initState() {
    super.initState();
    _cardController.addListener(_detectBank);
  }

  void _detectBank() {
    final text = _cardController.text.replaceAll(' ', '');
    String? newBank;
    if (text.startsWith('4111') || text.startsWith('5222')) {
      newBank = 'KCB Bank';
    } else if (text.startsWith('4222') || text.startsWith('5333')) {
      newBank = 'NCBA Bank';
    } else if (text.startsWith('4')) {
      newBank = 'Visa';
    }

    if (newBank != _detectedBank) {
      setState(() {
        _detectedBank = newBank;
        _error = null;
      });
    }
  }

  @override
  void dispose() {
    _cardController.removeListener(_detectBank);
    _amountController.dispose();
    _phoneController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Top Up Wallet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMethodTab(0, Icons.credit_card, 'Card', isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodTab(1, Icons.phone_android, 'M-Pesa', isDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Amount (KES)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixText: 'KES ',
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedMethod == 1)
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '07XX XXX XXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.phone_android),
              ),
            )
          else ...[
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4XXX XXXX XXXX XXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
                prefixIcon: const Icon(Icons.credit_card),
                suffixIcon: _detectedBank != null
                    ? Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _detectedBank!,
                              style: TextStyle(
                                color: _detectedBank == 'Visa' ? Colors.blue : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '***',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.navy,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Confirm & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTab(int index, IconData icon, String label, bool isDark) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.yellow.withOpacity(0.1)
              : (isDark ? Colors.white12 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.yellow : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.yellow : (isDark ? Colors.white54 : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.yellow : (isDark ? Colors.white54 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndSubmit() {
    setState(() => _error = null);
    
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _error = 'Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 50) {
      setState(() => _error = 'Min top-up: KES 50');
      return;
    }

    if (_selectedMethod == 1) {
      final phone = _phoneController.text.trim();
      if (phone.length < 10) {
        setState(() => _error = 'Invalid M-Pesa number');
        return;
      }
    } else {
      final card = _cardController.text.replaceAll(' ', '');
      if (card.length < 12) {
        setState(() => _error = 'Invalid card number');
        return;
      }

      final expiry = _expiryController.text.trim();
      if (expiry.length < 5 || !expiry.contains('/')) {
        setState(() => _error = 'Invalid expiry (MM/YY)');
        return;
      }

      final cvv = _cvvController.text.trim();
      if (cvv.length < 3) {
        setState(() => _error = 'Invalid CVV');
        return;
      }

      bool isKCB = card.startsWith('4111') || card.startsWith('5222');
      bool isNCBA = card.startsWith('4222') || card.startsWith('5333');

      if (!isKCB && !isNCBA) {
        setState(() => _error = 'Unsupported card. Only KCB or NCBA allowed.');
        return;
      }
    }

    Navigator.of(context).pop({
      'amount': amount,
      'method': _selectedMethod == 1 ? 'M-Pesa' : 'Card',
      'phone': _selectedMethod == 1 ? _phoneController.text.trim() : null,
    });
  }
}
