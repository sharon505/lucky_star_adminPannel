import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/viewmodel/LoginFormProvider_viewModel.dart';
import '../../reports/viewModels/product_view_model.dart';
import '../../reports/viewModels/distributor_view_model.dart';
import '../../financial_overview/viewModels/agent_receivables_view_model.dart';
import '../../financial_overview/viewModels/agent_collection_view_model.dart';

Future<void> openAgentCollectionDialog(
    BuildContext context, {
      DateTime? initialDate,
    }) async {
  final DateTime date = initialDate ?? DateTime.now();

  final pv = context.read<ProductViewModel>();
  final dv = context.read<DistributorViewModel>();

  if (pv.items.isEmpty && !pv.isLoading) pv.load();
  if (dv.items.isEmpty && !dv.isLoading) dv.load();

  int? selProductId = pv.selected?.productId;
  int? selAgentId = dv.selected?.distributorId;

  final receivableCtrl = TextEditingController(text: '0.00');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();
      bool _didKickoff = false;

      // Take user from LoginFormProvider (usernameController)
      final login = ctx.read<LoginFormProvider>();
      final currentUser = login.username;

      return ChangeNotifierProvider(
        create: (_) => AgentCollectionViewModel()
          ..bootstrap(
            initialDate: date,
            initialProductId: selProductId,
            initialAgentId: selAgentId,
            initialAmount: 0,
            initialUser: currentUser,
          ),
        child: StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final pvm = ctx.watch<ProductViewModel>();
            final dvm = ctx.watch<DistributorViewModel>();
            final rvm = ctx.watch<AgentReceivablesViewModel>();
            final avm = ctx.watch<AgentCollectionViewModel>();

            Future<void> _updateReceivable() async {
              final int? effectiveProductId =
                  selProductId ??
                      pvm.selected?.productId ??
                      (pvm.items.isNotEmpty ? pvm.items.first.productId : null);

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
                // rvm.error will be shown below
              }
            }

            if (!_didKickoff && receivableCtrl.text == '0.00') {
              _didKickoff = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateReceivable();
              });
            }

            final bool disabled = avm.isSubmitting;

            return AlertDialog(
              backgroundColor: AppTheme.adminGreenDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'Agent Collection',
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
                          }
                          await _updateReceivable();
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
                        const LinearProgressIndicator(color: AppTheme.adminGreen),
                      ],
                      if (pvm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          pvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // ---------- Agent ----------
                      DropdownButtonFormField<int>(
                        value: selAgentId ?? dvm.selected?.distributorId,
                        items: [
                          for (final it in dvm.items)
                            DropdownMenuItem<int>(
                              value: it.distributorId,
                              child: Text(
                                it.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: disabled
                            ? null
                            : (v) async {
                          setStateDialog(() => selAgentId = v);
                          if (v != null) {
                            final sel = dvm.items.firstWhere(
                                  (e) => e.distributorId == v,
                            );
                            dvm.select(sel);
                          }
                          await _updateReceivable();
                        },
                        validator: (v) => v == null && dvm.items.isEmpty
                            ? 'No agents available'
                            : null,
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
                        Text(
                          dvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // ---------- Amount Receivable (from API) ----------
                      TextFormField(
                        controller: receivableCtrl,
                        readOnly: true,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          color: AppTheme.adminWhite,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _amountDeco('Amount Receivable'),
                      ),
                      if (rvm.isLoading) ...[
                        SizedBox(height: 8.h),
                        const LinearProgressIndicator(color: AppTheme.adminGreen),
                      ],
                      if (rvm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          rvm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // ---------- Amount (editable; bound to VM) ----------
                      TextFormField(
                        controller: avm.amountCtrl,
                        enabled: !disabled,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          // allow empty, digits, one dot, up to 2 decimals
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,9}(\.\d{0,2})?$'),
                          ),
                        ],
                        onChanged: avm.setAmountFromString, // no rewriting
                        style: const TextStyle(
                          color: AppTheme.adminWhite,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _amountDeco('Amount'),
                        validator: (v) {
                          final recv = double.tryParse(
                            receivableCtrl.text.trim(),
                          ) ??
                              double.infinity;

                          if (v == null || v.trim().isEmpty) {
                            return 'Enter amount';
                          }
                          final x = double.tryParse(v.trim());
                          if (x == null) return 'Invalid number';
                          if (x <= 0) return 'Amount must be greater than zero';
                          if (recv.isFinite && x > recv) {
                            return 'Amount exceeds receivable';
                          }
                          return null;
                        },
                      ),

                      if (avm.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          avm.error!,
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
                    'CANCEL',
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
                    if (!formKey.currentState!.validate()) return;

                    final int? effectiveProductId =
                        selProductId ??
                            pvm.selected?.productId ??
                            (pvm.items.isNotEmpty
                                ? pvm.items.first.productId
                                : null);

                    final int? effectiveAgentId =
                        selAgentId ??
                            dvm.selected?.distributorId ??
                            (dvm.items.isNotEmpty
                                ? dvm.items.first.distributorId
                                : null);

                    if (effectiveProductId == null ||
                        effectiveAgentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select product and agent.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Refresh user right before submit (in case it changed)
                    final uname = ctx.read<LoginFormProvider>().username;

                    avm
                      ..setDate(date)
                      ..setProduct(effectiveProductId)
                      ..setAgent(effectiveAgentId)
                      ..setUser(uname);

                    final result = await avm.submit();

                    if (avm.isSuccess) {
                      // Format to 2 decimals after success (optional)
                      if (avm.amount != null) {
                        avm.amountCtrl.text =
                            (avm.amount as num).toStringAsFixed(2);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text(result?.msg ?? 'Collection saved'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(ctx);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Failed to submit. Please check and try again.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: avm.isSubmitting
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
