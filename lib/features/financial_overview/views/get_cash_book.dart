import 'package:flutter/material.dart';
import 'package:lucky_star_admin/core/constants/app_appbar.dart';

class GetCashBook extends StatelessWidget {
  const GetCashBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(text: 'Cash Book'),
    );
  }
}
