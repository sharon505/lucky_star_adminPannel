import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/app_gradient_background.dart';
import '../widgets/authButton_widget.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  ///todo button nav fix
  // nav() => Navigator.pushNamed(context, 'LoginView');
  nav() => Navigator.pushReplacementNamed(context, 'LoginView');

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      nav,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = AppTypography.heading1.copyWith(
      color: AppTheme.background,
      fontSize: 35.sp,
      height: 2,
    );

    return Scaffold(
      backgroundColor: AppTheme.primary,
      floatingActionButton: button(
        onPressed: nav,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: GradientBackground(
        colors: AppTheme.winGradient,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _image(),
              _text(style: style),
            ],
          ),
        ),
      ),
    );
  }


  Widget _text({
    TextStyle? style,
    // String title = 'Welcome to\nLucky Star\nAdmin',
    String title = 'Lucky Star\nAdmin Panel',
  }) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: AppPadding.allMedium,
        child: Text(
          title,
          style: style,
        ),
      ),
    );
  }

  Widget _image() {
    return Positioned(
      top: 195.h,
      child: Image.asset(
        'assets/splash/cash pic.png',
        fit: BoxFit.contain,
        scale: 2.8,
      ),
    );
  }
}
