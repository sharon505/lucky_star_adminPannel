import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/viewmodel/LoginFormProvider_viewModel.dart';
import '../../reports/viewModels/product_view_model.dart';
import '../viewModel/current_stock_view_model.dart';
import '../viewModel/location_stock_issue_view_model.dart';
import '../viewModel/location_view_model.dart';

Future<void> openLocationWiseDialog(
    BuildContext context, {
      DateTime? initialDate,
    }) async {
  final pv = context.read<ProductViewModel>();
  final lv = context.read<LocationViewModel>();

  // Preload products + locations if empty
  if (pv.items.isEmpty && !pv.isLoading) pv.load();
  if (lv.items.isEmpty && !lv.isLoading) lv.load();

  final DateTime date = initialDate ?? DateTime.now();

  int? selProductId = pv.selected?.productId;
  int? selLocationId = lv.selectedLocationId;

  final currentStockCtrl = TextEditingController(text: '0');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();
      bool _didKickoff = false;

      // Current user from login provider
      final login = ctx.read<LoginFormProvider>();
      final currentUser = login.username;

      String _fmtDate(DateTime d) {
        final y = d.year.toString().padLeft(4, '0');
        final m = d.month.toString().padLeft(2, '0');
        final day = d.day.toString().padLeft(2, '0');
        return '$y-$m-$day';
      }

      return ChangeNotifierProvider(
        create: (_) => LocationStockIssueViewModel()
          ..bootstrap(
            initialDate: date,
            initialProductId: selProductId,
            initialLocationId: selLocationId,
            initialCurrentStock: 0,
            initialUser: currentUser,
          ),
        child: StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final pvm = ctx.watch<ProductViewModel>();
            final lvm = ctx.watch<LocationViewModel>();
            final csvm = ctx.watch<CurrentStockViewModel>();
            final lsvm = ctx.watch<LocationStockIssueViewModel>();

            // keep read-only text field in sync with VM
            currentStockCtrl.text = lsvm.currentStock.toString();

            Future<void> _updateCurrentStock() async {
              if (selProductId == null) return;
              if (pvm.items.isEmpty) return;

              final product = pvm.items
                  .firstWhere(
                    (e) => e.productId == selProductId!,
                orElse: () => pvm.items.first,
              )
                  .productName;

              try {
                await ctx.read<CurrentStockViewModel>().fetch(product: product);
                final stockVm = ctx.read<CurrentStockViewModel>();
                lsvm.setCurrentStock(stockVm.currentStock);
                currentStockCtrl.text = stockVm.currentStock.toString();
              } catch (_) {
                // csvm.error will be shown below
              }
            }

            // Initial auto-load of current stock if product already selected
            if (!_didKickoff) {
              _didKickoff = true;
              if (selProductId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateCurrentStock();
                });
              }
            }

            final currentVal = lsvm.currentStock.toDouble();
            final bool hasStock = currentVal > 0;
            final bool disabled = lsvm.isSubmitting;

            return AlertDialog(
              backgroundColor: AppTheme.adminGreenDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'Location Wise Issue',
                style: AppTypography.heading1.copyWith(
                  fontSize: 17.sp,
                  color: AppTheme.adminGreen,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10.h),

                      // ---------- Issue Date (read-only, today/initial) ----------
                      TextFormField(
                        readOnly: true,
                        decoration: _inputDeco('Issue Date').copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_today_rounded,
                            color: AppTheme.adminWhite,
                            size: 18,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppTheme.adminWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        controller: TextEditingController(
                          text: _fmtDate(lsvm.issueDate),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // ---------- Location (LocationViewModel) ----------
                      DropdownButtonFormField<int>(
                        value: selLocationId ?? lvm.selectedLocationId,
                        items: [
                          for (final it in lvm.items)
                            DropdownMenuItem<int>(
                              value: it.locationId,
                              child: Text(
                                it.locationName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: disabled
                            ? null
                            : (v) async {
                          setStateDialog(() => selLocationId = v);
                          if (v != null) {
                            lvm.setLocation(v);
                            lsvm.setLocation(v);
                          }
                        },
                        validator: (v) =>
                        (v == null && lvm.items.isEmpty)
                            ? 'No locations available'
                            : null,
                        decoration: _inputDeco('Location'),
                        dropdownColor: AppTheme.adminGreenDark,
                        style: const TextStyle(color: AppTheme.adminWhite),
                      ),
                      if (lvm.isLoading) ...[
                        SizedBox(height: 8.h),
                        const LinearProgressIndicator(
                          color: AppTheme.adminGreen,
                        ),
                      ],
                      if (lvm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          lvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // ---------- Product ----------
                      DropdownButtonFormField<int>(
                        value: selProductId ?? pvm.selected?.productId,
                        items: [
                          for (final it in pvm.items)
                            DropdownMenuItem<int>(
                              value: it.productId,
                              child: Text(
                                it.productName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: disabled
                            ? null
                            : (v) async {
                          setStateDialog(() => selProductId = v);
                          if (v != null) {
                            final sel = pvm.items.firstWhere(
                                  (e) => e.productId == v,
                            );
                            pvm.select(sel);
                            lsvm.setProduct(v);
                          }
                          await _updateCurrentStock();
                        },
                        validator: (v) => v == null && pvm.items.isEmpty
                            ? 'No products available'
                            : null,
                        decoration: _inputDeco('Product'),
                        dropdownColor: AppTheme.adminGreenDark,
                        style: const TextStyle(color: AppTheme.adminWhite),
                      ),
                      if (pvm.isLoading) ...[
                        SizedBox(height: 8.h),
                        const LinearProgressIndicator(
                          color: AppTheme.adminGreen,
                        ),
                      ],
                      if (pvm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          pvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // ---------- Current Stock ----------
                      TextFormField(
                        controller: currentStockCtrl,
                        readOnly: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        style: const TextStyle(
                          color: AppTheme.adminWhite,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _amountDeco('Current Stock'),
                      ),
                      if (csvm.isLoading) ...[
                        SizedBox(height: 8.h),
                        const LinearProgressIndicator(
                          color: AppTheme.adminGreen,
                        ),
                      ],
                      if (csvm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          csvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // ---------- Issue Stock (editable; bound to VM) ----------
                      TextFormField(
                        controller: lsvm.issueQtyCtrl,
                        enabled: hasStock && !disabled,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        onChanged: lsvm.setIssueQuantityFromString,
                        style: const TextStyle(
                          color: AppTheme.adminWhite,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _amountDeco('Issue Stock'),
                        validator: (v) {
                          if (!hasStock) {
                            return 'No stock available to issue';
                          }
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter issue stock';
                          }
                          final x = double.tryParse(v.trim());
                          if (x == null) return 'Invalid number';
                          if (x <= 0) return 'Must be greater than zero';

                          final current = lsvm.currentStock.toDouble();
                          if (current > 0 && x > current) {
                            return 'Cannot issue more than current stock';
                          }
                          return null;
                        },
                      ),

                      if (lsvm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          lsvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: disabled ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(color: AppTheme.adminWhite),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: disabled
                        ? AppTheme.adminGreen.withOpacity(.6)
                        : AppTheme.adminGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: disabled
                      ? null
                      : () async {
                    if (!hasStock) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('No stock available to issue.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (!formKey.currentState!.validate()) return;

                    if (selLocationId == null || selProductId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select location and product.',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // Refresh user in case changed
                    final uname =
                        ctx.read<LoginFormProvider>().username;

                    lsvm
                      ..setLocation(selLocationId!)
                      ..setProduct(selProductId!)
                      ..setUser(uname)
                      ..setCurrentStock(
                        int.tryParse(
                          currentStockCtrl.text.trim(),
                        ) ??
                            0,
                      );

                    final result = await lsvm.submit();

                    if (lsvm.hasSuccessResponse) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Issue saved (code: ${result?.column1})',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(ctx);
                    } else if (lsvm.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lsvm.error!),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: lsvm.isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('SUBMIT'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

InputDecoration _inputDeco(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(
    color: AppTheme.adminWhite,
    fontWeight: FontWeight.w600,
  ),
  filled: true,
  fillColor: AppTheme.adminGreenLite.withOpacity(.35),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: AppTheme.adminGreenDarker),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide:
    const BorderSide(color: AppTheme.adminGreen, width: 1.2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Colors.redAccent),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide:
    const BorderSide(color: Colors.redAccent, width: 1.2),
  ),
);

InputDecoration _amountDeco(String label) =>
    _inputDeco(label).copyWith(
      suffixText: '₹',
      suffixStyle: const TextStyle(color: AppTheme.adminWhite),
    );
