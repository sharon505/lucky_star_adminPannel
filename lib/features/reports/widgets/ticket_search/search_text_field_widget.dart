import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/color_scheme.dart';
import '../../viewModels/prize_search_view_model.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// If provided, we'll debounce onChanged calls by this duration.
  final Duration? debounceDuration;

  final bool autofocus;
  final bool showClearButton;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final double backgroundOpacity;

  const SearchTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.debounceDuration,
    this.autofocus = false,
    this.showClearButton = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    this.borderRadius = 14,
    this.backgroundOpacity = 0.10,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleChanged(String value) {
    if (widget.debounceDuration != null && widget.debounceDuration!.inMilliseconds > 0) {
      _debounce?.cancel();
      _debounce = Timer(widget.debounceDuration!, () => widget.onChanged?.call(value));
    } else {
      widget.onChanged?.call(value);
    }
    setState(() {}); // update clear button visibility
  }

  // void _clear() {
  //   _controller.clear();
  //   widget.onChanged?.call('');
  //   setState(() {});
  // }
  void _clear({bool exitField = true}) {
    // stop any pending debounced onChanged
    _debounce?.cancel();

    _controller.clear();
    widget.onChanged?.call('');

    // ✅ reset the view model too
    context.read<PrizeSearchViewModel>().reset();

    if (exitField) {
      FocusScope.of(context).unfocus();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: AppTheme.adminWhite.withOpacity(0.14), width: 1),
    );

    return TextField(
      textCapitalization: TextCapitalization.characters, // ask keyboard for CAPS
      inputFormatters: [UpperCaseTextFormatter()], // enforce CAPS
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      style: const TextStyle(
        color: AppTheme.adminWhite,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppTheme.adminGreen,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppTheme.adminWhite.withOpacity(0.55),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.adminWhite),
        suffixIcon: (widget.showClearButton && _controller.text.isNotEmpty)
            ? IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.adminWhite),
          onPressed: _clear,
        )
            : null,
        isDense: true,
        contentPadding: widget.contentPadding,
        filled: true,
        fillColor: AppTheme.adminWhite.withOpacity(widget.backgroundOpacity),
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: AppTheme.adminGreen, width: 1.2),
        ),
      ),
    );
  }
}

// put this formatter somewhere common
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection, // keep cursor position
    );
  }
}


/// Example gradient wrapper you can use behind the search bar (optional).
class AdminSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hint;

  const AdminSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hint = 'Search items, users, or IDs...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.adminGreenDarker,
            AppTheme.adminGreenDark,
            AppTheme.adminGreenLite,
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(8),
      child: SearchTextField(
        hintText: hint,
        debounceDuration: const Duration(milliseconds: 300),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        backgroundOpacity: 0.12,
        borderRadius: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
