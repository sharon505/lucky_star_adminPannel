import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../viewModels/agent_stock_issue_view_model.dart';
import '../viewModels/distributor_view_model.dart';
import '../viewModels/product_view_model.dart';
import '../models/product_models.dart';
import '../models/distributor_models.dart';
import '../models/agent_stock_issue_models.dart';

class AgentStockIssueDetails extends StatelessWidget {
  const AgentStockIssueDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return _AgentIssueScaffold();
  }
}

class _AgentIssueScaffold extends StatelessWidget {
  const _AgentIssueScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AgentStockIssueViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Agent Stock Issue Details'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(
        onPressed: () => _openFilterDialog(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _IssueContent(
          items: vm.filteredItems,
          isLoading: vm.isLoading,
          error: vm.error,
          dateFrom: vm.dateFrom,
          dateTo: vm.dateTo,
          total: vm.totalIssueCount,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog ----------------

Future<void> _openFilterDialog(BuildContext context) async {
  final issueVm = context.read<AgentStockIssueViewModel>();
  final productVm = context.read<ProductViewModel>();
  final distVm = context.read<DistributorViewModel>();

  // Seed with current values (default to today if null)
  DateTime rangeFrom = issueVm.dateFrom;
  DateTime rangeTo   = issueVm.dateTo;

  ProductItem? selProduct = productVm.selected;
  DistributorItem? selDistributor = distVm.selected;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      Future<void> pickDate({required bool isFrom}) async {
        final initial = isFrom ? rangeFrom : rangeTo;
        final d = await showDatePicker(
          context: ctx,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (c, child) => Theme(
            data: Theme.of(c).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.adminGreen,
                onPrimary: Colors.black,
                surface: AppTheme.adminGreenDark,
                onSurface: AppTheme.adminWhite,
              ),
            ),
            child: child!,
          ),
        );
        if (d != null) {
          if (isFrom) {
            rangeFrom = d;
            if (rangeTo.isBefore(rangeFrom)) rangeTo = rangeFrom;
          } else {
            rangeTo = d;
            if (rangeFrom.isAfter(rangeTo)) rangeFrom = rangeTo;
          }
          (ctx as Element).markNeedsBuild();
        }
      }

      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Filter Agent Issue Details',
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

                    int? selProductId = selProduct?.productId;
                    if (selProductId == null || !uniq.containsKey(selProductId)) {
                      selProductId = items.isNotEmpty ? items.first.productId : null;
                      if (selProductId != null) selProduct = uniq[selProductId];
                    }

                    return DropdownButtonFormField<int>(
                      value: selProductId,
                      items: items
                          .map((p) => DropdownMenuItem<int>(
                        value: p.productId,
                        child: Text(p.productName, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (int? v) {
                        if (v == null) return;
                        selProduct = uniq[v];
                      },
                      validator: (v) => v == null ? 'Select a product' : null,
                      decoration: _inputDeco('Product'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // ---------- Distributor (ID-based value + de-dup) ----------
                Consumer<DistributorViewModel>(
                  builder: (_, dvm, __) {
                    if (dvm.isLoading) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: const LinearProgressIndicator(color: AppTheme.adminGreen),
                      );
                    }
                    if (dvm.error != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(dvm.error!, style: const TextStyle(color: Colors.redAccent)),
                          SizedBox(height: 8.h),
                          OutlinedButton(onPressed: () => dvm.load(), child: const Text('Retry')),
                        ],
                      );
                    }

                    // De-dupe by distributorId
                    final Map<int, DistributorItem> uniq = {};
                    for (final d in dvm.filteredItems) {
                      uniq[d.distributorId] = d;
                    }
                    final items = uniq.values.toList()
                      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    int? selDistributorId = selDistributor?.distributorId;
                    if (selDistributorId == null || !uniq.containsKey(selDistributorId)) {
                      selDistributorId = items.isNotEmpty ? items.first.distributorId : null;
                      if (selDistributorId != null) selDistributor = uniq[selDistributorId];
                    }

                    return DropdownButtonFormField<int>(
                      value: selDistributorId,
                      items: items
                          .map((d) => DropdownMenuItem<int>(
                        value: d.distributorId,
                        child: Text(d.name, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (int? v) {
                        if (v == null) return;
                        selDistributor = uniq[v]; // keep full model
                      },
                      validator: (v) => v == null ? 'Select a distributor' : null,
                      decoration: _inputDeco('Distributor'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // Date range (always visible) — side-by-side columns
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => pickDate(isFrom: true),
                        child: InputDecorator(
                          decoration: _inputDeco('From'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fmtDate(rangeFrom),
                                style: const TextStyle(color: AppTheme.adminWhite),
                              ),
                              Icon(Icons.calendar_today_rounded,
                                  color: AppTheme.adminGreen, size: 13.sp),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => pickDate(isFrom: false),
                        child: InputDecorator(
                          decoration: _inputDeco('To'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fmtDate(rangeTo),
                                style: const TextStyle(color: AppTheme.adminWhite),
                              ),
                              Icon(Icons.calendar_today_rounded,
                                  color: AppTheme.adminGreen, size: 13.sp),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
              if (selProduct == null || selDistributor == null) return;

              await issueVm.fetch(
                dateFrom: rangeFrom,
                dateTo: rangeTo,
                productId: selProduct!.productId,
                distributorId: selDistributor!.distributorId,
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

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// ---------------- Content with toggle (Table/Tiles) ----------------

enum _ViewMode { table, tiles }

class _IssueContent extends StatefulWidget {
  final List<AgentStockIssueItem> items;
  final bool isLoading;
  final String? error;
  final DateTime dateFrom;
  final DateTime dateTo;
  final double total;

  const _IssueContent({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.dateFrom,
    required this.dateTo,
    required this.total,
  });

  @override
  State<_IssueContent> createState() => _IssueContentState();
}

class _IssueContentState extends State<_IssueContent> {
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
                    Text(
                      'From: ${_fmtDate(widget.dateFrom)}  To: ${_fmtDate(widget.dateTo)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                    // Text('Rows: ${widget.items.length}',
                    //     style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                    // Text('Total Count: ${widget.total.toStringAsFixed(2)}',
                    //     style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp)),
                  ],
                ),
              ),

              // Segmented toggle
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
                ? _IssueTableView(items: widget.items)
                : _IssueTileView(items: widget.items),
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

class _IssueTableView extends StatelessWidget {
  final List<AgentStockIssueItem> items;
  const _IssueTableView({required this.items});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720.w),
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
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('PRODUCT')),
              DataColumn(label: Text('DISTRIBUTOR')),
              DataColumn(label: Text('CODE')),
              DataColumn(label: Text('COUNT')),
            ],
            rows: items.map((e) {
              return DataRow(cells: [
                DataCell(Text('${e.sn}')),
                DataCell(Text(e.issueDate)), // dd/MM/yyyy from API
                DataCell(SizedBox(
                  width: 180.w,
                  child: Text(e.productName, overflow: TextOverflow.ellipsis),
                )),
                DataCell(SizedBox(
                  width: 180.w,
                  child: Text(e.name, overflow: TextOverflow.ellipsis),
                )),
                DataCell(SizedBox(
                  width: 140.w,
                  child: Text(e.distributorCode, overflow: TextOverflow.ellipsis),
                )),
                DataCell(Text(e.issueCount.toStringAsFixed(2))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Tile view ----------------

class _IssueTileView extends StatelessWidget {
  final List<AgentStockIssueItem> items;
  const _IssueTileView({required this.items});

  @override
  Widget build(BuildContext context) {
    // Responsive grid — 2 columns on small, 3+ on larger screens
    final crossAxisCount = MediaQuery.of(context).size.width ~/ 260.0;
    final columns = crossAxisCount.clamp(1, 4);

    return GridView.builder(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.8, // wider cards
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
              // Top row: date + count chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.issueDate,
                      style: TextStyle(
                        color: AppTheme.adminWhite.withOpacity(.9),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.adminGreen.withOpacity(.22),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.adminGreen.withOpacity(.5)),
                    ),
                    child: Text(
                      e.issueCount.toStringAsFixed(2),
                      style: TextStyle(
                        color: AppTheme.adminGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
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
              // Distributor name
              Row(
                children: [
                  Icon(Icons.store_mall_directory_rounded,
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
              // Code
              Row(
                children: [
                  Icon(Icons.badge_rounded,
                      size: 14.sp, color: AppTheme.adminWhite.withOpacity(.8)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      e.distributorCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.adminWhite.withOpacity(.75),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // SN footer
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
}
