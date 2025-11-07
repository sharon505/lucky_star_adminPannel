import 'package:flutter/material.dart';

import '../../../core/constants/app_appbar.dart';

class ProfitAndLossStatement extends StatelessWidget {
  const ProfitAndLossStatement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(text: 'Profit And Loss Statement'),
    );
  }
}