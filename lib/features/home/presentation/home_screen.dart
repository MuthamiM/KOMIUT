import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../activity/data/trip_repository.dart';
import '../../payment/data/payment_repository.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final trips = ref.watch(tripListProvider);
    final AsyncValue<double> balanceAsync = ref.watch(balanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user?.fullName ?? 'MUSA', isDark),
              const SizedBox(height: 24),
              _buildWalletCard(context, balanceAsync, ref),
              const SizedBox(height: 32),
              _buildQuickActions(context, isDark),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Recent Trips', () => context.push('/activity'), isDark),
              const SizedBox(height: 16),
              _buildTripsList(context, trips, isDark),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  Widget _buildHeader(BuildContext context, String name, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
            fontSize: 16,
          ),
        ),
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, AsyncValue<double> balanceAsync, WidgetRef ref) {
    final isVisible = ref.watch(balanceVisibilityProvider);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => ref.read(balanceVisibilityProvider.notifier).state = !isVisible,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: 20,
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
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const SizedBox(height: 32, child: CircularProgressIndicator(color: Colors.white)),
            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/payment'),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Top Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(context, Icons.directions_bus, 'Book Trip', () => context.push('/booking'), isDark),
        _buildActionItem(context, Icons.history, 'Activity', () => context.push('/activity'), isDark),
        _buildActionItem(context, Icons.account_balance_wallet, 'Payments', () => context.push('/payment'), isDark),
        _buildActionItem(context, Icons.settings, 'Settings', () => context.push('/settings'), isDark),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? AppColors.yellow : AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: isDark ? AppColors.textPrimaryDark : AppColors.navy,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildTripsList(BuildContext context, List<Trip> trips, bool isDark) {
    if (trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No completed trips yet',
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.take(3).length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripItem(context, trip, isDark);
      },
    );
  }

  Widget _buildTripItem(BuildContext context, Trip trip, bool isDark) {
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.navy;
    final subtleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.yellow.withOpacity(0.1) : AppColors.navy.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on, 
              color: isDark ? AppColors.yellow : AppColors.navy, 
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.routeName, 
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                  style: TextStyle(color: subtleColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${trip.fare}',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                trip.status == TripStatus.completed ? 'Completed' : 'Failed',
                style: TextStyle(
                  color: trip.status == TripStatus.completed ? AppColors.success : AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int index) {
    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.navy,
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        if (i == 0) context.go('/');
        if (i == 1) context.push('/activity');
        if (i == 2) context.push('/payment');
        if (i == 3) context.push('/settings');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Payments'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
