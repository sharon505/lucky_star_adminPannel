import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../viewModels/sales_details_by_agent_view_model.dart';
import '../viewModels/product_view_model.dart';
import '../viewModels/distributor_view_model.dart';
import '../models/product_models.dart';
import '../models/distributor_models.dart';
import '../models/agent_stock_sale_models.dart';

class SalesDetailsByAgent extends StatelessWidget {
  const SalesDetailsByAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductViewModel()..load()),
        ChangeNotifierProvider(create: (_) => DistributorViewModel()..load()),
        ChangeNotifierProvider(create: (_) => SalesDetailsByAgentViewModel()),
      ],
      child: const _SalesDetailsScaffold(),
    );
  }
}

class _SalesDetailsScaffold extends StatefulWidget {
  const _SalesDetailsScaffold();

  @override
  State<_SalesDetailsScaffold> createState() => _SalesDetailsScaffoldState();
}

class _SalesDetailsScaffoldState extends State<_SalesDetailsScaffold> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    final pvm = context.read<ProductViewModel>();
    final avm = context.read<DistributorViewModel>();
    final vm  = context.read<SalesDetailsByAgentViewModel>();

    // wait until lists are loaded (or give up quickly)
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      final ok = !pvm.isLoading && pvm.error == null && pvm.filteredItems.isNotEmpty
          && !avm.isLoading && avm.error == null && avm.filteredItems.isNotEmpty;
      if (ok) break;
    }
    if (!mounted) return;

    if (pvm.filteredItems.isNotEmpty) {
      final productId = pvm.filteredItems.first.productId;
      final agentId   = 0; // 👉 use 0 for ALL; change to avm.filteredItems.first.distributorId if needed
      await vm.autoBootstrap(productId: productId, agentId: agentId, daysBack: 1);
    }

    if (mounted) setState(() => _bootstrapped = true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesDetailsByAgentViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Sales Details By Agent'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(
        onPressed: () => _openFilterDialog(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _SalesContent(
          items: vm.items,
          isLoading: vm.isLoading || !_bootstrapped,
          error: vm.error,
          totalSale: vm.totalStockSale,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog ----------------
Future<void> _openFilterDialog(BuildContext context) async {
  final vm = context.read<SalesDetailsByAgentViewModel>();
  // final productVm = context.read<ProductViewModel>();
  // final agentVm = context.read<DistributorViewModel>();

  DateTime from = vm.fromDate ?? DateTime.now().subtract(const Duration(days: 1));
  DateTime to = vm.toDate ?? DateTime.now();

  int? selProductId = vm.productId;
  int? selAgentId = vm.agentId; // set to 0 for ALL if your backend needs it

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      Future<void> pickDate({required bool isFrom}) async {
        final init = isFrom ? from : to;
        final picked = await showDatePicker(
          context: ctx,
          initialDate: init,
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
          if (isFrom) {
            from = DateTime(picked.year, picked.month, picked.day);
            if (from.isAfter(to)) to = from;
          } else {
            to = DateTime(picked.year, picked.month, picked.day);
            if (to.isBefore(from)) from = to;
          }
        }
      }

      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Sales Details',
          style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'From Date',
                        date: from,
                        onTap: () => pickDate(isFrom: true),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _DateField(
                        label: 'To Date',
                        date: to,
                        onTap: () => pickDate(isFrom: false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Product
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

                    final Map<int, ProductItem> uniq = {
                      for (final p in pvm.filteredItems) p.productId: p
                    };
                    final items = uniq.values.toList()
                      ..sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));

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

                // Agent
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

                    final Map<int, DistributorItem> uniq = {
                      for (final a in avm.filteredItems) a.distributorId: a
                    };
                    final items = uniq.values.toList()
                      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    if (selAgentId != null && !uniq.containsKey(selAgentId!)) {
                      selAgentId = null;
                    }
                    selAgentId ??= items.isNotEmpty ? items.first.distributorId : null;

                    return DropdownButtonFormField<int>(
                      value: selAgentId,
                      items: items
                          .map((a) => DropdownMenuItem<int>(
                        value: a.distributorId,
                        child: Text(a.name, overflow: TextOverflow.ellipsis),
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

              await vm.fetch(
                fromDate: from,
                toDate: to,
                productId: selProductId!,
                agentId: selAgentId!,
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    final txt = '${two(date.day)}/${two(date.month)}/${date.year}';
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDeco(label),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.adminGreen),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                txt,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.adminWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

/// ---------------- Content (Header + Table/Tiles toggle) ----------------
enum _ViewMode { table, tiles }

class _SalesContent extends StatefulWidget {
  final List<StockSaleItem> items;
  final bool isLoading;
  final String? error;
  final double totalSale;

  const _SalesContent({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.totalSale,
  });

  @override
  State<_SalesContent> createState() => _SalesContentState();
}

class _SalesContentState extends State<_SalesContent> {
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No data', style: TextStyle(color: AppTheme.adminWhite.withOpacity(.9), fontSize: 14.sp)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              children: [
                OutlinedButton(
                  onPressed: () => context.read<SalesDetailsByAgentViewModel>().refresh(),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.adminGreen, foregroundColor: Colors.black),
                  onPressed: () => _openFilterDialog(context),
                  child: const Text('Set Filters'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header summary + toggle
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
                      'Total Sale: ${widget.totalSale.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: AppTheme.adminGreen.withOpacity(.85), fontSize: 14.sp,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _mode == _ViewMode.table
                ? _SalesTableView(items: widget.items)
                : _SalesTileView(items: widget.items),
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
class _SalesTableView extends StatelessWidget {
  final List<StockSaleItem> items;
  const _SalesTableView({required this.items});

  String _fmt(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 980.w),
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
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('PRODUCT')),
              DataColumn(label: Text('AGENT')),
              DataColumn(label: Text('STOCK_SALE')),
            ],
            rows: items.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(_fmt(e.date))),
                  DataCell(SizedBox(width: 140.w, child: Text(e.productName, overflow: TextOverflow.ellipsis))),
                  DataCell(SizedBox(width: 110.w, child: Text(e.name, overflow: TextOverflow.ellipsis))),
                  DataCell(Text(e.stockSale.toStringAsFixed(2))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}


/// ---------------- Tile view ----------------
class _SalesTileView extends StatelessWidget {
  final List<StockSaleItem> items;
  const _SalesTileView({required this.items});

  String _fmt(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

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

            // Leading initial badge
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
            //     (e.productName.isNotEmpty ? e.productName[0] : '-').toUpperCase(),
            //     style: TextStyle(
            //       color: AppTheme.adminWhite,
            //       fontWeight: FontWeight.w700,
            //       fontSize: 14.sp,
            //     ),
            //   ),
            // ),

            // Title: product name
            title: Text(
              e.productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.adminWhite,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Subtitle: agent + date
            subtitle: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 4.h),
                  Text(
                    'Date: ${_fmt(e.date)}',
                    style: TextStyle(
                      color: AppTheme.adminWhite.withOpacity(.7),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing: sale amount chip
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.adminGreen.withOpacity(.28),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppTheme.adminGreen),
              ),
              child: Text(
                e.stockSale.toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

