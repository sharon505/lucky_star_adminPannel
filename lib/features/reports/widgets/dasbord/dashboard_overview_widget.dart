// lib/features/financial_overview/widgets/dashboard_overview_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../viewModels/dashboard_view_model.dart';

class DashboardOverview extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Future<void> Function()? onRefresh;
  final bool embedded;

  // Headline values (big tile)
  final double totalStock;
  final double issuedStock;
  final double currentStock;

  // Remaining metric cards (grid)
  final List<DashboardMetric> metrics;

  const DashboardOverview({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.embedded,
    required this.totalStock,
    required this.issuedStock,
    required this.currentStock,
    required this.metrics,
  });

  factory DashboardOverview.fromViewModel({
    Key? key,
    required DashboardViewModel vm,
    Future<void> Function()? onRefresh,
    bool embedded = false,
  }) {
    // Only the "other" metrics go in the grid
    final remaining = <DashboardMetric>[
      DashboardMetric(
        title: "Today's Sale Count",
        value: vm.todaysSaleCount,
        icon: Icons.shopping_cart_checkout_rounded,
        color1: Colors.pinkAccent,
        color2: Colors.deepPurpleAccent,
      ),
      DashboardMetric(
        title: "Today's Sale Value",
        value: vm.todaysSaleValue,
        icon: Icons.attach_money_rounded,
        color1: Colors.greenAccent,
        color2: Colors.green,
      ),
      DashboardMetric(
        title: 'Prized Payout',
        value: vm.todaysPrizedPayout,
        icon: Icons.monetization_on_rounded,
        color1: Colors.amberAccent,
        color2: Colors.deepOrangeAccent,
      ),
      DashboardMetric(
        title: "Today's Prized Count",
        value: vm.todaysPrizedCount,
        icon: Icons.emoji_events_rounded,   // changed icon
        color1: Colors.cyanAccent,          // changed colors
        color2: Colors.teal,
      ),

    ];

    return DashboardOverview(
      key: key,
      isLoading: vm.isLoading,
      error: vm.error,
      onRefresh: onRefresh ?? vm.refresh,
      embedded: embedded,
      totalStock: vm.totalStock,
      issuedStock: vm.issuedStock,
      currentStock: vm.currentStock,
      metrics: remaining,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.adminGreen));
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $error', style: const TextStyle(color: Colors.redAccent)),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.adminGreen),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final content = Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- BIG HEAD TILE (3 values) ---
          FadeInUp(
            duration: const Duration(milliseconds: 450),
            child: _MetricBigCard(
              totalStock: totalStock,
              issuedStock: issuedStock,
              currentStock: currentStock,
              theme: _BigCardTheme.bluePurple,
            ),
          ),
          SizedBox(height: 12.h),

          // --- GRID OF THE REST (4 columns) ---
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,            // ← as requested
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.50.h,
            ),
            itemCount: metrics.length,
            itemBuilder: (_, i) => FadeInUp(
              delay: Duration(milliseconds: 90 * i),
              duration: const Duration(milliseconds: 420),
              child: _MetricCard(data: metrics[i]),
            ),
          ),
        ],
      ),
    );

    if (!embedded && onRefresh != null) {
      return RefreshIndicator(
        color: AppTheme.adminGreen,
        onRefresh: onRefresh!,
        child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: content),
      );
    }

    return content;
  }
}

class DashboardMetric {
  final String title;
  final double value;
  final IconData icon;
  final Color color1;
  final Color color2;

  DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color1,
    required this.color2,
  });
}

/// Big combined tile for (Total, Issued, Current) stock
class _MetricBigCard extends StatelessWidget {
  final double totalStock;
  final double issuedStock;
  final double currentStock;

  /// Choose a preset theme or pass custom colors.
  final _BigCardTheme theme;

  const _MetricBigCard({
    required this.totalStock,
    required this.issuedStock,
    required this.currentStock,
    this.theme = _BigCardTheme.emerald, // default
  });

  @override
  Widget build(BuildContext context) {
    final colors = _themeColors(theme);

    TextStyle labelStyle = TextStyle(
      color: colors.onTile.withOpacity(.9),
      fontWeight: FontWeight.w600,
      fontSize: 12.sp,
    );

    TextStyle valueStyle = TextStyle(
      color: colors.onTile,
      fontWeight: FontWeight.w800,
      fontSize: 20.sp,
      letterSpacing: .3,
    );

    Widget cell(String label, double value, IconData icon) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colors.tileOverlay,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: colors.tileBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colors.iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: colors.onTile, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value.toStringAsFixed(2), style: valueStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 160.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.grad1, colors.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: colors.grad2.withOpacity(.30),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -22,
            child: Icon(Icons.inventory_2_rounded, size: 120.sp, color: colors.bigIcon),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Stock Summary',
                    style: TextStyle(
                      color: colors.onTile,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                LayoutBuilder(
                  builder: (context, c) {
                    final isNarrow = c.maxWidth < 600;
                    if (isNarrow) {
                      return Column(
                        children: [
                          cell('Total Stock', totalStock, Icons.inventory_2_rounded),
                          SizedBox(height: 10.h),
                          cell('Issued Stock', issuedStock, Icons.outbox_rounded),
                          SizedBox(height: 10.h),
                          cell('Current Stock', currentStock, Icons.store_rounded),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: cell('Total Stock', totalStock, Icons.inventory_2_rounded)),
                        SizedBox(width: 10.w),
                        Expanded(child: cell('Issued Stock', issuedStock, Icons.outbox_rounded)),
                        SizedBox(width: 10.w),
                        Expanded(child: cell('Current Stock', currentStock, Icons.store_rounded)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Preset themes
enum _BigCardTheme { emerald, bluePurple, sunset, rose, slate }

class _BigCardColors {
  final Color grad1, grad2, onTile, tileOverlay, tileBorder, iconBg, bigIcon;
  const _BigCardColors({
    required this.grad1,
    required this.grad2,
    required this.onTile,
    required this.tileOverlay,
    required this.tileBorder,
    required this.iconBg,
    required this.bigIcon,
  });
}

_BigCardColors _themeColors(_BigCardTheme t) {
  switch (t) {
    case _BigCardTheme.bluePurple:
      return _BigCardColors(
        grad1: const Color(0xFF7F7FFF).withOpacity(.95),
        grad2: const Color(0xFF6A00FF).withOpacity(.95),
        onTile: Colors.white,
        tileOverlay: Colors.white.withOpacity(.08),
        tileBorder: Colors.white.withOpacity(.10),
        iconBg: Colors.white.withOpacity(.10),
        bigIcon: Colors.white.withOpacity(.08),
      );
    case _BigCardTheme.sunset:
      return _BigCardColors(
        grad1: const Color(0xFFFFA351).withOpacity(.95),
        grad2: const Color(0xFFFF5E62).withOpacity(.95),
        onTile: Colors.black,
        tileOverlay: Colors.white.withOpacity(.30),
        tileBorder: Colors.black.withOpacity(.06),
        iconBg: Colors.white.withOpacity(.45),
        bigIcon: Colors.black.withOpacity(.08),
      );
    case _BigCardTheme.rose:
      return _BigCardColors(
        grad1: const Color(0xFFFF8AC9).withOpacity(.95),
        grad2: const Color(0xFFFF3377).withOpacity(.95),
        onTile: Colors.white,
        tileOverlay: Colors.white.withOpacity(.10),
        tileBorder: Colors.white.withOpacity(.12),
        iconBg: Colors.white.withOpacity(.12),
        bigIcon: Colors.white.withOpacity(.10),
      );
    case _BigCardTheme.slate:
      return _BigCardColors(
        grad1: const Color(0xFF7A8CA0).withOpacity(.95),
        grad2: const Color(0xFF3B4753).withOpacity(.95),
        onTile: Colors.white,
        tileOverlay: Colors.white.withOpacity(.06),
        tileBorder: Colors.white.withOpacity(.10),
        iconBg: Colors.white.withOpacity(.10),
        bigIcon: Colors.white.withOpacity(.08),
      );
    case _BigCardTheme.emerald:
    default:
      return _BigCardColors(
        grad1: Colors.tealAccent.withOpacity(.95),
        grad2: AppTheme.adminGreen.withOpacity(.95),
        onTile: Colors.white,
        tileOverlay: Colors.white.withOpacity(.07),
        tileBorder: Colors.white.withOpacity(.10),
        iconBg: Colors.white.withOpacity(.08),
        bigIcon: Colors.white.withOpacity(.08),
      );
  }
}


/// Small metric tile for the remaining items
class _MetricCard extends StatelessWidget {
  final DashboardMetric data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [data.color1.withOpacity(.9), data.color2.withOpacity(.9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: data.color2.withOpacity(.3),
            offset: const Offset(0, 5),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Icon(
              data.icon,
              size: 95.sp,
              color: Colors.white.withOpacity(.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(data.icon, size: 28.sp, color: Colors.white),
                SizedBox(height: 6.h),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    // height: 1.2,
                  ),
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value.toStringAsFixed(2),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
