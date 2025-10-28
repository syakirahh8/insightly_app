import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insightly_app/routes/app_pages.dart';
import 'package:insightly_app/utils/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // navigate to home screen after 3 second
    Future.delayed(Duration(seconds: 4), () {
      Get.offAllNamed(Routes.HOME);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/insightly_logo.png',
              width: 350,
              height: 350,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 1000.ms, curve: Curves.easeOut)
                .then(delay: 300.ms)
                .shake(
                  hz: 2,
                  offset: Offset(8, 0),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then(delay: 300.ms)
                .fadeOut(duration: 700.ms, curve: Curves.easeInCubic),
             SizedBox(height: 10),
            Transform.translate(
              offset: const Offset(0, -130),
              child: Text(
                'Fast News, Deeper Insight.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              )
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 300.ms, curve: Curves.easeOut)
                  .then(delay: 1500.ms)
                  .fadeOut(duration: 600.ms, curve: Curves.easeInCubic),
            ),
            // LOADING
            CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 2000.ms)
                .then(delay: 300.ms)
                .fadeOut(duration: 300.ms, curve: Curves.easeInCubic),
          ],
        ),
      ),
    );
  }
}
