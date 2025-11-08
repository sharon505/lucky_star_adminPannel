import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import 'package:lucky_star_admin/core/constants/app_appbar.dart';      // <-- use your AppAppbar
import 'package:lucky_star_admin/core/theme/text_styles.dart';         // <-- use your AppTypography

import 'package:lucky_star_admin/features/reports/models/distributor_models.dart';
import '../../reports/viewModels/distributor_view_model.dart';

class AgentMasterPage extends StatefulWidget {
  const AgentMasterPage({super.key});

  @override
  State<AgentMasterPage> createState() => _AgentMasterPageState();
}

class _AgentMasterPageState extends State<AgentMasterPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DistributorViewModel>();
      if (vm.items.isEmpty && !vm.isLoading) vm.load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DistributorViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.adminGreenDark,
      appBar: const AppAppbar(text: 'Agents'), // <-- your custom app bar
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.adminGreenLite, AppTheme.adminGreenDark],
                ),
              ),
            ),
          ),

          // Content
          RefreshIndicator(
            color: AppTheme.adminGreen,
            backgroundColor: AppTheme.adminGreenDark,
            onRefresh: () => vm.load(),
            child: ListView(
              padding: EdgeInsets.all(12.w),
              children: [
                // Search
                TextField(
                  controller: _search,
                  onChanged: vm.setQuery,
                  style: AppTypography.body.copyWith(
                    color: AppTheme.adminWhite, fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search,
                        color: AppTheme.adminWhite.withOpacity(.8), size: 20.sp),
                    hintText: 'Search agents...',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppTheme.adminWhite.withOpacity(.7), fontSize: 13.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(.06),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppTheme.adminWhite.withOpacity(.12), width: 1.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppTheme.adminWhite.withOpacity(.9), width: 1.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                if (vm.isLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: const CircularProgressIndicator(),
                    ),
                  )
                else if (vm.error != null)
                  _ErrorBox(message: vm.error!, onRetry: () => vm.load())
                else if (vm.filteredItems.isEmpty)
                    const _EmptyBox(text: 'No agents found')
                  else
                    ...vm.filteredItems.map((a) => _AgentTile(item: a)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentTile extends StatelessWidget {
  final DistributorItem item;
  const _AgentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            AppTheme.adminGreenDark.withOpacity(.65),
            AppTheme.adminGreenLite.withOpacity(.65),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // glass overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white.withOpacity(.06),
                border: Border.all(color: Colors.white.withOpacity(.12), width: 1.r),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            leading: Container(
              width: 42.w, height: 42.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(.18), width: 1.r),
              ),
              child: Icon(Icons.person_outline, color: AppTheme.adminGreen, size: 22.sp),
            ),
            title: Text(
              item.name,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTypography.heading3.copyWith(
                color: AppTheme.adminWhite, fontSize: 15.sp, fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'ID: ${item.distributorId}',
                style: AppTypography.body.copyWith(
                  color: AppTheme.adminWhite.withOpacity(.75), fontSize: 12.5.sp,
                ),
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppTheme.adminWhite.withOpacity(.9), size: 22.sp),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${item.name}',
                      style: AppTypography.body.copyWith(color: AppTheme.adminWhite)),
                  backgroundColor: AppTheme.adminGreenDark,
                ),
              );
              context.read<DistributorViewModel>().select(item);
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Icon(Icons.error_outline, color: AppTheme.adminGreen),
        title: Text(
          message,
          style: AppTypography.body.copyWith(
            color: AppTheme.adminWhite, fontSize: 13.sp,
          ),
        ),
        trailing: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.adminGreenDarker.withOpacity(.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Center(
          child: Text(
            text,
            style: AppTypography.heading3.copyWith(
              color: AppTheme.adminWhite, fontSize: 14.sp, fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
