// lib/features/reports/views/day_book.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../viewModels/day_book_view_model.dart';
import '../models/day_book_models.dart';

class DayBook extends StatelessWidget {
  const DayBook({super.key});

  @override
  Widget build(BuildContext context) {
    return _DayBookScaffold();
  }
}

class _DayBookScaffold extends StatelessWidget {
  const _DayBookScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayBookViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Day Book'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(
        onPressed: () => _openDateDialog(context),
        // tooltip: 'Filter Date',
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        // padding: EdgeInsets.fromLTRB(12, 12, 12, 96),
        child: _DayBookContent(
          isLoading: vm.isLoading,
          error: vm.error,
          items: vm.items,
          date: vm.date,
          totalDebit: vm.totalDebit,
          totalCredit: vm.totalCredit,
          net: vm.net,
        ),
      ),
    );
  }
}

/// ---------------- Filter (Date picker) ----------------
Future<void> _openDateDialog(BuildContext context) async {
  final vm = context.read<DayBookViewModel>();
  DateTime sel = vm.date ?? DateTime.now();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Select Date — Day Book',
          style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 360.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: sel,
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
                    sel = DateTime(picked.year, picked.month, picked.day);
                  }
                },
                child: InputDecorator(
                  decoration: _inputDeco('Date'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.adminGreen),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          _fmt(sel),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.adminWhite),
                        ),
                      ),
                    ],
                  ),
                ),
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
              await vm.fetch(date: sel);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('APPLY'),
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

String _fmt(DateTime d) {
  String two(int n) => n < 10 ? '0$n' : '$n';
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

/// ---------------- Content (Header + Toggle + Table/Tiles) ----------------
enum _ViewMode { table, tiles }

class _DayBookContent extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final List<DayBookItem> items;
  final DateTime? date;
  final double totalDebit;
  final double totalCredit;
  final double net;

  const _DayBookContent({
    required this.isLoading,
    required this.error,
    required this.items,
    required this.date,
    required this.totalDebit,
    required this.totalCredit,
    required this.net,
  });

  @override
  State<_DayBookContent> createState() => _DayBookContentState();
}

class _DayBookContentState extends State<_DayBookContent> {
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
            Text(
              'No entries for ${widget.date != null ? _fmt(widget.date!) : 'selected date'}',
              style: TextStyle(color: AppTheme.adminWhite.withOpacity(.9), fontSize: 14.sp),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              children: [
                OutlinedButton(
                  onPressed: () => context.read<DayBookViewModel>().refresh(),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.adminGreen, foregroundColor: Colors.black),
                  onPressed: () => _openDateDialog(context),
                  child: const Text('Pick Date'),
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
        // Header: date + totals + toggle
        Container(
          padding: EdgeInsets.all(10.w),
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: AppTheme.adminWhite.withOpacity(.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.adminWhite.withOpacity(.10)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14.w,
                //runSpacing: 6.h,
                //crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _chip('Date', widget.date != null ? _fmt(widget.date!) : '-'),
                  _chip('Debit', widget.totalDebit.toStringAsFixed(2)),
                  _chip('Credit', widget.totalCredit.toStringAsFixed(2)),
                  _chip('Net', widget.net.toStringAsFixed(2), highlight: true),
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

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _mode == _ViewMode.table
                ? _DayBookTable(items: widget.items)
                : _DayBookTiles(items: widget.items),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value, {bool highlight = false}) {
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppTheme.adminWhite.withOpacity(.80),
              fontWeight: FontWeight.w600,
              fontSize: 11.5.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: txt,
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
            ),
          ),
        ],
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
/// ---------------- Table view (now scrolls vertically + horizontally) ----------------
class _DayBookTable extends StatelessWidget {
  final List<DayBookItem> items;
  const _DayBookTable({required this.items});

  String _fmt(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(                // ← vertical scroll
      padding: EdgeInsets.only(bottom: 12.h),    // space above FAB
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 980.w),
          child: SingleChildScrollView(          // ← horizontal scroll
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 14.w,
              horizontalMargin: 12.w,
              headingRowHeight: 36.h,
              dataRowMinHeight: 36.h,
              dataRowMaxHeight: 40.h,
              headingRowColor: WidgetStateProperty.all(
                AppTheme.adminWhite.withOpacity(.08),
              ),
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
                DataColumn(label: Text('DESCRIPTION')),
                DataColumn(label: Text('DEBIT')),
                DataColumn(label: Text('CREDIT')),
              ],
              rows: items.map((e) {
                return DataRow(
                  cells: [
                    DataCell(Text(_fmt(e.tranDate))),
                    DataCell(SizedBox(
                      width: 240.w,
                      child: Text(e.description, overflow: TextOverflow.ellipsis),
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
    );
  }
}


/// ---------------- Tile view ----------------
class _DayBookTiles extends StatelessWidget {
  final List<DayBookItem> items;
  const _DayBookTiles({required this.items});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const minTileW = 270.0;
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
                e.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.adminWhite,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                _fmt(e.tranDate),
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(.75),
                  fontSize: 11.5.sp,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pill('Debit', e.debit, highlight: true),
                  _pill('Credit', e.credit),
                ],
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: br),
      ),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(2),
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
