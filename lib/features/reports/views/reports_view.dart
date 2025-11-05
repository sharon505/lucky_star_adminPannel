import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../shared/app_gradient_background.dart';
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
            SearchTextField(
              hintText: 'Ticket Search…',
              debounceDuration: const Duration(milliseconds: 300),
              onChanged: (q) { /* filter list */ },
              onSubmitted: (q) { /* trigger search */ },
            ),
            height,
            _ticketSearch(),
            height,
          ],
        ),
      ),
    );
  }

  Widget _ticketSearch(){
    return PrizeClaimCard(
      slNo: 1,
      prizeAmount: 25000,
      customerName: 'Anand Kumar',
      status: ClaimStatus.approved,
      onTap: () {}, // optional
    );
  }



}
