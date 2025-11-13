import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/agent_collection_cta_button.dart'; // contains PrimaryCTAButton
import '../widgets/open_Issue_entry_dialog.dart';
import '../widgets/open_Location_wise_dialog.dart';
import '../widgets/open_agent_collection_dialog.dart';
import '../../reports/viewModels/distributor_view_model.dart';
import '../../reports/viewModels/product_view_model.dart';
import 'product_master_page.dart';
import 'agent_master_page.dart';

class MasterDataView extends StatefulWidget {
  const MasterDataView({super.key});

  @override
  State<MasterDataView> createState() => _MasterDataViewState();
}

class _MasterDataViewState extends State<MasterDataView> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_bootstrapped) return;
      _bootstrapped = true;

      final products = context.read<ProductViewModel>();
      final agents = context.read<DistributorViewModel>();

      await Future.wait([products.load(), agents.load()]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productCount = context.select<ProductViewModel, int>(
      (vm) => vm.items.length,
    );
    final agentCount = context.select<DistributorViewModel, int>(
      (vm) => vm.items.length,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0C1725), Color(0xFF142A3B)],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.h,
                    children: [
                      // Top CTA buttons (fixed, grid scrolls)
                      PrimaryCTAButton(
                        onTap: () => openAgentCollectionDialog(context),
                        title: 'Agent Collection',
                        subtitle: 'Day Book • Cash • Prizes • Adjustments',
                        leadingIcon: Icons.payments_outlined,
                        backgroundIcon: Icons.payments_rounded,
                      ),

                      PrimaryCTAButton(
                        onTap: () => openLocationWiseDialog(context),
                        title: 'Location Wise Issuing',
                        subtitle: 'Branch • Location • Product • Issue Count',
                        leadingIcon: Icons.location_on_outlined,
                        backgroundIcon: Icons.location_city_rounded,
                      ),

                      PrimaryCTAButton(
                        onTap: () => openIssueEntryDialog(context),
                        title: 'Agent Stock Issue',
                        subtitle: 'Product • Agent • Issue Date • Quantity',
                        leadingIcon: Icons.inventory_2_outlined,
                        backgroundIcon: Icons.local_shipping_rounded,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid is the ONLY scrollable in this screen
// Expanded(
//   child: GridView.count(
//     physics: NeverScrollableScrollPhysics(),
//     crossAxisCount: cols,
//     mainAxisSpacing: 12.h,
//     crossAxisSpacing: 12.w,
//     childAspectRatio: 1.01,
//     children: [
//       _MasterTile(
//         title: 'Products',
//         subtitle:
//         'Create, edit & manage product catalog',
//         icon: Icons.inventory_2_rounded,
//         count: productCount,
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF34D399),
//             Color(0xFF10B981),
//           ],
//         ),
//         onTap: () => Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => const ProductMasterPage(),
//           ),
//         ),
//         onLongPress: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 'Long-press actions coming soon',
//               ),
//             ),
//           );
//         },
//       ),
//       _MasterTile(
//         title: 'Agents',
//         subtitle:
//         'Profiles, assignments & contact info',
//         icon: Icons.badge_rounded,
//         count: agentCount,
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF60A5FA),
//             Color(0xFF2563EB),
//           ],
//         ),
//         onTap: () => Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => const AgentMasterPage(),
//           ),
//         ),
//         onLongPress: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 'Long-press actions coming soon',
//               ),
//             ),
//           );
//         },
//       ),
//     ],
//   ),
// ),

class _MasterTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int? count;
  final Gradient gradient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _MasterTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.count,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<_MasterTile> createState() => _MasterTileState();
}

class _MasterTileState extends State<_MasterTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? .98 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 18.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: Colors.white.withOpacity(.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(.12),
                      width: 1.r,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.20),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(.18),
                              width: 1.r,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                        const Spacer(),
                        if (widget.count != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.28),
                              borderRadius: BorderRadius.circular(999.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(.18),
                                width: 1.r,
                              ),
                            ),
                            child: Text(
                              '${widget.count}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.25,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
