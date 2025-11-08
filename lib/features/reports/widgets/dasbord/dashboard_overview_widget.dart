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
  final List<DashboardMetric> metrics;
  final bool embedded;

  const DashboardOverview({
    super.key,
    required this.isLoading,
    required this.metrics,
    this.error,
    this.onRefresh,
    this.embedded = false,
  });

  factory DashboardOverview.fromViewModel({
    Key? key,
    required DashboardViewModel vm,
    Future<void> Function()? onRefresh,
    bool embedded = false,
  }) {
    final metrics = <DashboardMetric>[
      DashboardMetric(
        title: 'Total Stock',
        value: vm.totalStock,
        icon: Icons.inventory_2_rounded,
        color1: Colors.tealAccent,
        color2: AppTheme.adminGreen,
      ),
      DashboardMetric(
        title: 'Issued Stock',
        value: vm.issuedStock,
        icon: Icons.outbox_rounded,
        color1: Colors.orangeAccent,
        color2: Colors.deepOrange,
      ),
      DashboardMetric(
        title: 'Current Stock',
        value: vm.currentStock,
        icon: Icons.store_rounded,
        color1: Colors.lightBlueAccent,
        color2: Colors.blueAccent,
      ),
      DashboardMetric(
        title: 'Today\'s Sale Count',
        value: vm.todaysSaleCount,
        icon: Icons.shopping_cart_checkout_rounded,
        color1: Colors.pinkAccent,
        color2: Colors.deepPurpleAccent,
      ),
      DashboardMetric(
        title: 'Today\'s Sale Value',
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
    ];

    return DashboardOverview(
      key: key,
      isLoading: vm.isLoading,
      error: vm.error,
      onRefresh: onRefresh ?? vm.refresh,
      metrics: metrics,
      embedded: embedded,
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

    final grid = GridView.builder(
      shrinkWrap: true,
      physics: embedded
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // <── FIXED 3 COLUMNS
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.70,
      ),
      itemCount: metrics.length,
      itemBuilder: (_, i) => FadeInUp(
        delay: Duration(milliseconds: 80 * i),
        duration: const Duration(milliseconds: 450),
        child: _MetricCard(data: metrics[i]),
      ),
    );

    if (!embedded && onRefresh != null) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: RefreshIndicator(
          color: AppTheme.adminGreen,
          onRefresh: onRefresh!,
          child: grid,
        ),
      );
    }

    return Padding(padding: EdgeInsets.all(12.w), child: grid);
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
                Flexible(
                  child: Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.95),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
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

