import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = themeNotifier.isDarkMode;

    return GestureDetector(
      onTap: () {
        themeNotifier.toggleTheme();
      },
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF1E1E2C), const Color(0xFF0F0F1A)]
              : [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : const Color(0xFF0072FF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              left: isDark ? 30.0 : 2.0,
              right: isDark ? 2.0 : 30.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    isDark ? Icons.nights_stay : Icons.wb_sunny_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFF0F0F1A) : const Color(0xFF0072FF),
                  ).animate(target: isDark ? 1 : 0).rotate(duration: 400.ms),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
