import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    try {
      // Check if user is authenticated
      final isAuthenticated = _authService.isAuthenticated;
      
      if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      }
    } catch (error) {
      // If there's an error, go to login screen
      Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: SafeArea(
        child: Center(
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
                      // App Logo
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'assignment',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 15.w,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // App Name
                      Text(
                        'TaskSwap',
                        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      SizedBox(height: 1.h),
                      
                      // Tagline
                      Text(
                        'Social Task Exchange',
                        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Loading indicator
                      SizedBox(
                        width: 8.w,
                        height: 8.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}