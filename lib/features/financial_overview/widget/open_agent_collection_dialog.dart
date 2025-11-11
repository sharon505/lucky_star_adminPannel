// lib/features/financial_overview/dialogs/agent_collection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../reports/viewModels/product_view_model.dart';
import '../../reports/viewModels/distributor_view_model.dart';
import '../viewModels/agent_receivables_view_model.dart';

Future<void> openAgentCollectionDialog(BuildContext context, {DateTime? initialDate}) async {
  // keep for future (API may need it)
  final DateTime date = initialDate ?? DateTime.now();

  final pv = context.read<ProductViewModel>();
  final dv = context.read<DistributorViewModel>();

  // preload dropdown data if needed
  if (pv.items.isEmpty && !pv.isLoading) pv.load();
  if (dv.items.isEmpty && !dv.isLoading) dv.load();

  // local selection state
  int? selProductId = pv.selected?.productId;
  int? selAgentId   = dv.selected?.distributorId;

  // controllers
  final receivableCtrl = TextEditingController(text: '0.00');
  final amountCtrl     = TextEditingController(text: '0.00');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();
      bool _didKickoff = false; // guard for initial post-frame fetch

      return StatefulBuilder(
        builder: (ctx, setStateDialog) {
          final pvm = ctx.watch<ProductViewModel>();
          final dvm = ctx.watch<DistributorViewModel>();
          final rvm = ctx.watch<AgentReceivablesViewModel>(); // observe loading/error

          // Resolve + fetch receivable and put into the field
          Future<void> _updateReceivable() async {
            // effective product (selected -> vm.selected -> first)
            final int? effectiveProductId =
                selProductId ??
                    pvm.selected?.productId ??
                    (pvm.items.isNotEmpty ? pvm.items.first.productId : null);

            // effective agent (selected -> vm.selected -> first)
            final int? effectiveAgentId =
                selAgentId ??
                    dvm.selected?.distributorId ??
                    (dvm.items.isNotEmpty ? dvm.items.first.distributorId : null);

            if (effectiveProductId == null || effectiveAgentId == null) return;

            try {
              final amt = await ctx.read<AgentReceivablesViewModel>().fetch(
                agentId: effectiveAgentId,
                productId: effectiveProductId,
              );
              receivableCtrl.text = amt.toStringAsFixed(2);
            } catch (_) {
              // rvm.error is displayed below
            }
          }

          // Initial fetch (deferred) if we can resolve ids and field is default
          if (!_didKickoff && receivableCtrl.text == '0.00') {
            _didKickoff = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateReceivable();
            });
          }

          return AlertDialog(
            backgroundColor: AppTheme.adminGreenDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            title: const Text(
              'Filter — Agent Collection',
              style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---------- Product ----------
                    DropdownButtonFormField<int>(
                      value: selProductId ?? pvm.selected?.productId,
                      items: [
                        for (final it in pvm.items)
                          DropdownMenuItem<int>(
                            value: it.productId,
                            child: Text(it.productName, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (v) async {
                        setStateDialog(() => selProductId = v);
                        if (v != null) {
                          final sel = pvm.items.firstWhere((e) => e.productId == v);
                          pvm.select(sel);
                        }
                        await _updateReceivable(); // safe (user-initiated)
                      },
                      validator: (v) => v == null && pvm.items.isEmpty ? 'No products available' : null,
                      decoration: _inputDeco('Product'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    ),
                    if (pvm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (pvm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(pvm.error!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    SizedBox(height: 12.h),

                    // ---------- Agent ----------
                    DropdownButtonFormField<int>(
                      value: selAgentId ?? dvm.selected?.distributorId,
                      items: [
                        for (final it in dvm.items)
                          DropdownMenuItem<int>(
                            value: it.distributorId,
                            child: Text(it.name, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (v) async {
                        setStateDialog(() => selAgentId = v);
                        if (v != null) {
                          final sel = dvm.items.firstWhere((e) => e.distributorId == v);
                          dvm.select(sel);
                        }
                        await _updateReceivable(); // safe (user-initiated)
                      },
                      validator: (v) => v == null && dvm.items.isEmpty ? 'No agents available' : null,
                      decoration: _inputDeco('Agent'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    ),
                    if (dvm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (dvm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(dvm.error!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    SizedBox(height: 12.h),

                    // ---------- Amount Receivable (from API) ----------
                    TextFormField(
                      controller: receivableCtrl,
                      readOnly: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
                      decoration: _amountDeco('Amount Receivable'),
                    ),
                    if (rvm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (rvm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(rvm.error!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    SizedBox(height: 12.h),

                    // ---------- Amount (editable) ----------
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
                      decoration: _amountDeco('Amount'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter amount';
                        final x = double.tryParse(v.trim());
                        if (x == null) return 'Invalid number';
                        final recv = double.tryParse(receivableCtrl.text.trim()) ?? double.infinity;
                        if (x < 0) return 'Amount cannot be negative';
                        if (recv.isFinite && x > recv) return 'Amount exceeds receivable';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL', style: TextStyle(color: AppTheme.adminWhite)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.adminGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  // Resolve final IDs for submit too (same rule as receivable)
                  final int? effectiveProductId =
                      selProductId ??
                          pvm.selected?.productId ??
                          (pvm.items.isNotEmpty ? pvm.items.first.productId : null);

                  final int? effectiveAgentId =
                      selAgentId ??
                          dvm.selected?.distributorId ??
                          (dvm.items.isNotEmpty ? dvm.items.first.distributorId : null);

                  if (effectiveProductId == null || effectiveAgentId == null) return;

                  final entered = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

                  // TODO: submit your collection here with (date, effectiveProductId, effectiveAgentId, entered)

                  Navigator.pop(ctx);
                },
                child: const Text('SUBMIT'),
              ),
            ],
          );
        },
      );
    },
  );
}

InputDecoration _inputDeco(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w600),
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
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Colors.redAccent),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
  ),
);

InputDecoration _amountDeco(String label) =>
    _inputDeco(label).copyWith(suffixText: '₹', suffixStyle: const TextStyle(color: AppTheme.adminWhite));
