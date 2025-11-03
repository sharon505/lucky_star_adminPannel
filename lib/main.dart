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
import 'features/home/home_page.dart';


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
];

Map<String, Widget Function(BuildContext)> routes = <String, WidgetBuilder>{
  'LoginView': (context) => const LoginView(),
  'HomePage': (context) => const HomePage(),
  // 'PayOutReportView': (context) => const PayOutReportView(),
  // 'PayOutView': (context) => const PayOutView(),
  // 'SummaryView': (context) => const SummaryView(),
  // 'SaleEntryView': (context) => const SaleEntryView(),
  // 'StockView': (context) => const StockView(),
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
