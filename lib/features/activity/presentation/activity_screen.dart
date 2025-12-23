import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../data/trip_repository.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        centerTitle: true,
      ),
      body: trips.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildTripCard(context, trip, isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off, 
            size: 80, 
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No trips found',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent trips will appear here.',
            style: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip, bool isDark) {
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.navy;
    final subtleTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                style: TextStyle(color: subtleTextColor, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (trip.status == TripStatus.completed ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip.status == TripStatus.completed ? 'Completed' : 'Failed',
                  style: TextStyle(
                    color: trip.status == TripStatus.completed ? AppColors.success : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: isDark ? AppColors.yellow : AppColors.navy, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  trip.routeName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              Text(
                'KES ${trip.fare}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          Divider(height: 32, color: isDark ? Colors.white.withOpacity(0.1) : null),
          Row(
            children: [
              Icon(Icons.payment, size: 16, color: subtleTextColor),
              const SizedBox(width: 8),
              Text('Paid via Wallet', style: TextStyle(color: subtleTextColor, fontSize: 13)),
              const Spacer(),
              TextButton(
                onPressed: () {
                    final parts = trip.routeName.split(' to ');
                    final from = parts.isNotEmpty ? parts[0] : 'Unknown';
                    final to = parts.length > 1 ? parts[1] : 'Unknown';
                    
                    context.push('/receipt', extra: {
                        'sacco': 'KOMIUT TRANSPORT',
                        'amount': trip.fare.toStringAsFixed(2),
                        'from': from,
                        'to': to,
                        'date': '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                        'paymentMethod': 'WALLET',
                    });
                },
                child: const Text('View Receipt'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
