import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lucky_star_admin/core/constants/app_appbar.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import 'package:lucky_star_admin/core/theme/text_styles.dart';

import 'package:lucky_star_admin/features/reports/models/product_models.dart';
import '../../reports/viewModels/product_view_model.dart';

class ProductMasterPage extends StatefulWidget {
  const ProductMasterPage({super.key});

  @override
  State<ProductMasterPage> createState() => _ProductMasterPageState();
}

class _ProductMasterPageState extends State<ProductMasterPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure list is loaded if navigated directly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProductViewModel>();
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
    final vm = context.watch<ProductViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.adminGreenDark,
      appBar: const AppAppbar(text: 'Products'),
      body: Stack(
        children: [
          // Background gradient with your palette
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
          // Subtle glow accents
          Positioned(
            top: -120.h, left: -60.w,
            child: _GlowBall(size: 240.w, color: AppTheme.adminGreen.withOpacity(.22)),
          ),
          Positioned(
            bottom: -150.h, right: -80.w,
            child: _GlowBall(size: 300.w, color: AppTheme.adminWhite.withOpacity(.12)),
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
                    hintText: 'Search products...',
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
                    const _EmptyBox(text: 'No products found')
                  else
                    ...vm.filteredItems.map((p) => _ProductTile(item: p)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative soft glow
class _GlowBall extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBall({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: size * .6, spreadRadius: size * .25)],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductItem item;
  const _ProductTile({required this.item});

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
              child: Icon(Icons.inventory_2_outlined, color: AppTheme.adminWhite, size: 22.sp),
            ),
            title: Text(
              item.productName,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTypography.heading3.copyWith(
                color: AppTheme.adminWhite, fontSize: 15.sp, fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'ID: ${item.productId}',
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
                  content: Text('Selected: ${item.productName}',
                      style: AppTypography.body.copyWith(color: AppTheme.adminWhite)),
                  backgroundColor: AppTheme.adminGreenDark,
                ),
              );
              context.read<ProductViewModel>().select(item);
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
        leading: const Icon(Icons.error_outline, color: Colors.red),
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
