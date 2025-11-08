// lib/features/reports/views/cash_receivables_by_agent.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../viewModels/cash_receivables_view_model.dart';
import '../viewModels/product_view_model.dart';
import '../viewModels/distributor_view_model.dart';
import '../models/cash_receivables_models.dart';
import '../models/product_models.dart';
import '../models/distributor_models.dart';

class CashReceivablesByAgent extends StatelessWidget {
  const CashReceivablesByAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductViewModel()..load()),
        ChangeNotifierProvider(create: (_) => DistributorViewModel()..load()),
        ChangeNotifierProvider(create: (_) => CashReceivablesViewModel()),
      ],
      child: const _CashReceivablesScaffold(),
    );
  }
}

class _CashReceivablesScaffold extends StatefulWidget {
  const _CashReceivablesScaffold();

  @override
  State<_CashReceivablesScaffold> createState() => _CashReceivablesScaffoldState();
}

class _CashReceivablesScaffoldState extends State<_CashReceivablesScaffold> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    // Kick off initial fetch once product + agent lists are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(context));
  }

  Future<void> _bootstrap(BuildContext context) async {
    if (_bootstrapped) return;

    final productsVm = context.read<ProductViewModel>();
    final agentsVm   = context.read<DistributorViewModel>();
    final receVm     = context.read<CashReceivablesViewModel>();

    // Wait (briefly) for Product & Agent lists to be available.
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (
    (productsVm.isLoading || productsVm.filteredItems.isEmpty ||
        agentsVm.isLoading   || agentsVm.filteredItems.isEmpty) &&
        DateTime.now().isBefore(deadline)
    ) {
      await Future.delayed(const Duration(milliseconds: 120));
    }

    // If either list is still empty or errored, bail out silently (user can filter manually).
    if (productsVm.filteredItems.isEmpty || agentsVm.filteredItems.isEmpty) {
      if (mounted) setState(() => _bootstrapped = true);
      return;
    }

    // De-dupe like in dialog, then pick first available.
    int _firstUniqueProductId() {
      final map = <int, ProductItem>{};
      for (final p in productsVm.filteredItems) {
        map[p.productId] = p;
      }
      final list = map.values.toList()
        ..sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
      return list.first.productId;
    }

    int _firstUniqueAgentId() {
      final map = <int, DistributorItem>{};
      for (final d in agentsVm.filteredItems) {
        map[d.distributorId] = d;
      }
      final list = map.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list.first.distributorId;
    }

    // Respect any existing selections stored in the receivables VM (0 means unset).
    final productId = receVm.productId != 0 ? receVm.productId : _firstUniqueProductId();
    final agentId   = receVm.agentId   != 0 ? receVm.agentId   : _firstUniqueAgentId();

    // Fire the initial fetch.
    await receVm.fetch(agentId: agentId, productId: productId);

    if (mounted) setState(() => _bootstrapped = true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CashReceivablesViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Cash Receivables From Agent'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(
        onPressed: () => _openFilterDialog(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _ReceivablesContent(
          items: vm.filteredItems,
          isLoading: vm.isLoading || !_bootstrapped,
          error: vm.error,
          totalDebit: vm.totalDebit,
          totalCredit: vm.totalCredit,
          totalPayout: vm.totalPayout,
          totalBalanceReceive: vm.totalBalanceReceive,
          totalReceivable: vm.totalReceivable,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog (Product + Agent) ----------------
Future<void> _openFilterDialog(BuildContext context) async {
  final receVm    = context.read<CashReceivablesViewModel>();
  final productVm = context.read<ProductViewModel>();
  final agentVm   = context.read<DistributorViewModel>();

  int? selProductId = receVm.productId == 0 ? null : receVm.productId;
  int? selAgentId   = receVm.agentId   == 0 ? null : receVm.agentId;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Filter Cash Receivables',
          style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------- Product ----------
                Consumer<ProductViewModel>(
                  builder: (_, pvm, __) {
                    if (pvm.isLoading) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: const LinearProgressIndicator(color: AppTheme.adminGreen),
                      );
                    }
                    if (pvm.error != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(pvm.error!, style: const TextStyle(color: Colors.redAccent)),
                          SizedBox(height: 8.h),
                          OutlinedButton(onPressed: () => pvm.load(), child: const Text('Retry')),
                        ],
                      );
                    }

                    // De-dupe by productId
                    final Map<int, ProductItem> uniq = {};
                    for (final p in pvm.filteredItems) {
                      uniq[p.productId] = p;
                    }
                    final items = uniq.values.toList()
                      ..sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));

                    // Ensure selected is in list
                    if (selProductId != null && !uniq.containsKey(selProductId)) {
                      selProductId = null;
                    }
                    selProductId ??= items.isNotEmpty ? items.first.productId : null;

                    return DropdownButtonFormField<int>(
                      value: selProductId,
                      items: items
                          .map((p) => DropdownMenuItem<int>(
                        value: p.productId,
                        child: Text(p.productName, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (v) => selProductId = v,
                      validator: (v) => v == null ? 'Select a product' : null,
                      decoration: _inputDeco('Product'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // ---------- Agent (Distributor) ----------
                Consumer<DistributorViewModel>(
                  builder: (_, avm, __) {
                    if (avm.isLoading) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: const LinearProgressIndicator(color: AppTheme.adminGreen),
                      );
                    }
                    if (avm.error != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(avm.error!, style: const TextStyle(color: Colors.redAccent)),
                          SizedBox(height: 8.h),
                          OutlinedButton(onPressed: () => avm.load(), child: const Text('Retry')),
                        ],
                      );
                    }

                    // De-dupe by distributorId (agent id)
                    final Map<int, DistributorItem> uniq = {};
                    for (final d in avm.filteredItems) {
                      uniq[d.distributorId] = d;
                    }
                    final items = uniq.values.toList()
                      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    if (selAgentId != null && !uniq.containsKey(selAgentId)) {
                      selAgentId = null;
                    }
                    selAgentId ??= items.isNotEmpty ? items.first.distributorId : null;

                    return DropdownButtonFormField<int>(
                      value: selAgentId,
                      items: items
                          .map((d) => DropdownMenuItem<int>(
                        value: d.distributorId,
                        child: Text(d.name, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (v) => selAgentId = v,
                      validator: (v) => v == null ? 'Select an agent' : null,
                      decoration: _inputDeco('Agent'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    );
                  },
                ),
              ],
            ),
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
              if (!formKey.currentState!.validate()) return;
              if (selProductId == null || selAgentId == null) return;

              await receVm.fetch(agentId: selAgentId!, productId: selProductId!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('SUBMIT'),
          ),
        ],
      );
    },
  );
}

InputDecoration _inputDeco(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppTheme.adminWhite.withOpacity(.75)),
    filled: true,
    fillColor: AppTheme.adminWhite.withOpacity(.06),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppTheme.adminWhite.withOpacity(.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppTheme.adminGreen, width: 1.4),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
  );
}

/// =================================================================
///                         CONTENT + TOGGLE
/// =================================================================

enum _ViewMode { table, tiles }

class _ReceivablesContent extends StatefulWidget {
  final List<CashReceivableItem> items;
  final bool isLoading;
  final String? error;

  final double totalDebit;
  final double totalCredit;
  final double totalPayout;
  final double totalBalanceReceive;
  final double totalReceivable;

  const _ReceivablesContent({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.totalDebit,
    required this.totalCredit,
    required this.totalPayout,
    required this.totalBalanceReceive,
    required this.totalReceivable,
  });

  @override
  State<_ReceivablesContent> createState() => _ReceivablesContentState();
}

class _ReceivablesContentState extends State<_ReceivablesContent> {
  _ViewMode _mode = _ViewMode.table;

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.adminGreen));
    }
    if (widget.error != null) {
      return Center(child: Text(widget.error!, style: const TextStyle(color: Colors.redAccent)));
    }
    if (widget.items.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: AppTheme.adminWhite)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary + view toggle
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppTheme.adminWhite.withOpacity(.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.adminWhite.withOpacity(.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5.w,
                //runSpacing: 6.h,
                children: [
                  // Text('Rows: ${widget.items.length}',
                  //     style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                  Text('Debit: ${_fmt(widget.totalDebit)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                  Text('Credit: ${_fmt(widget.totalCredit)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                  Text('Payout: ${_fmt(widget.totalPayout)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                  Text('Balance Receive: ${_fmt(widget.totalBalanceReceive)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                  Text('Receivable: ${_fmt(widget.totalReceivable)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.adminWhite.withOpacity(.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppTheme.adminWhite.withOpacity(.12)),
                ),
                padding: EdgeInsets.all(2.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewChip(
                      label: 'Table',
                      icon: Icons.table_chart,
                      selected: _mode == _ViewMode.table,
                      onTap: () => setState(() => _mode = _ViewMode.table),
                    ),
                    _ViewChip(
                      label: 'Tiles',
                      icon: Icons.grid_view_rounded,
                      selected: _mode == _ViewMode.tiles,
                      onTap: () => setState(() => _mode = _ViewMode.tiles),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _mode == _ViewMode.table
                ? _ReceivablesTableView(items: widget.items)
                : _ReceivablesTileView(items: widget.items),
          ),
        ),
      ],
    );
  }
}

class _ViewChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppTheme.adminGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14.sp, color: selected ? Colors.black : AppTheme.adminWhite),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : AppTheme.adminWhite,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================================================================
///                           TABLE VIEW
/// =================================================================

class _ReceivablesTableView extends StatefulWidget {
  final List<CashReceivableItem> items;
  const _ReceivablesTableView({required this.items});

  @override
  State<_ReceivablesTableView> createState() => _ReceivablesTableViewState();
}

class _ReceivablesTableViewState extends State<_ReceivablesTableView> {
  final _hCtrl = ScrollController();
  final _vCtrl = ScrollController();

  String _int(num v) => v.round().toString();

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820.w),
        child: Scrollbar(
          controller: _vCtrl,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _vCtrl, // vertical scroll
            child: Scrollbar(
              controller: _hCtrl,
              thumbVisibility: true,
              notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _hCtrl, // horizontal scroll
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 14.w,
                  horizontalMargin: 12.w,
                  headingRowHeight: 36.h,
                  dataRowMinHeight: 36.h,
                  dataRowMaxHeight: 40.h,
                  headingRowColor:
                  WidgetStateProperty.all(AppTheme.adminWhite.withOpacity(.08)),
                  headingTextStyle: TextStyle(
                    color: AppTheme.adminWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                  dataTextStyle: TextStyle(
                    color: AppTheme.adminWhite,
                    fontSize: 12.sp,
                  ),
                  columns: const [
                    DataColumn(label: Text('SN')),
                    DataColumn(label: Text('AGENT')),
                    DataColumn(label: Text('SALE')),
                    DataColumn(label: Text('COLLECTION')),
                    DataColumn(label: Text('RECEIVABLE')),
                    DataColumn(label: Text('PAYOUT')),
                    DataColumn(label: Text('BAL. RECEIVE')),
                  ],
                  rows: items.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text('${e.sn}')),
                        DataCell(SizedBox(
                          width: 120.w,
                          child: Text(e.name, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(Text(_int(e.debit))),
                        DataCell(Text(_int(e.credit))),
                        DataCell(Text(_int(e.receivable))),
                        DataCell(Text(_int(e.payout))),
                        DataCell(Text(_int(e.balanceReceive))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// =================================================================
///                           TILE VIEW
/// =================================================================

class _ReceivablesTileView extends StatelessWidget {
  final List<CashReceivableItem> items;
  const _ReceivablesTileView({required this.items});

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, i) {
        final e = items[i];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.adminWhite.withOpacity(.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppTheme.adminWhite.withOpacity(.10)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

            // leading: Container(
            //   width: 40.w,
            //   height: 40.w,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: AppTheme.adminWhite.withOpacity(.08),
            //     borderRadius: BorderRadius.circular(10.r),
            //     border: Border.all(color: AppTheme.adminWhite.withOpacity(.12)),
            //   ),
            //   child: Text(
            //     (e.name.isNotEmpty ? e.name[0] : '-').toUpperCase(),
            //     style: TextStyle(
            //       color: AppTheme.adminWhite,
            //       fontWeight: FontWeight.w700,
            //       fontSize: 14.sp,
            //     ),
            //   ),
            // ),

            title: Text(
              e.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.adminWhite,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            // 👉 All metrics in one vertical column
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricRow('Sale', _fmt(e.debit)),
                  SizedBox(height: 4.h),
                  _metricRow('Collection', _fmt(e.credit)),
                  SizedBox(height: 4.h),
                  _metricRow('Payout', _fmt(e.payout)),
                  SizedBox(height: 4.h),
                  _metricRow('Bal. Receive', _fmt(e.balanceReceive)),
                ],
              ),
            ),

            // Receivable highlighted on the right
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.adminGreen.withOpacity(.28),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppTheme.adminGreen),
              ),
              child: Text(
                _fmt(e.receivable),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Label on the left, value right-aligned → feels “columnar”
  Widget _metricRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label',
            style: TextStyle(
              color: AppTheme.adminWhite.withOpacity(.78),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.adminWhite.withOpacity(.95),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

