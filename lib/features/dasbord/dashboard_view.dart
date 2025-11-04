import 'package:flutter/material.dart';

import '../../shared/app_gradient_background.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          flexibleSpace: const GradientBackground(child: SizedBox()),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
              Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Reports'),
              Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
            ],
          ),
        ),
        body: GradientBackground(
          child: const TabBarView(
            children: [
              Center(child: Text('Overview tab')),
              Center(child: Text('Reports tab')),
              Center(child: Text('Settings tab')),
            ],
          ),
        ),
      ),
    );
  }
}
