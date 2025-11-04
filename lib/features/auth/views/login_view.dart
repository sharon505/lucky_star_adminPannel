import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/network/api_endpoints.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/theme/color_scheme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/app_gradient_background.dart';
import '../../../shared/app_text_form_field.dart';
import '../viewmodel/LoginFormProvider_viewModel.dart';
import '../viewmodel/login_view_model.dart';
import '../widgets/authButton_widget.dart';

// import your provider + viewmodel + user model
import '../model/model_user.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 30.h);

    Future<void> _submit(BuildContext context) async {
      final form = context.read<LoginFormProvider>();
      final auth = context.read<AuthViewModel>();

      if (!form.validateForm()) return;

      // Call API
      await auth.login(
        UserModel(
          usercode: form.usernameController.text.trim(),
          password: form.passwordController.text,
        ),
      );

      // Handle result
      final error = auth.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      // Success -> navigate
      if (auth.loginResponse != null && context.mounted) {
        Navigator.pushReplacementNamed(context, 'HomePageViews');
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SizedBox.expand( // guarantees bounds for the background
        child: GradientBackground(
          colors: AppTheme.winGradient,
          child: SafeArea(
            child: Padding(
              padding: AppPadding.allMedium,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // ✅ LayoutBuilder gives us the real viewport height.
                  final minH = constraints.maxHeight;

                  return SingleChildScrollView(
                    // Let scroll view size to content; we give content a minHeight = viewport
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minH),
                      child: Consumer2<LoginFormProvider, AuthViewModel>(
                        builder: (context, form, authVm, _) {
                          final isLoading = authVm.isLoading;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min, // important in scroll views
                            children: [
                              _image(image: 'assets/splash/tresureChest.png'),
                              _text(text: 'Sign In To\nLuckyStar Admin'),
                              gap,
                              AppTextFormField(
                                label: "Username",
                                hint: "Enter your username",
                                controller: form.usernameController,
                                keyboardType: TextInputType.text,
                                prefixIcon: Icons.person,
                                validator: form.validateUsername,
                                enabled: !isLoading,
                              ),
                              AppTextFormField(
                                label: "Password",
                                hint: "Enter your password",
                                controller: form.passwordController,
                                isPassword: true,
                                prefixIcon: Icons.lock,
                                validator: form.validatePassword,
                                enabled: !isLoading,
                                // If your AppTextFormField supports a suffixIcon/toggle, hook it to:
                                // obscureText: !form.isPasswordVisible,
                                // suffixIcon: IconButton(
                                //   icon: Icon(form.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                //   onPressed: form.togglePasswordVisibility,
                                // ),
                              ),
                              SizedBox(height: 10.h),
                              button(
                                padding: AppPadding.allSmall.copyWith(right: 0, left: 0),
                                ///todo un command the code before release (login button)
                                onPressed: ()=>Navigator.pushNamed(context,'DashboardView'),
                                // onPressed: isLoading ? null : () => _submit(context),
                                text: isLoading ? "Logging in..." : "Login",
                              ),
                              Center(
                                child: Text(
                                  "Version ${ApiEndpoints.currentVersion}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              if (authVm.errorMessage != null) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  authVm.errorMessage!,
                                  style: AppTypography.body.copyWith(color: Colors.redAccent),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              // Bottom breathing room; don't use Spacer in a scroll view.
                              SizedBox(height: 12.h),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _text({String? text}) {
    return Text(
      text ?? 'Sign into Lucky Star Admin',
      style: AppTypography.heading1.copyWith(
        color: AppTheme.background,
        fontSize: 30.sp,
        height: 2.h,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _image({String? image}) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
      child: Image.asset(
        height: 300.h,
          image ?? 'assets/splash/giftBoxClosed.png'),
    );
  }
}
