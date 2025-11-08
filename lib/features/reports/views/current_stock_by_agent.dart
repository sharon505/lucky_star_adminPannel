import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../viewModels/current_stock_by_agent_view_model.dart';
import '../viewModels/product_view_model.dart';
import '../viewModels/distributor_view_model.dart';
import '../models/product_models.dart';
import '../models/distributor_models.dart';
import '../models/agent_stock_summary_models.dart';

class CurrentStockByAgent extends StatelessWidget {
  const CurrentStockByAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductViewModel()..load()),
        ChangeNotifierProvider(create: (_) => DistributorViewModel()..load()),
        ChangeNotifierProvider(create: (_) => CurrentStockByAgentViewModel()),
      ],
      child: const _StockByAgentScaffold(),
    );
  }
}

class _StockByAgentScaffold extends StatefulWidget {
  const _StockByAgentScaffold();

  @override
  State<_StockByAgentScaffold> createState() => _StockByAgentScaffoldState();
}

class _StockByAgentScaffoldState extends State<_StockByAgentScaffold> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(context));
  }

  Future<void> _bootstrap(BuildContext context) async {
    if (_bootstrapped) return;

    final stockVm   = context.read<CurrentStockByAgentViewModel>();
    final productVm = context.read<ProductViewModel>();
    final agentVm   = context.read<DistributorViewModel>();

    // Wait briefly for product & agent lists to load (MultiProvider already called load()).
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (
    (productVm.isLoading || agentVm.isLoading) &&
        DateTime.now().isBefore(deadline)
    ) {
      await Future.delayed(const Duration(milliseconds: 120));
    }

    // Prefer filteredItems; fall back to raw lists
    final products = productVm.filteredItems.isNotEmpty
        ? productVm.filteredItems
        : productVm.items;

    final agents = agentVm.filteredItems.isNotEmpty
        ? agentVm.filteredItems
        : agentVm.items;

    // If we still have nothing, keep UI usable; user can open the filter dialog.
    if (products.isEmpty) {
      if (mounted) setState(() => _bootstrapped = true);
      return;
    }

    // Respect any previously chosen IDs in the VM; otherwise pick first available.
    final int productId = stockVm.productId ??
        (productVm.selected?.productId ?? products.first.productId);

    // agentId: 0 means ALL (your VM already supports 0). If VM has a non-zero selection, keep it;
    // else try selected agent or default to 0 if no agents available.
    final int agentId = (stockVm.agentId != 0)
        ? stockVm.agentId
        : (agentVm.selected?.distributorId ?? (agents.isNotEmpty ? agents.first.distributorId : 0));

    await stockVm.fetch(productId: productId, agentId: agentId);

    if (mounted) setState(() => _bootstrapped = true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrentStockByAgentViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Current Stock By Agent'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(
        onPressed: () => _openFilterDialog(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _StockContent(
          items: vm.filteredItems,
          // Show spinner during initial bootstrap for clear feedback
          isLoading: vm.isLoading || !_bootstrapped,
          error: vm.error,
          totalIssued: vm.totalIssued,
          totalSale: vm.totalSale,
          totalBalance: vm.totalBalance,
        ),
      ),
    );
  }
}


/// ---------------- Filter Dialog ----------------

Future<void> _openFilterDialog(BuildContext context) async {
  final vm = context.read<CurrentStockByAgentViewModel>();
  final productVm = context.read<ProductViewModel>();
  final agentVm = context.read<DistributorViewModel>(); // agents list

  int? selProductId = vm.productId; // can be null initially
  int selAgentId = vm.agentId;      // 0 = ALL

  // Seed full objects so we can show names
  ProductItem? selProduct = (selProductId == null)
      ? null
      : productVm.filteredItems.firstWhere(
        (p) => p.productId == selProductId,
    orElse: () => productVm.filteredItems.isNotEmpty
        ? productVm.filteredItems.first
        : ProductItem(productId: 0, productName: 'ALL'),
  );

  // ❗ FIX: remove distributorCode (constructor doesn’t support it)
  DistributorItem? selAgent = agentVm.filteredItems.firstWhere(
        (a) => a.distributorId == selAgentId,
    orElse: () => agentVm.filteredItems.isNotEmpty
        ? agentVm.filteredItems.first
        : const DistributorItem(distributorId: 0, name: 'ALL'),
  );

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Filter — Current Stock',
          style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------- Product (ID-based value + de-dup) ----------
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

                    int? value = selProduct?.productId;
                    if (value == null || !uniq.containsKey(value)) {
                      value = items.isNotEmpty ? items.first.productId : null;
                      if (value != null) selProduct = uniq[value];
                      selProductId = value;
                    }

                    return DropdownButtonFormField<int>(
                      value: value,
                      items: items
                          .map((p) => DropdownMenuItem<int>(
                        value: p.productId,
                        child: Text(p.productName, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (int? v) {
                        if (v == null) return;
                        selProduct = uniq[v];
                        selProductId = v;
                      },
                      validator: (v) => v == null ? 'Select a product' : null,
                      decoration: _inputDeco('Product'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // ---------- Agent (ID-based value + de-dup) ----------
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

                    // De-dupe by distributorId (agents)
                    final Map<int, DistributorItem> uniq = {};
                    for (final a in avm.filteredItems) {
                      uniq[a.distributorId] = a;
                    }
                    final items = uniq.values.toList()
                      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    int? value = selAgent?.distributorId;
                    if (value == null || !uniq.containsKey(value)) {
                      value = items.isNotEmpty ? items.first.distributorId : 0;
                      selAgent = uniq[value] ?? const DistributorItem(distributorId: 0, name: 'ALL'); // ❗ FIX
                      selAgentId = value;
                    }

                    return DropdownButtonFormField<int>(
                      value: value,
                      items: items
                          .map((a) => DropdownMenuItem<int>(
                        value: a.distributorId,
                        child: Text(a.name, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (int? v) {
                        if (v == null) return;
                        selAgent = uniq[v];
                        selAgentId = v;
                      },
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
              if (selProductId == null) return;

              await vm.fetch(
                productId: selProductId!,
                agentId: selAgentId,
              );

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

/// ---------------- Content with toggle (Table/Tiles) ----------------

enum _ViewMode { table, tiles }

class _StockContent extends StatefulWidget {
  final List<AgentStockSummaryItem> items;
  final bool isLoading;
  final String? error;
  final double totalIssued;
  final double totalSale;
  final double totalBalance;

  const _StockContent({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.totalIssued,
    required this.totalSale,
    required this.totalBalance,
  });

  @override
  State<_StockContent> createState() => _StockContentState();
}

class _StockContentState extends State<_StockContent> {
  _ViewMode _mode = _ViewMode.table;

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
        // Header summary + view toggle
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Text(
                    //   'Rows: ${widget.items.length}',
                    //   style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    // ),
                    Text(
                      'Issued: ${widget.totalIssued.toStringAsFixed(2)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                    Text(
                      'Sale: ${widget.totalSale.toStringAsFixed(2)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                    Text(
                      'Balance: ${widget.totalBalance.toStringAsFixed(2)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              // Toggle
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
                ? _StockTableView(items: widget.items)
                : _StockTileView(items: widget.items),
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

/// ---------------- Table view ----------------

class _StockTableView extends StatelessWidget {
  final List<AgentStockSummaryItem> items;
  const _StockTableView({required this.items});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 14.w,
            horizontalMargin: 12.w,
            headingRowHeight: 36.h,
            dataRowMinHeight: 36.h,
            dataRowMaxHeight: 40.h,
            headingRowColor: WidgetStateProperty.all(AppTheme.adminWhite.withOpacity(.08)),
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
              DataColumn(label: Text('PRODUCT')),
              DataColumn(label: Text('AGENT')),
              DataColumn(label: Text('ISSUED')),
              DataColumn(label: Text('SALE')),
              DataColumn(label: Text('BALANCE')),
            ],
            rows: items.map((e) {
              return DataRow(cells: [
                DataCell(Text('${e.sn}')),
                DataCell(SizedBox(
                  width: 200.w,
                  child: Text(e.productName, overflow: TextOverflow.ellipsis),
                )),
                DataCell(SizedBox(
                  width: 180.w,
                  child: Text(e.name, overflow: TextOverflow.ellipsis),
                )),
                DataCell(Text(e.issued.toStringAsFixed(2))),
                DataCell(Text(e.sale.toStringAsFixed(2))),
                DataCell(Text(e.balanceStock.toStringAsFixed(2))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Tile view ----------------

class _StockTileView extends StatelessWidget {
  final List<AgentStockSummaryItem> items;
  const _StockTileView({required this.items});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = (MediaQuery.of(context).size.width / 260).floor().clamp(1, 4);
    return GridView.builder(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.75,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final e = items[i];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.adminWhite.withOpacity(.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppTheme.adminWhite.withOpacity(.10)),
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product
              Text(
                e.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.adminWhite,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              // Agent
              Row(
                children: [
                  Icon(Icons.person_rounded,
                      size: 14.sp, color: AppTheme.adminWhite.withOpacity(.8)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      e.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.adminWhite.withOpacity(.85),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Numbers row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pill('Issued', e.issued),
                  _pill('Sale', e.sale),
                  _pill('Bal', e.balanceStock),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'SN: ${e.sn}',
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(.6),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pill(String label, double value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.adminGreen.withOpacity(.22),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.adminGreen.withOpacity(.5)),
      ),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              color: AppTheme.adminGreen,
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.adminWhite.withOpacity(.75),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
