import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../models/expense_Income_tracker.dart';
import '../viewModels/expense_income_tracker_view_model.dart';

class ExpenseIncomeTracker extends StatelessWidget {
  const ExpenseIncomeTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TrackerScaffold();
  }
}

class _TrackerScaffold extends StatefulWidget {
  const _TrackerScaffold({super.key});

  @override
  State<_TrackerScaffold> createState() => _TrackerScaffoldState();
}

class _TrackerScaffoldState extends State<_TrackerScaffold> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    final vm = context.read<ExpenseIncomeTrackerViewModel>();
    await vm.autoBootstrap(); // today..today, default group (EXPENSE)
    if (!mounted) return;
    setState(() => _bootstrapped = true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseIncomeTrackerViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Expense Income Tracker'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(onPressed: () => _openFilterDialog(context)),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _TrackerContent(
          isLoading: vm.isLoading || !_bootstrapped,
          error: vm.error,
          rows: vm.items,
          totalDebit: vm.totalDebit,
          totalCredit: vm.totalCredit,
          net: vm.net,
          from: vm.fromDate,
          to: vm.toDate,
          group: vm.group,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog (From/To + Group) ----------------
Future<void> _openFilterDialog(BuildContext context) async {
  final vm = context.read<ExpenseIncomeTrackerViewModel>();

  DateTime from = vm.fromDate ?? DateTime.now().subtract(Duration(days: 10));
  DateTime to   = vm.toDate   ?? DateTime.now().subtract(Duration(days: 1));
  String group  = vm.group; // EXPENSE / INCOME

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      return StatefulBuilder(
        builder: (ctx, setStateDialog) {
          Future<void> pickFrom() async {
            final picked = await _pickDate(ctx, from);
            if (picked != null) {
              setStateDialog(() {
                from = DateTime(picked.year, picked.month, picked.day);
                if (to.isBefore(from)) to = from; // keep range valid
              });
            }
          }

          Future<void> pickTo() async {
            final picked = await _pickDate(ctx, to);
            if (picked != null) {
              setStateDialog(() {
                to = DateTime(picked.year, picked.month, picked.day);
                if (from.isAfter(to)) from = to; // keep range valid
              });
            }
          }

          return AlertDialog(
            backgroundColor: AppTheme.adminGreenDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            title: const Text(
              'Filter — Expense/Income',
              style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DateField(label: 'From Date', date: from, onTap: pickFrom),
                    SizedBox(height: 10.h),
                    _DateField(label: 'To Date', date: to, onTap: pickTo),
                    SizedBox(height: 10.h),
                    DropdownButtonFormField<String>(
                      value: group,
                      items: const [
                        DropdownMenuItem(value: 'EXPENSE', child: Text('Expense')),
                        DropdownMenuItem(value: 'INCOME',  child: Text('Income')),
                      ],
                      onChanged: (v) => setStateDialog(() => group = v ?? group),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Select a group' : null,
                      decoration: _inputDeco('Group'),
                      dropdownColor: AppTheme.adminGreenDark,
                      style: const TextStyle(color: AppTheme.adminWhite),
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
                  if (from.isAfter(to)) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('From Date cannot be after To Date')),
                    );
                    return;
                  }
                  await vm.fetch(from: from, to: to, group: group);
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


Future<DateTime?> _pickDate(BuildContext ctx, DateTime initial) {
  return showDatePicker(
    context: ctx,
    initialDate: initial,
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
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.date, required this.onTap});

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

class _TrackerContent extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final List<CashBookItem> rows;
  final double totalDebit;
  final double totalCredit;
  final double net;
  final DateTime? from;
  final DateTime? to;
  final String group;

  const _TrackerContent({
    super.key,
    required this.isLoading,
    required this.error,
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.net,
    required this.from,
    required this.to,
    required this.group,
  });

  @override
  State<_TrackerContent> createState() => _TrackerContentState();
}

class _TrackerContentState extends State<_TrackerContent> {
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
                  onPressed: () => context.read<ExpenseIncomeTrackerViewModel>().refresh(),
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

    String two(int n) => n < 10 ? '0$n' : '$n';
    String dateStr(DateTime? d) =>
        d == null ? '' : '${two(d.day)}/${two(d.month)}/${d.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header summary + toggle
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (widget.from != null && widget.to != null)
                      Text(
                        'Range: ${dateStr(widget.from)} → ${dateStr(widget.to)}',
                        style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                      ),
                    _chip('Group', widget.group),
                    _chip('Total Debit', widget.totalDebit.toStringAsFixed(2)),
                    _chip('Total Credit', widget.totalCredit.toStringAsFixed(2)),
                    _chip('Net', widget.net.toStringAsFixed(2), highlight: true),
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
                ? _TrackerTable(items: widget.rows)
                : _TrackerTiles(items: widget.rows),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value, {bool highlight = false}) {
    final bg  = highlight ? AppTheme.adminGreen.withOpacity(.28) : AppTheme.adminWhite.withOpacity(.06);
    final br  = highlight ? AppTheme.adminGreen : AppTheme.adminWhite.withOpacity(.12);
    final txt = highlight ? Colors.black : AppTheme.adminWhite;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: br),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: txt,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
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
class _TrackerTable extends StatefulWidget {
  final List<CashBookItem> items;
  const _TrackerTable({required this.items});

  @override
  State<_TrackerTable> createState() => _TrackerTableState();
}

class _TrackerTableState extends State<_TrackerTable> {
  final _hCtrl = ScrollController();
  final _vCtrl = ScrollController();

  String _fmt(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

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
        constraints: BoxConstraints(maxWidth: 1200.w),
        child: Scrollbar(
          controller: _vCtrl,
          thumbVisibility: true,
          child: SingleChildScrollView( // vertical
            controller: _vCtrl,
            child: Scrollbar(
              controller: _hCtrl,
              thumbVisibility: true,
              notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView( // horizontal
                controller: _hCtrl,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 14.w,
                  horizontalMargin: 12.w,
                  headingRowHeight: 36.h,
                  dataRowMinHeight: 36.h,
                  dataRowMaxHeight: 44.h,
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
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('LEDGER')),
                    DataColumn(label: Text('NARRATION')),
                    DataColumn(label: Text('MODE')),
                    DataColumn(label: Text('REF')),
                    DataColumn(label: Text('DEBIT')),
                    DataColumn(label: Text('CREDIT')),
                  ],
                  rows: items.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text(_fmt(e.tranDate))),
                        DataCell(SizedBox(
                          width: 150.w,
                          child: Text(e.ledgerName, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(SizedBox(
                          width: 260.w,
                          child: Text(e.narration, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(Text(e.mode.name.toUpperCase())),
                        DataCell(SizedBox(
                          width: 60.w,
                          child: Text(e.transactionRefNo, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(Text(e.debit.toStringAsFixed(2))),
                        DataCell(Text(e.credit.toStringAsFixed(2))),
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


/// ---------------- Tile view ----------------
class _TrackerTiles extends StatelessWidget {
  final List<CashBookItem> items;
  const _TrackerTiles({required this.items});

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

            // Leading badge (first letter of mode)
            // leading: Container(
            //   width: 42.w,
            //   height: 42.w,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: AppTheme.adminWhite.withOpacity(.08),
            //     borderRadius: BorderRadius.circular(10.r),
            //     border: Border.all(color: AppTheme.adminWhite.withOpacity(.12)),
            //   ),
            //   child: Text(
            //     (e.mode.name.isNotEmpty ? e.mode.name[0] : '-').toUpperCase(),
            //     style: TextStyle(
            //       color: AppTheme.adminWhite,
            //       fontWeight: FontWeight.w800,
            //       fontSize: 14.sp,
            //     ),
            //   ),
            // ),

            // Title: Ledger (bold)
            title: Text(
              e.ledgerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.adminWhite,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),

            // Subtitle: date + mode + optional ref + narration (2 lines)
            subtitle: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: [
                      _chipSmall('${_fmt(e.tranDate)}'),
                      _chipSmall(e.mode.name.toUpperCase()),
                      if (e.transactionRefNo.trim().isNotEmpty)
                        _chipSmall('Ref: ${e.transactionRefNo}'),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    e.narration,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.adminWhite.withOpacity(.9),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing: Debit / Credit stacked
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Debit: ${e.debit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.adminWhite.withOpacity(.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Credit: ${e.credit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.adminWhite.withOpacity(.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // _amt('DEBIT', e.debit, highlight: true),
                // SizedBox(height: 6.h),
                // _amt('CREDIT', e.credit),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chipSmall(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.adminWhite.withOpacity(.06),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.adminWhite.withOpacity(.12)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.adminWhite.withOpacity(.85),
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _amt(String label, double value, {bool highlight = false}) {
    final bg  = highlight ? AppTheme.adminGreen.withOpacity(.28) : AppTheme.adminGreen.withOpacity(.18);
    final br  = highlight ? AppTheme.adminGreen : AppTheme.adminGreen.withOpacity(.55);
    final txt = highlight ? Colors.black : AppTheme.adminGreen;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: br),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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

