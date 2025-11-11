import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/color_scheme.dart';

class AmountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  const AmountField({
    required this.label,
    required this.controller,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w600),
        suffixText: '₹',
        suffixStyle: const TextStyle(color: AppTheme.adminWhite),
        filled: true,
        fillColor: AppTheme.adminGreenLite.withOpacity(.35),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppTheme.adminGreenDarker),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppTheme.adminGreen, width: 1.2),
        ),
      ),
    );
  }
}