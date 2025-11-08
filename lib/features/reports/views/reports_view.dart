import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../shared/app_gradient_background.dart';
import '../viewModels/dashboard_view_model.dart';
import '../viewModels/prize_search_view_model.dart';
import '../widgets/dasbord/dashboard_overview_widget.dart';
import '../widgets/sales/report_quick_tiles.dart';
import '../widgets/stock_report/stock_report_tile.dart';
import '../widgets/ticket_search/prize_claim_card_widget.dart';
import '../widgets/ticket_search/search_text_field_widget.dart';

typedef Tap = VoidCallback?;

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget height = SizedBox(height: 10.h);

    return GradientBackground(
      colors: [AppTheme.adminGreenDark, AppTheme.adminGreenDark],
      child: Padding(
        padding: AppPadding.allSmall,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ///ticketSearch
              height,
              _ticketSearch(context),
              ///dasbord
              Consumer<DashboardViewModel>(
                builder: (context, vm, _) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: DashboardOverview.fromViewModel(
                    vm: vm,
                    onRefresh: vm.refresh,
                    embedded: true,
                  ),
                ),
              ),
              ///stockReport
              _stocks(
                context,
                onTap: [
                  () => Navigator.pushNamed(context, 'StockReportView'),
                  () => Navigator.pushNamed(context, 'AgentStockIssueDetails'),
                  () => Navigator.pushNamed(context, 'CurrentStockByAgent'),
                ],
              ),
              height,
              _salesList(
                context,
                onTap: [
                  () => Navigator.pushNamed(context, 'SalesDetailsByAgent'),
                  () => Navigator.pushNamed(context, 'CashReceivablesByAgent'),
                  () => Navigator.pushNamed(context, 'CashCollectionByAgent'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///ticketSearch
  Widget _ticketSearch(BuildContext context) {
    final vm = context.watch<PrizeSearchViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Search box --------------------------------------------------------
        SearchTextField(
          hintText: 'Ticket Search…',
          debounceDuration: const Duration(milliseconds: 300),
          // keep the field in sync with VM
          controller: vm.slnoController,
          onChanged: (q) {
            // Update text in VM (just in case your SearchTextField doesn't
            // keep controller bound); trigger search for >= 3 chars
            vm.setSlno(q);
            if (q.trim().length >= 3 && !vm.isLoading) {
              vm.search();
            }
          },
          onSubmitted: (q) {
            vm.setSlno(q);
            vm.search();
          },
        ),

        const SizedBox(height: 12),

        // --- State: loading / error / results ---------------------------------
        if (vm.isLoading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          )
        else if (vm.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          )
        else if (vm.results.isEmpty)
          SizedBox()
        // const Padding(
        //   padding: EdgeInsets.all(0),
        //   child: Text(
        //     // '',
        //     'Search by SL No. to see prize details',
        //     textAlign: TextAlign.center,
        //   ),
        // )
        else ...[
          // Render results using your PrizeClaimCard
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = vm.results[index];
              return PrizeTicketCard(
                customerMob: p.customerMob,
                claimStatus: p.claimStatus,
                dateIso: p.date.toString(),
                luckySlno: p.luckySlno,
                prizeAmount: p.prizeAmount,
                customerName: p.customerName,
              );
            },
          ),
        ],
      ],
    );
  }

  ///stockReport
  Widget _stocks(BuildContext context, {List<Tap>? onTap}) {
    Tap _at(int i) => (onTap != null && i < onTap.length) ? onTap![i] : null;
    return LayoutBuilder(
      builder: (context, c) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          // perfect squares (AspectRatio 1:1 inside tile)
          children: [
            SquareIconTile(
              text: 'Stock Report',
              icon: Icons.assessment_rounded,
              uppercase: true,
              onTap: _at(0),
            ),
            SquareIconTile(
              text: 'Agent Stock Issue Details',
              icon: Icons.local_shipping_rounded,
              uppercase: true,
              onTap: _at(1),
            ),
            SquareIconTile(
              text: 'Current Stock by Agent',
              icon: Icons.account_tree_rounded,
              uppercase: true,
              onTap: _at(2),
            ),
          ],
        );
      },
    );
  }

  ///sales
  Widget _salesList(BuildContext context, {List<Tap>? onTap}) {
    Tap? _at(int i) => (onTap != null && i < onTap.length) ? onTap[i] : null;

    final items = <ReportTileData>[
      ReportTileData(
        title: 'Sales Details By Agent',
        subtitle: 'Agent-wise entries',
        leadingIcon: Icons.receipt_long_rounded,
        onTap: _at(0),
      ),
      ReportTileData(
        title: 'Cash Receivables From Agent',
        subtitle: 'Agent-wise entries',
        leadingIcon: Icons.request_quote_rounded,
        onTap: _at(1),
      ),
      ReportTileData(
        title: 'Cash Collection From Agent',
        subtitle: 'Agent-wise entries',
        leadingIcon: Icons.payments_rounded,
        onTap: _at(2),
      ),
    ];

    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: AppPadding.allSmall,
      // keep your padding
      itemBuilder: (context, index) => items[index], // <-- use index
    );
  }
}
