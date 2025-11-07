import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../../reports/models/distributor_models.dart';
import '../../reports/viewModels/distributor_view_model.dart';
import '../viewModels/cash_book_view_model.dart';
import '../models/cash_book_model.dart';

class GetCashBook extends StatelessWidget {
  const GetCashBook({super.key});

  @override
  Widget build(BuildContext context) {
    return _CashBookScaffold();
  }
}

class _CashBookScaffold extends StatefulWidget {
  const _CashBookScaffold();

  @override
  State<_CashBookScaffold> createState() => _CashBookScaffoldState();
}

class _CashBookScaffoldState extends State<_CashBookScaffold> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    final avm = context.read<DistributorViewModel>();
    final vm  = context.read<CashBookViewModel>();

    // Wait briefly for agent list to load
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      final ok = !avm.isLoading && avm.error == null && avm.filteredItems.isNotEmpty;
      if (ok) break;
    }
    if (!mounted) return;

    if (avm.filteredItems.isNotEmpty) {
      final firstAgentId = avm.filteredItems.first.distributorId;
      await vm.autoBootstrap(agentId: firstAgentId);
    }

    if (mounted) setState(() => _bootstrapped = true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CashBookViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Cash Book'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(onPressed: () => _openFilterDialog(context)),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _CashBookContent(
          isLoading: vm.loading || !_bootstrapped,
          error: vm.error,
          rows: vm.rows,
          totalDebit: vm.totalDebit,
          totalCredit: vm.totalCredit,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog (Agent only) ----------------
Future<void> _openFilterDialog(BuildContext context) async {
  final vm = context.read<CashBookViewModel>();
  final agentVm = context.read<DistributorViewModel>();

  int? selAgentId;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Filter — Cash Book',
          style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              if (selAgentId == null) return;
              await vm.load(agentId: '$selAgentId');
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

/// ---------------- Content (Header + Table/Tiles toggle) ----------------

enum _ViewMode { table, tiles }

class _CashBookContent extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final List<CashBookRow> rows;
  final double totalDebit;
  final double totalCredit;

  const _CashBookContent({
    required this.isLoading,
    required this.error,
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
  });

  @override
  State<_CashBookContent> createState() => _CashBookContentState();
}

class _CashBookContentState extends State<_CashBookContent> {
  _ViewMode _mode = _ViewMode.table;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.adminGreen));
    }
    if (widget.error != null) {
      return Center(child: Text(widget.error!, style: const TextStyle(color: Colors.redAccent)));
    }
    if (widget.rows.isEmpty) {
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
                  onPressed: () => context.read<CashBookViewModel>().refresh(),
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
                    Text(
                      'Rows: ${widget.rows.length}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                    Text(
                      'Total Debit: ${widget.totalDebit.toStringAsFixed(2)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                    Text(
                      'Total Credit: ${widget.totalCredit.toStringAsFixed(2)}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
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
                ? _CashBookTable(items: widget.rows, totalDebit: widget.totalDebit, totalCredit: widget.totalCredit)
                : _CashBookTiles(items: widget.rows),
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
class _CashBookTable extends StatelessWidget {
  final List<CashBookRow> items;
  final double totalDebit;
  final double totalCredit;

  const _CashBookTable({
    required this.items,
    required this.totalDebit,
    required this.totalCredit,
  });

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
              DataColumn(label: Text('DESCR')),
              DataColumn(label: Text('DEBIT')),
              DataColumn(label: Text('CREDIT')),
            ],
            rows: [
              ...items.map((e) => DataRow(
                cells: [
                  DataCell(SizedBox(width: 260.w, child: Text(e.descr, overflow: TextOverflow.ellipsis))),
                  DataCell(Text(e.debit.toStringAsFixed(2))),
                  DataCell(Text(e.credit.toStringAsFixed(2))),
                ],
              )),
              // footer (totals)
              DataRow(
                color: WidgetStatePropertyAll(AppTheme.adminWhite.withOpacity(.06)),
                cells: [
                  const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataCell(Text(totalDebit.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w800))),
                  DataCell(Text(totalCredit.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w800))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- Tile view ----------------
class _CashBookTiles extends StatelessWidget {
  final List<CashBookRow> items;
  const _CashBookTiles({required this.items});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const minTileW = 260.0;
    final crossAxisCount = (screenW / minTileW).floor().clamp(1, 4);

    return GridView.builder(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.9,
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
              Text(
                e.descr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.adminWhite,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _pill('DEBIT', e.debit, highlight: true),
                  SizedBox(width: 8.w),
                  _pill('CREDIT', e.credit),
                ],
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _pill(String label, double value, {bool highlight = false}) {
    final bg  = highlight ? AppTheme.adminGreen.withOpacity(.28) : AppTheme.adminGreen.withOpacity(.18);
    final br  = highlight ? AppTheme.adminGreen : AppTheme.adminGreen.withOpacity(.55);
    final txt = highlight ? Colors.black : AppTheme.adminGreen;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: br),
      ),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(value % 1 == 0 ? 0 : 2),
            style: TextStyle(
              color: txt,
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
