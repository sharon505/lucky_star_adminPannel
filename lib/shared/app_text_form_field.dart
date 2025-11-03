import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/color_scheme.dart';
import '../core/theme/text_styles.dart';

class AppTextFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  /// When true, field shows a toggle (eye) to reveal/hide text.
  final bool isPassword;

  /// Prevents keyboard & editing but keeps the field styling.
  final bool readOnly;

  /// Enables/Disables the field (disables interaction & greys it out).
  final bool enabled;

  /// Called when the field is tapped (useful for date pickers, etc.)
  final VoidCallback? onTap;

  /// Extra optional props for convenience
  final int maxLines;
  final int minLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.maxLines = 1,
    this.minLines = 1,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofillHints,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxLines = widget.isPassword ? 1 : widget.maxLines;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _obscure : false,
        readOnly: widget.readOnly,
        enabled: widget.enabled, // ✅ wired properly
        onTap: widget.onTap,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        textInputAction: widget.textInputAction,
        focusNode: widget.focusNode,
        autofillHints: widget.autofillHints,
        maxLines: effectiveMaxLines,
        minLines: widget.minLines,
        // style: AppStyle.heading2.copyWith(color: AppTheme.textPrimary,fontSize: 13.sp),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: AppTypography.heading1.copyWith(color: AppTheme.textSecondary,fontSize: 10.sp),
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: AppTypography.heading1.copyWith(color: AppTheme.textSecondary,fontSize: 10.sp),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppTheme.secondary)
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.secondary,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          )
              : (widget.suffixIcon != null
              ? Icon(widget.suffixIcon, color: AppTheme.secondary)
              : null),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppTheme.secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
            BorderSide(color: AppTheme.secondary.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppTheme.secondary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
            BorderSide(color: AppTheme.secondary.withOpacity(0.15)),
          ),
        ),
      ),
    );
  }
}
