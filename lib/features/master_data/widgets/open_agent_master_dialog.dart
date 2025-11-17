// lib/features/master_data/widgets/open_agent_master_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/viewmodel/LoginFormProvider_viewModel.dart';
import '../viewModel/location_view_model.dart';
import '../viewModel/get_team_view_model.dart';
import '../viewModel/agent_master_view_model.dart';

Future<void> openAgentMasterDialog(BuildContext context) async {
  final lv = context.read<LocationViewModel>();
  final tv = context.read<GetTeamViewModel>();

  if (lv.items.isEmpty && !lv.isLoading) lv.load();

  int? selectedLocationId = lv.selectedLocationId;
  int? selectedTeamId;

  // Preload teams if location already selected
  if (selectedLocationId != null &&
      tv.items.isEmpty &&
      !tv.isLoading) {
    await tv.load(locationId: selectedLocationId, forceRefresh: true);
  }

  final nameCtrl    = TextEditingController();
  final codeCtrl    = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final emailCtrl   = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      return StatefulBuilder(
        builder: (ctx, setStateDialog) {
          final lvm = ctx.watch<LocationViewModel>();
          final tvm = ctx.watch<GetTeamViewModel>();
          final amvm = ctx.watch<AgentMasterViewModel>();
          final login = ctx.read<LoginFormProvider>();

          final bool disabled = amvm.isSubmitting;

          // SAFE values
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

          return AlertDialog(
            backgroundColor: AppTheme.adminGreenDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Agent Master',
              style: AppTypography.heading1.copyWith(
                fontSize: 17.sp,
                color: AppTheme.adminGreen,
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // AGENT NAME
                    TextFormField(
                      controller: nameCtrl,
                      enabled: !disabled,
                      decoration: _inputDeco("Agent Name"),
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? "Enter Agent Name" : null,
                    ),
                    SizedBox(height: 12.h),

                    // AGENT CODE
                    TextFormField(
                      controller: codeCtrl,
                      enabled: !disabled,
                      decoration: _inputDeco("Agent Code"),
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? "Enter Agent Code" : null,
                    ),
                    SizedBox(height: 12.h),

                    // ADDRESS
                    TextFormField(
                      controller: addressCtrl,
                      enabled: !disabled,
                      maxLines: 3,
                      decoration: _inputDeco("Address").copyWith(
                        alignLabelWithHint: true,
                      ),
                      style: const TextStyle(color: AppTheme.adminWhite),
                    ),
                    SizedBox(height: 12.h),

                    // LOCATION
                    DropdownButtonFormField<int>(
                      value: locationValue ?? lvm.selectedLocationId,
                      items: [
                        for (final it in lvm.items)
                          DropdownMenuItem<int>(
                            value: it.locationId,
                            child: Text(it.locationName),
                          ),
                      ],
                      onChanged: disabled
                          ? null
                          : (v) async {
                        setStateDialog(() {
                          selectedLocationId = v;
                          selectedTeamId = null;
                        });

                        ctx.read<GetTeamViewModel>().reset();

                        if (v != null) {
                          lvm.setLocation(v);
                          await tv.load(locationId: v, forceRefresh: true);
                        }
                      },
                      decoration: _inputDeco("Location"),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) => v == null ? "Select Location" : null,
                    ),

                    SizedBox(height: 12.h),

                    // INTRODUCED BY TEAM
                    DropdownButtonFormField<int>(
                      value: teamValue,
                      items: [
                        for (final t in tvm.items)
                          DropdownMenuItem<int>(
                            value: t.teamId,
                            child: Text(t.teamName),
                          ),
                      ],
                      onChanged: disabled
                          ? null
                          : (v) => setStateDialog(() => selectedTeamId = v),
                      decoration: _inputDeco("Introduced By"),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) => v == null ? "Select Introduced By" : null,
                    ),

                    SizedBox(height: 12.h),

                    // PHONE
                    TextFormField(
                      controller: phoneCtrl,
                      enabled: !disabled,
                      decoration: _inputDeco("Phone No"),
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppTheme.adminWhite),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? "Enter Phone No" : null,
                    ),
                    SizedBox(height: 12.h),

                    // EMAIL
                    TextFormField(
                      controller: emailCtrl,
                      enabled: !disabled,
                      decoration: _inputDeco("Email"),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    ),

                    if (amvm.errorMessage != null) ...[
                      SizedBox(height: 10.h),
                      Text(
                        amvm.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              // CLOSE BUTTON
              TextButton(
                onPressed: disabled ? null : () => Navigator.pop(ctx),
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: AppTheme.adminWhite),
                ),
              ),

              // SUBMIT BUTTON
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

                  if (selectedLocationId == null ||
                      selectedTeamId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select location and Introduced By"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  final ok =
                  await ctx.read<AgentMasterViewModel>().createAgent(
                    name: nameCtrl.text.trim(),
                    code: codeCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    locationId: selectedLocationId!,
                    teamId: selectedTeamId!,
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    user: login.username,
                  );

                  if (!ctx.mounted) return;

                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Agent saved successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          amvm.errorMessage ?? "Failed to save agent",
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: amvm.isSubmitting
                    ? SizedBox(
                  height: 18.r,
                  width: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Text("SUBMIT"),
              ),
            ],
          );
        },
      );
    },
  );
}

// --------------------------- INPUT DECORATION ----------------------------
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
    borderSide: BorderSide(color: AppTheme.adminGreen, width: 1.2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Colors.redAccent),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: BorderSide(color: Colors.redAccent, width: 1.2),
  ),
);
