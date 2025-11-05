import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../shared/app_gradient_background.dart';
import '../viewModels/prize_search_view_model.dart';
import '../widgets/prize_claim_card_widget.dart';
import '../widgets/search_text_field_widget.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {

    Widget height = SizedBox(height: 10.h);

    return GradientBackground(
      colors: [
        AppTheme.adminGreenDark,
        AppTheme.adminGreenDark,
      ],
      child: Padding(
        padding: AppPadding.allSmall,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            height,
            _ticketSearch(context),
          ],
        ),
      ),
    );
  }

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
        if (vm.isLoading) const Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        )
        else if (vm.errorMessage != null) Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            vm.errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        )
        else if (vm.results.isEmpty) const Padding(
            //padding: EdgeInsets.all(12),
            padding: EdgeInsets.all(0),
            child: Text(
              '',
              // 'Search by SL No. to see prize details',
              textAlign: TextAlign.center,
            ),
          )
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
                    // slNo: index + 1,
                    prizeAmount: p.prizeAmount,
                    customerName: p.customerName,
                    // status: _parseClaimStatus(p.claimStatus),
                    // onTap: () {
                    //   // e.g., open detail, copy SLNO, etc.
                    //   // Clipboard.setData(ClipboardData(text: p.luckySlno));
                    // },
                  );
                },
              ),
            ],
      ],
    );
  }

  ClaimStatus _parseClaimStatus(String raw) {
    final s = raw.trim().toUpperCase();
    switch (s) {
      case 'CLAIMED':
      case 'CLIAIMED': // typo-safe
        return ClaimStatus.claimed;
      case 'APPROVED':
        return ClaimStatus.approved;
      case 'REJECTED':
        return ClaimStatus.rejected;
      case 'PENDING':
      default:
        return ClaimStatus.pending;
    }
  }




}
