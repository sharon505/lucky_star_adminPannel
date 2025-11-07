import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'features/auth/viewmodel/LoginFormProvider_viewModel.dart';
import 'features/auth/viewmodel/login_view_model.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/splash_view.dart';
import 'features/dasbord/dashboard_view.dart';
import 'features/financial_overview/views/day_book.dart';
import 'features/financial_overview/views/expense_Income_tracker.dart';
import 'features/financial_overview/views/get_cash_book.dart';
import 'features/financial_overview/views/profit_and_loss_statement.dart';
import 'features/home/home_page.dart';
import 'features/reports/viewModels/agent_stock_issue_view_model.dart';
import 'features/reports/viewModels/cash_collection_by_agent_view_model.dart';
import 'features/reports/viewModels/cash_receivables_view_model.dart';
import 'features/reports/viewModels/current_stock_by_agent_view_model.dart';
import 'features/reports/viewModels/distributor_view_model.dart';
import 'features/reports/viewModels/prize_search_view_model.dart';
import 'features/reports/viewModels/product_view_model.dart';
import 'features/reports/viewModels/sales_details_by_agent_view_model.dart';
import 'features/reports/viewModels/stock_report_view_model.dart';
import 'features/reports/views/agent_stock_issue_details.dart';
import 'features/reports/views/cash_collection_by_agent.dart';
import 'features/reports/views/cash_receivables_by_agent.dart';
import 'features/reports/views/current_stock_by_agent.dart';
import 'features/reports/views/sales_details_by_agent.dart';
import 'features/reports/views/stock_report_view.dart';


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

List<SingleChildWidget> providers = [
  ///Auth
  ChangeNotifierProvider(create: (context) => AuthViewModel()),
  ChangeNotifierProvider(create: (context) => LoginFormProvider()),
  ///ticket search
  ChangeNotifierProvider(create: (_) => PrizeSearchViewModel()),
  ///report
  ChangeNotifierProvider(create: (_) => StockReportViewModel()),
  ChangeNotifierProvider(create: (_) => ProductViewModel()..load()),
  ChangeNotifierProvider(create: (_) => DistributorViewModel()..load()),
  ChangeNotifierProvider(create: (_) => AgentStockIssueViewModel()),
  ChangeNotifierProvider(create: (_) => CurrentStockByAgentViewModel()),
  ChangeNotifierProvider(create: (_) => CashReceivablesViewModel()),
  ChangeNotifierProvider(create: (_) => SalesDetailsByAgentViewModel()),
  ChangeNotifierProvider(create: (_) => CashCollectionByAgentViewModel()),
];

//9567030890

Map<String, Widget Function(BuildContext)> routes = <String, WidgetBuilder>{
  'LoginView': (context) => const LoginView(),
  'HomePage':  (context) => const HomePage(),
  'DashboardView':  (context) => const DashboardView(),
  ///reports
  'StockReportView':  (context) => const StockReportView(),
  'AgentStockIssueDetails':  (context) => const AgentStockIssueDetails(),
  'CurrentStockByAgent':  (context) => const CurrentStockByAgent(),
  ///sales
  'CashCollectionByAgent':  (context) => const CashCollectionByAgent(),
  'CashReceivablesByAgent':  (context) => const CashReceivablesByAgent(),
  'SalesDetailsByAgent':  (context) => const SalesDetailsByAgent(),
  ///Financial
  'GetCashBook':  (context) => const GetCashBook(),
  'DayBook':  (context) => const DayBook(),
  'ProfitAndLossStatement':  (context) => const ProfitAndLossStatement(),
  'ExpenseIncomeTracker':  (context) => const ExpenseIncomeTracker(),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MultiProvider(
        providers: providers,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            // ScreenUtil.init(context);
            return MaterialApp(
              routes: routes,
              debugShowCheckedModeBanner: false,
              title: 'LuckyStar',
              theme: theme,
              home: const SplashView(),
            );
          },
        ),
      ),
    );
  }
}

ThemeData? theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  useMaterial3: true,
  textTheme: Typography.blackCupertino.apply(
    // lets ScreenUtil scale text globally
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  ),
);
