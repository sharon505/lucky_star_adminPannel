import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import 'package:provider/provider.dart';

import '../../reports/viewModels/distributor_view_model.dart';
import '../../reports/viewModels/product_view_model.dart';
import '../../master_data/widgets/agent_collection_tile.dart';
import '../widget/amount_field.dart';
import '../widget/date_field.dart';
import '../widget/dropdown_field.dart';
import '../../master_data/widgets/open_agent_collection_dialog.dart';
import '../widget/title_card.dart';

typedef Tap = VoidCallback?;

class FinancialOverviewPage extends StatelessWidget {
  const FinancialOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.adminGreenDark,
      body: Padding(
        padding: AppPadding.allSmall,
        child: Column(
          children: [
            _financial(
              context,
              onTap: [
                () => Navigator.pushNamed(context, 'GetCashBook'),
                () => Navigator.pushNamed(context, 'DayBook'),
                () => Navigator.pushNamed(context, 'ProfitAndLossStatement'),
                () => Navigator.pushNamed(context, 'ExpenseIncomeTracker'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _financial(BuildContext context, {List<Tap>? onTap}) {
    Tap? _at(int i) => (onTap != null && i < onTap.length) ? onTap[i] : null;

    final List<TitleCard> items = [
      TitleCard(
        title: 'Cash Book',
        subtitle: 'Cash ledger by date • receipts & payments',
        leadingIcon: Icons.account_balance_wallet_outlined,
        onTap: _at(0),
      ),
      TitleCard(
        title: 'Day Book',
        subtitle: 'Daily debit/credit summary • all vouchers',
        leadingIcon: Icons.receipt_long_outlined,
        onTap: _at(1),
      ),
      TitleCard(
        title: 'Profit & Loss Statement',
        subtitle: 'Revenue vs expense • net profit overview',
        leadingIcon: Icons.trending_up_outlined,
        onTap: _at(2),
      ),
      TitleCard(
        title: 'Expense & Income Tracker',
        subtitle: 'Category-wise tracking • monthly trends',
        leadingIcon: Icons.account_balance_outlined,
        onTap: _at(3),
      ),
    ];

    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: AppPadding.allSmall,
      itemBuilder: (context, index) => items[index],
    );
  }
}



