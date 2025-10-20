import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
 with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override 
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    );

    _fadeAnimation = Tween<double> (
      begin: 0.0,
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut
    ));

    _animationController.forward();

    // navigate to homescreen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      // TODO: defining all routes for each screens
      // Get.offAllNamed(Route.HOME)
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: Offset(0, 10)
                        )
                        ]
                      ),
                      // TODO: ICONS NEWS PAPER PUT HERE
                    )
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}