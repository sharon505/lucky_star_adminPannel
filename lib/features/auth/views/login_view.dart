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
import '../model/model_user.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // ❗ Form key belongs to the widget instance, not the provider
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 30.h);

    Future<void> _submit(BuildContext context) async {
      final form = context.read<LoginFormProvider>();
      final auth = context.read<AuthViewModel>();

      // Validate using the local key
      if (!(_formKey.currentState?.validate() ?? false)) return;

      await auth.login(
        UserModel(
          usercode: form.usernameController.text.trim(),
          password: form.passwordController.text,
        ),
      );

      final error = auth.errorMessage;
      if (error != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      if (auth.loginResponse != null && context.mounted) {
        Navigator.pushReplacementNamed(context, 'DashboardView');
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SizedBox.expand(
        child: GradientBackground(
          colors: AppTheme.winGradient,
          child: SafeArea(
            child: Padding(
              padding: AppPadding.allMedium,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minH = constraints.maxHeight;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minH),
                      child: Consumer2<LoginFormProvider, AuthViewModel>(
                        builder: (context, form, authVm, _) {
                          final isLoading = authVm.isLoading;

                          return Form(
                            key: _formKey, // ✅ unique per screen instance
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _image(image: 'assets/splash/tresureChest.png'),
                                _text(text: 'Sign in to\nLucky Star Admin'),
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
                                ),
                                SizedBox(height: 10.h),
                                button(
                                  padding: AppPadding.allSmall.copyWith(right: 0, left: 0),
                                  onPressed: isLoading ? null : () => _submit(context),
                                  text: isLoading ? "Logging in…" : "Log in",
                                ),
                                Center(
                                  child: Text(
                                    "Version ${ApiEndpoints.appVersion}",
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
                                SizedBox(height: 12.h),
                              ],
                            ),
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
      text ?? 'Sign in to Lucky Star Admin',
      style: AppTypography.heading1.copyWith(
        color: AppTheme.background,
        fontSize: 30.sp,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _image({String? image}) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
      child: Image.asset(
        image ?? 'assets/splash/giftBoxClosed.png',
        height: 300.h,
      ),
    );
  }

}
