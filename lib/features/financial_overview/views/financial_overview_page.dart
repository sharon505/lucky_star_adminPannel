import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../widget/agent_collection_tile.dart';
import '../widget/amount_field.dart';
import '../widget/date_field.dart';
import '../widget/dropdown_field.dart';
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
            AgentCollectionCTAButton(
              onTap: () => _openAgentCollectionDialog(context),
              // optional:
              title: 'Agent Collection',
              // subtitle: 'Tap to view breakdown & settle dues',
              // leadingIcon: Icons.account_balance_wallet_outlined,
            ),
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

  Future<void> _openAgentCollectionDialog(BuildContext context) async {
    DateTime date = DateTime.now();
    String? productId;
    String? agentId;

    final products = const <DropdownMenuItem<String>>[
      DropdownMenuItem(value: '1', child: Text('LUCKY STAR CARD')),
      DropdownMenuItem(value: '2', child: Text('MEGA DRAW')),
    ];

    final agents = const <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'A1', child: Text('JEBEL ALI 2')),
      DropdownMenuItem(value: 'A2', child: Text('AL MUTEENA 1')),
    ];

    productId = products.isNotEmpty ? products.first.value : null;
    agentId   = agents.isNotEmpty ? agents.first.value : null;

    final receivableCtrl = TextEditingController(text: '0.00');
    final amountCtrl     = TextEditingController(text: '0.00');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.adminGreenDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: const Text(
                'Filter — Agent Collection',
                style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DateField(
                      label: 'Date',
                      date: date,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          barrierDismissible: false,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.adminGreen,
                                  surface: AppTheme.adminGreenDark,
                                  onSurface: AppTheme.adminWhite,
                                ),
                                dialogBackgroundColor: AppTheme.adminGreenDark,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => date = DateTime(picked.year, picked.month, picked.day));
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    DropdownField<String>(
                      label: 'Products',
                      value: productId,
                      items: products,
                      onChanged: (v) {
                        setState(() {
                          productId = v;
                          // TODO: fetch receivable for (date, productId, agentId)
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    DropdownField<String>(
                      label: 'Agents',
                      value: agentId,
                      items: agents,
                      onChanged: (v) {
                        setState(() {
                          agentId = v;
                          // TODO: fetch receivable for (date, productId, agentId)
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    AmountField(
                      label: 'Amount Receivable',
                      controller: receivableCtrl,
                      readOnly: true,
                    ),
                    SizedBox(height: 12.h),
                    AmountField(
                      label: 'Amount',
                      controller: amountCtrl,
                      readOnly: false,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL', style: TextStyle(color: AppTheme.adminWhite)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.adminGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () async {
                    // TODO: submit with (date, productId!, agentId!, double.parse(amountCtrl.text))
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('SUBMIT'),
                ),
              ],
            );
          },
        );
      },
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



