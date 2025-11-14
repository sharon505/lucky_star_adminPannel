// lib/features/master_data/widgets/open_Issue_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/viewmodel/LoginFormProvider_viewModel.dart';
import '../../reports/viewModels/product_view_model.dart';
import '../models/agent_stock_Issue_response_model.dart';
import '../viewModel/location_view_model.dart';
import '../viewModel/get_team_view_model.dart';
import '../viewModel/current_stock_view_model.dart';
import '../viewModel/team_agent_view_model.dart';
import '../viewModel/agent_stock_issue_view_model.dart';

// TARGET PAYLOAD (with NAMES):
//
// {
//   "issuedate"    : "2025-11-14",
//   "current_stock": "28535",
//   "teamcode"     : "JEBEL ALI",
//   "agent"        : "JEBEL ALI 1",
//   "Product"      : "LUCKY STAR CARD",
//   "IssueQuantity": "10",
//   "user"         : "admin",
//   "locationid"   : "1"
// }

Future<void> openIssueEntryDialog(
    BuildContext context, {
      DateTime? initialDate,
    }) async {
  // Get existing VMs from above in widget tree
  final pv = context.read<ProductViewModel>();
  final lv = context.read<LocationViewModel>();

  // Preload products + locations if empty
  if (pv.items.isEmpty && !pv.isLoading) pv.load();
  if (lv.items.isEmpty && !lv.isLoading) lv.load();

  final DateTime today = initialDate ?? DateTime.now();

  int? selectedProductId = pv.selected?.productId;
  int? selectedLocationId = lv.selectedLocationId;

  // Introduced By -> GetTeamViewModel (Team)
  int? selectedTeamId;

  // Agent -> TeamAgentViewModel (Agent list for selected team)
  int? selectedAgentDisId;

  final currentStockCtrl = TextEditingController(text: '0');
  final quantityCtrl = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();
      bool didKickoffStock = false;

      // Current user from login provider (like your Location Wise dialog)
      final login = ctx.read<LoginFormProvider>();
      final currentUser = login.username; // currently unused, but fine

      String _fmtDate(DateTime d) {
        final y = d.year.toString().padLeft(4, '0');
        final m = d.month.toString().padLeft(2, '0');
        final day = d.day.toString().padLeft(2, '0');
        return '$y-$m-$day';
      }

      return StatefulBuilder(
        builder: (ctx, setStateDialog) {
          final pvm = ctx.watch<ProductViewModel>();
          final lvm = ctx.watch<LocationViewModel>();
          final tvm = ctx.watch<GetTeamViewModel>();
          final csvm = ctx.watch<CurrentStockViewModel>();
          final avm = ctx.watch<TeamAgentViewModel>();
          final isvm = ctx.watch<AgentIssueViewModel>();

          // --- Sync text field with VM current stock ---
          currentStockCtrl.text = csvm.currentStock.toString();

          // --- One-time initial stock fetch if product already selected ---
          Future<void> _updateCurrentStock() async {
            if (selectedProductId == null) return;
            if (pvm.items.isEmpty) return;

            final productName = pvm.items
                .firstWhere(
                  (e) => e.productId == selectedProductId!,
              orElse: () => pvm.items.first,
            )
                .productName;

            try {
              await ctx.read<CurrentStockViewModel>().fetch(product: productName);
              final stockVm = ctx.read<CurrentStockViewModel>();
              currentStockCtrl.text = stockVm.currentStock.toString();
            } catch (_) {
              // error will be shown via csvm.error
            }
          }

          if (!didKickoffStock) {
            didKickoffStock = true;
            if (selectedProductId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateCurrentStock();
              });
            }
          }

          // --- SAFE VALUES for each dropdown (avoid “value not in items” crash) ---

          int? productValue = selectedProductId;
          if (productValue != null &&
              !pvm.items.any((e) => e.productId == productValue)) {
            productValue = null;
          }

          int? locationValue = selectedLocationId;
          if (locationValue != null &&
              !lvm.items.any((e) => e.locationId == locationValue)) {
            locationValue = null;
          }

          int? teamValue = selectedTeamId;
          if (teamValue != null &&
              !tvm.items.any((e) => e.teamId == teamValue)) {
            teamValue = null;
          }

          int? agentValue = selectedAgentDisId;
          if (agentValue != null &&
              !avm.items.any((e) => e.disId == agentValue)) {
            agentValue = null;
          }

          // use ViewModel's isSubmitting flag
          final bool disabled = isvm.isSubmitting;

          return AlertDialog(
            backgroundColor: AppTheme.adminGreenDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Issue Entry',
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

                    // -------- Issue Date (read-only) --------
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
                        text: _fmtDate(today),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // -------- Product --------
                    DropdownButtonFormField<int>(
                      value: productValue ?? pvm.selected?.productId,
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
                        setStateDialog(() => selectedProductId = v);

                        if (v == null) {
                          currentStockCtrl.text = '0';
                          return;
                        }

                        final sel =
                        pvm.items.firstWhere((e) => e.productId == v);
                        pvm.select(sel);
                        await _updateCurrentStock();
                      },
                      decoration: _inputDeco('Product'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) =>
                      (v == null && pvm.items.isEmpty)
                          ? 'No products available'
                          : (v == null ? 'Select a product' : null),
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

                    // -------- Location --------
                    DropdownButtonFormField<int>(
                      value: locationValue ?? lvm.selectedLocationId,
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
                        setStateDialog(() {
                          selectedLocationId = v;
                          selectedTeamId = null;
                          selectedAgentDisId = null;
                        });

                        // Reset team + agent lists
                        ctx.read<GetTeamViewModel>().reset();
                        ctx.read<TeamAgentViewModel>().reset();

                        if (v != null) {
                          lvm.setLocation(v);

                          // Load teams for this location
                          await ctx
                              .read<GetTeamViewModel>()
                              .load(locationId: v, forceRefresh: true);
                        }
                      },
                      decoration: _inputDeco('Location'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) =>
                      (v == null && lvm.items.isEmpty)
                          ? 'No locations available'
                          : (v == null ? 'Select a location' : null),
                    ),
                    if (lvm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (lvm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        lvm.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // -------- Current Stock --------
                    TextFormField(
                      controller: currentStockCtrl,
                      readOnly: true,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                      style: const TextStyle(
                        color: AppTheme.adminWhite,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _amountDeco('Current Stock'),
                    ),
                    if (csvm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (csvm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        csvm.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // -------- Introduced By (Team) --------
                    DropdownButtonFormField<int>(
                      value: teamValue,
                      items: [
                        for (final t in tvm.items)
                          DropdownMenuItem<int>(
                            value: t.teamId,
                            child: Text(
                              t.teamName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: disabled
                          ? null
                          : (v) async {
                        setStateDialog(() {
                          selectedTeamId = v;
                          selectedAgentDisId = null;
                        });

                        ctx.read<TeamAgentViewModel>().reset();

                        if (v != null) {
                          tvm.selectById(v);

                          // Load agents for this team
                          await ctx
                              .read<TeamAgentViewModel>()
                              .load(teamId: v, forceRefresh: true);
                        }
                      },
                      decoration: _inputDeco('Introduced By'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) {
                        if (locationValue == null) {
                          return 'Select location first';
                        }
                        if (tvm.isLoading) return null;
                        if (tvm.items.isEmpty) {
                          return 'No team found for this location';
                        }
                        if (v == null) return 'Select Introduced By';
                        return null;
                      },
                    ),
                    if (tvm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (tvm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        tvm.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // -------- Agent --------
                    DropdownButtonFormField<int>(
                      value: agentValue,
                      items: [
                        for (final a in avm.items)
                          DropdownMenuItem<int>(
                            value: a.disId,
                            child: Text(
                              a.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: disabled
                          ? null
                          : (v) {
                        setStateDialog(() => selectedAgentDisId = v);
                        if (v != null) {
                          avm.selectByDisId(v);
                        }
                      },
                      decoration: _inputDeco('Agent'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) {
                        if (teamValue == null) {
                          return 'Select Introduced By first';
                        }
                        if (avm.isLoading) return null;
                        if (avm.items.isEmpty) {
                          return 'No agents found for this team';
                        }
                        if (v == null) return 'Select an agent';
                        return null;
                      },
                    ),
                    if (avm.isLoading) ...[
                      SizedBox(height: 8.h),
                      const LinearProgressIndicator(color: AppTheme.adminGreen),
                    ],
                    if (avm.error != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        avm.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // -------- Quantity --------
                    TextFormField(
                      controller: quantityCtrl,
                      enabled: !disabled,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                      decoration: _amountDeco('Quantity'),
                      style: const TextStyle(
                        color: AppTheme.adminWhite,
                        fontWeight: FontWeight.w700,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter quantity';
                        }
                        final x = int.tryParse(v.trim());
                        if (x == null) return 'Invalid number';
                        if (x <= 0) return 'Must be greater than zero';

                        final current =
                            int.tryParse(currentStockCtrl.text.trim()) ?? 0;
                        if (current > 0 && x > current) {
                          return 'Cannot issue more than current stock';
                        }
                        return null;
                      },
                    ),

                    if (isvm.errorMessage != null) ...[
                      SizedBox(height: 10.h),
                      Text(
                        isvm.errorMessage!,
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
                  if (!formKey.currentState!.validate()) return;

                  if (locationValue == null ||
                      productValue == null ||
                      teamValue == null ||
                      agentValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select product, location, team and agent.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // TEAM -> use its NAME as teamcode (e.g. "JEBEL ALI")
                  final team = tvm.items
                      .firstWhere((t) => t.teamId == teamValue);
                  final String teamCode = team.teamName;

                  // AGENT -> use its NAME (e.g. "JEBEL ALI 1")
                  final agentItem = avm.items
                      .firstWhere((a) => a.disId == agentValue);
                  final String agentName = agentItem.name;

                  // PRODUCT -> use its NAME (e.g. "LUCKY STAR CARD")
                  final productItem = pvm.items
                      .firstWhere((e) => e.productId == productValue);
                  final String productName = productItem.productName;

                  // User
                  final uname =
                      ctx.read<LoginFormProvider>().username;

                  final issueDate = _fmtDate(today);
                  final currentStock =
                      int.tryParse(currentStockCtrl.text.trim()) ?? 0;
                  final qty = int.parse(quantityCtrl.text.trim());

                  // Call ViewModel
                  AgentStockIssueResponse? resp;
                  try {
                    resp = await ctx
                        .read<AgentIssueViewModel>()
                        .submitIssue(
                      issueDate: issueDate,
                      currentStock: currentStock,
                      teamCode: teamCode,      // "JEBEL ALI"
                      agent: agentName,        // "JEBEL ALI 1"
                      product: productName,    // "LUCKY STAR CARD"
                      issueQuantity: qty,
                      user: uname,
                      locationId: locationValue!,
                    );
                  } catch (_) {
                    // submitIssue rethrows; we just treat as failure
                    resp = null;
                  }

                  if (!ctx.mounted) return;

                  if (resp != null) {
                    // If you need voucher, extract from resp here
                    // e.g.: final voucher = resp.result.first.column1;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('Issue saved successfully.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isvm.errorMessage ??
                              'Failed to save issue.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: isvm.isSubmitting
                    ? SizedBox(
                  height: 18.r,
                  width: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Text('SUBMIT'),
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
      suffixText: 'Qty',
      suffixStyle: const TextStyle(color: AppTheme.adminWhite),
    );
