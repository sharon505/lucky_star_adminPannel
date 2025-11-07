import 'package:flutter/material.dart';

import '../../../core/constants/app_appbar.dart';

class ExpenseIncomeTracker extends StatelessWidget {
  const ExpenseIncomeTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(text: 'Expense Income Tracker'),
    );
  }
}