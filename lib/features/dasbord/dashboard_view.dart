import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/features/financial_overview/views/financial_overview_page.dart';
import 'package:lucky_star_admin/features/reports/views/reports_view.dart';
import 'package:provider/provider.dart';

import '../../core/theme/color_scheme.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/app_gradient_background.dart';
import '../auth/viewmodel/login_view_model.dart';
import '../master_data/views/master_data_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ROLE_ID from AuthViewModel -> LoginResponse -> LoginData
    final auth = context.watch<AuthViewModel>();
    final roleId = auth.loginResponse?.roleId; // null if not logged in

    // Build tab models dynamically
    final List<_Model> tabs = [
      _Model(
        icon: Icons.bar_chart_outlined,
        text: 'Reports',
        page: const ReportsView(),
      ),
      _Model(
        icon: Icons.dashboard_outlined,
        text: 'Financial',
        page: const FinancialOverviewPage(),
      ),
      // Only add Transactions if ROLE_ID != 2
      if (roleId != 2)
        _Model(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Transactions',
          page: const MasterDataView(),
        ),
    ];

    return DefaultTabController(
      length: tabs.length, // dynamic length
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '  Lucky Star Admin',
            style: AppTypography.heading1.copyWith(
              color: AppTheme.adminGreen,
              fontSize: 17.sp,
            ),
          ),
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
              tabs.length,
                  (i) => Tab(icon: Icon(tabs[i].icon), text: tabs[i].text),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.adminGreen),
              tooltip: "Logout",
              onPressed: ()=>_showLogoutDialog(context),
            ),
            SizedBox(width: 13.w)
          ],
        ),
        body: GradientBackground(
          colors: [AppTheme.adminDrawer, AppTheme.adminDrawer],
          child: TabBarView(
            children: List.generate(tabs.length, (i) => tabs[i].page),
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


void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.adminGreenDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        "Logout",
        style: TextStyle(color: AppTheme.adminWhite),
      ),
      content: const Text(
        "Are you sure you want to logout?",
        style: TextStyle(color: AppTheme.adminWhite),
      ),
      actions: [
        TextButton(
          child: const Text("CANCEL", style: TextStyle(color: AppTheme.adminWhite)),
          onPressed: () => Navigator.pop(ctx),
        ),
        TextButton(
          child: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent)),
          onPressed: ()=> Phoenix.rebirth(context),
        ),
      ],
    ),
  );
}


