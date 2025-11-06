import 'package:flutter/material.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../../../core/constants/app_appbar.dart';

class AgentStockIssueDetails extends StatelessWidget {
  const AgentStockIssueDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(text: 'Agent StockIssue Details'),
      backgroundColor: AppTheme.adminGreenLite,
    );
  }
}
