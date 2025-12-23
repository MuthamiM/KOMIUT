import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class KomiutLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const KomiutLogo({
    super.key,
    this.size = 100,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : AppColors.navy,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'K',
          style: TextStyle(
            color: isDark ? AppColors.navy : AppColors.yellow,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

