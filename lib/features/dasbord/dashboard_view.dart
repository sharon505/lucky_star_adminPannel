import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/features/financial_overview/views/financial_overview_page.dart';
import 'package:lucky_star_admin/features/reports/views/reports_view.dart';

import '../../core/theme/color_scheme.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/app_gradient_background.dart';

List<_Model> list = [
  _Model(icon: Icons.bar_chart_outlined,
      text: 'Reports',
      page: ReportsView()
  ),
  _Model(
    icon: Icons.dashboard_outlined,
    // text: 'financial overview',
    text: 'overview',
    page: FinancialOverviewPage(),
  ),
  _Model(
    icon: Icons.person_2,
    text: 'settings',
    page: Center(
      child: Text("settings"),
    ),
  ),
];

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '  Lucky Star Admin',
            style: AppTypography.heading1.copyWith(
              color: AppTheme.adminGreen,
              fontSize: 17.sp,
            ),
          ),
          // centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.adminGreenDarker,
          flexibleSpace: const GradientBackground(
            colors: [AppTheme.adminDrawer, AppTheme.adminDrawer],
            child: SizedBox(),
          ),
          bottom: TabBar(
            dividerColor: AppTheme.adminGreenLite,
            labelColor: AppTheme.adminGreen,
            unselectedLabelColor: AppTheme.rewardBackground,
            indicatorColor: AppTheme.adminWhite,
            isScrollable: false,
            tabs: List.generate(
              list.length,
              (i) => Tab(icon: Icon(list[i].icon), text: list[i].text),
            ),
          ),
        ),
        body: GradientBackground(
          colors: [AppTheme.adminDrawer, AppTheme.adminDrawer],
          child: TabBarView(
            children: List.generate(list.length, (i) => list[i].page),
          ),
        ),
      ),
    );
  }
}

class _Model {
  final IconData? icon;
  final String text;
  final Widget page;

  const _Model({required this.icon, required this.text, required this.page});
}
