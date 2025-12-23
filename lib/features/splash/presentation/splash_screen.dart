import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/komiut_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const KomiutLogo(size: 120)
                .animate()
                .fade(duration: 800.ms)
                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'KOMIUT',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.5, end: 0),
            const SizedBox(height: 8),
            Text(
              'Moving Africa Forward',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
