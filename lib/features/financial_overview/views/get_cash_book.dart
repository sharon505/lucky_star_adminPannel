// lib/features/financial_overview/views/get_cash_book.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../models/cash_book_model.dart';
import '../viewModels/cash_book_view_model.dart';

class GetCashBook extends StatelessWidget {
  const GetCashBook({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CashBookScaffold();
  }
}

class _CashBookScaffold extends StatefulWidget {
  const _CashBookScaffold({super.key});

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
    final vm = context.read<CashBookViewModel>();
    await vm.autoBootstrap(); // loads today's cash book
    if (!mounted) return;
    setState(() => _bootstrapped = true);
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
          isLoading: vm.isLoading || !_bootstrapped,
          error: vm.error,
          rows: vm.items, // List<DayBookEntry>
          totalDebit: vm.totalDebit,
          totalCredit: vm.totalCredit,
          date: vm.date,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog (Date) ----------------
Future<void> _openFilterDialog(BuildContext context) async {
  final vm = context.read<CashBookViewModel>();
  DateTime date = vm.date ?? DateTime.now();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Filter — Cash Book',
          style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DateField(
                label: 'Date',
                date: date,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: date,
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
                    date = DateTime(picked.year, picked.month, picked.day);
                  }
                },
              ),
            ],
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
              await vm.fetch(date: date);
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

class _CashBookContent extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final List<DayBookEntry> rows;
  final double totalDebit;
  final double totalCredit;
  final DateTime? date;

  const _CashBookContent({
    super.key,
    required this.isLoading,
    required this.error,
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.date,
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

    String two(int n) => n < 10 ? '0$n' : '$n';
    final dateStr = widget.date != null
        ? '${two(widget.date!.day)}/${two(widget.date!.month)}/${widget.date!.year}'
        : '';

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
                    if (dateStr.isNotEmpty)
                      Text(
                        'Date: $dateStr',
                        style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                      ),
                    Text(
                      'Rows: ${widget.rows.length}',
                      style: TextStyle(color: AppTheme.adminWhite.withOpacity(.85), fontSize: 12.sp),
                    ),
                    Text(
                      'Cash Balance: ${widget.totalDebit.toStringAsFixed(2)}',
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
                ? _CashBookTable(
              items: widget.rows,
              totalDebit: widget.totalDebit,
              totalCredit: widget.totalCredit,
            )
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
class _CashBookTable extends StatefulWidget {
  final List<DayBookEntry> items;
  final double totalDebit;
  final double totalCredit;

  const _CashBookTable({
    required this.items,
    required this.totalDebit,
    required this.totalCredit,
  });

  @override
  State<_CashBookTable> createState() => _CashBookTableState();
}

class _CashBookTableState extends State<_CashBookTable> {
  final _hCtrl = ScrollController();
  final _vCtrl = ScrollController();

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
        constraints: BoxConstraints(maxWidth: 980.w),
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
                    DataColumn(label: Text('PARTICULARS')),
                    DataColumn(label: Text('VOUCHER')),
                    DataColumn(label: Text('DEBIT')),
                    DataColumn(label: Text('CREDIT')),
                  ],
                  rows: [
                    ...items.map((e) => DataRow(
                      cells: [
                        DataCell(SizedBox(
                          width: 130.w,
                          child: Text(e.particulars, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(SizedBox(
                          width: 90.w,
                          child: Text(e.voucherNo, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(Text(e.debit.toStringAsFixed(2))),
                        DataCell(Text(e.credit.toStringAsFixed(2))),
                      ],
                    )),
                    // footer (totals)
                    DataRow(
                      color: WidgetStatePropertyAll(
                        AppTheme.adminWhite.withOpacity(.06),
                      ),
                      cells: [
                        const DataCell(
                          Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        const DataCell(
                          Text('—', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        DataCell(
                          Text(
                            widget.totalDebit.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        DataCell(
                          Text(
                            widget.totalCredit.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
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
class _CashBookTiles extends StatelessWidget {
  final List<DayBookEntry> items;
  const _CashBookTiles({required this.items});

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

            // Leading monogram (from particulars)
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
            //     (e.particulars.isNotEmpty ? e.particulars[0] : '-').toUpperCase(),
            //     style: TextStyle(
            //       color: AppTheme.adminWhite,
            //       fontWeight: FontWeight.w700,
            //       fontSize: 14.sp,
            //     ),
            //   ),
            // ),

            // Title: particulars
            title: Text(
              e.particulars,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.adminWhite,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Subtitle: optional voucher + two metric rows
            subtitle: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.voucherNo.trim().isNotEmpty) ...[
                    Text(
                      'Voucher: ${e.voucherNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.adminWhite.withOpacity(.75),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                  _kvRow('Debit', _fmt(e.debit), highlightValue: true),
                  SizedBox(height: 4.h),
                  _kvRow('Credit', _fmt(e.credit)),
                ],
              ),
            ),

            // Empty trailing (or you can add a date/amount chip if available)
            trailing: null,
          ),
        );
      },
    );
  }

  String _fmt(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  /// key : value row with the value right-aligned for a column-like look
  Widget _kvRow(String key, String value, {bool highlightValue = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            key,
            style: TextStyle(
              color: AppTheme.adminWhite.withOpacity(.78),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: highlightValue ? AppTheme.adminGreen : AppTheme.adminWhite.withOpacity(.95),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

