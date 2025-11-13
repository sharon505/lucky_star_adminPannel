import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../core/theme/text_styles.dart';
import '../../reports/viewModels/product_view_model.dart';
import '../viewModel/location_view_model.dart';
import '../viewModel/get_team_view_model.dart';
import '../viewModel/current_stock_view_model.dart';
import '../viewModel/team_agent_view_model.dart';

Future<void> openIssueEntryDialog(BuildContext context) async {
  // Get existing VMs from above in widget tree
  final pv = context.read<ProductViewModel>();
  final lv = context.read<LocationViewModel>();

  // Preload products + locations if empty
  if (pv.items.isEmpty && !pv.isLoading) pv.load();
  if (lv.items.isEmpty && !lv.isLoading) lv.load();

  int? selectedProductId  = pv.selected?.productId;
  int? selectedLocationId = lv.selectedLocationId;

  // Introduced By -> GetTeamViewModel (Team)
  int? selectedTeamId;

  // Agent -> TeamAgentViewModel (Agent list for selected team)
  int? selectedAgentDisId;

  final currentStockCtrl = TextEditingController(text: '0');
  final quantityCtrl     = TextEditingController();

  final today   = DateTime.now();
  final formKey = GlobalKey<FormState>();

  // For one-time initial current-stock fetch
  bool didKickoffStock = false;

  String _fmtDate(DateTime d) {
    final y   = d.year.toString().padLeft(4, '0');
    final m   = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setStateDialog) {
          final pvm  = ctx.watch<ProductViewModel>();
          final lvm  = ctx.watch<LocationViewModel>();
          final tvm  = ctx.watch<GetTeamViewModel>();
          final csvm = ctx.watch<CurrentStockViewModel>();
          final avm  = ctx.watch<TeamAgentViewModel>();

          // --- Sync text field with VM current stock ---
          currentStockCtrl.text = csvm.currentStock.toString();

          // --- One-time initial stock fetch if product already selected ---
          if (!didKickoffStock) {
            didKickoffStock = true;
            if (selectedProductId != null && pvm.items.isNotEmpty) {
              final sel = pvm.items.firstWhere(
                    (e) => e.productId == selectedProductId,
                orElse: () => pvm.items.first,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ctx
                    .read<CurrentStockViewModel>()
                    .fetch(product: sel.productName);
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

                    // -------- Issue Date (today, read-only) --------
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

                    // -------- Product (ProductViewModel + CurrentStockViewModel) --------
                    DropdownButtonFormField<int>(
                      value: productValue,
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
                      onChanged: (v) async {
                        setStateDialog(() => selectedProductId = v);

                        // Reset stock & clear if no product
                        if (v == null) {
                          currentStockCtrl.text = '0';
                          return;
                        }

                        final sel = pvm.items.firstWhere(
                              (e) => e.productId == v,
                        );
                        pvm.select(sel);

                        // Fetch current stock for selected product
                        await ctx
                            .read<CurrentStockViewModel>()
                            .fetch(product: sel.productName);
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

                    // -------- Location (LocationViewModel) --------
                    DropdownButtonFormField<int>(
                      value: locationValue,
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
                      onChanged: (v) async {
                        setStateDialog(() {
                          selectedLocationId = v;
                          selectedTeamId     = null; // reset Introduced By
                          selectedAgentDisId = null; // reset Agent
                        });

                        // Reset team + agent VMs when location changes
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

                    // -------- Current Stock (from CurrentStockViewModel) --------
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

                    // -------- Introduced By (Team / GetTeamViewModel) --------
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
                      onChanged: (v) async {
                        setStateDialog(() {
                          selectedTeamId     = v;
                          selectedAgentDisId = null; // reset agent
                        });

                        // Reset Agent list whenever team changes
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
                        if (tvm.isLoading) return null; // while loading
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

                    // -------- Agent (TeamAgentViewModel) --------
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
                      onChanged: (v) {
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
                        if (avm.isLoading) return null; // while loading
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
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
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppTheme.adminWhite),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.adminGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  // Use safe values we computed:
                  final issueDate     = today;
                  final productId     = productValue;
                  final locationId    = locationValue;
                  final currentStock  = csvm.currentStock;
                  final teamId        = teamValue;
                  final teamName      = tvm.selectedTeamName;
                  final agentDisId    = agentValue;
                  final agentName     = avm.selectedName;
                  final agentCode     = avm.selectedCode;
                  final qty           = int.parse(quantityCtrl.text.trim());

                  // TODO: Call your Issue service here with above values.

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue saved (mock).'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
