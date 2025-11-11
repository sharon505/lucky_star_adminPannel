// lib/features/reports/views/profit_and_loss_statement.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';
import '../../../core/constants/app_floatAction.dart';

import '../../../core/theme/text_styles.dart';
import '../viewModels/profit_loss_view_model.dart';
import '../models/profit_loss_model.dart';

class ProfitAndLossStatement extends StatelessWidget {
  const ProfitAndLossStatement({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PandLScaffold();
  }
}

class _PandLScaffold extends StatelessWidget {
  const _PandLScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfitLossViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Profit And Loss Statement'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(onPressed: () => _openFilterDialog(context)),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _PandLContent(
          isLoading: vm.isLoading,
          error: vm.error,
          rows: vm.items,
          totalIncome: vm.totalIncome,
          totalExpenses: vm.totalExpenses,
          netProfit: vm.netProfit,
          date: vm.date,
        ),
      ),
    );
  }
}

/// ---------------- Filter Dialog (Date) ----------------
Future<void> _openFilterDialog(BuildContext context) async {
  final vm = context.read<ProfitLossViewModel>();
  DateTime date = vm.date ?? DateTime.now();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title:  Text(
          'Profit & Loss',
          style: AppTypography.heading1.copyWith(
              fontSize: 17.sp,
              color: AppTheme.adminGreen
          ),
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
              await vm.loadByDate(date: date);
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

class _PandLContent extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final List<ProfitLossRow> rows;
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final DateTime? date;

  const _PandLContent({
    super.key,
    required this.isLoading,
    required this.error,
    required this.rows,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.date,
  });

  @override
  State<_PandLContent> createState() => _PandLContentState();
}

class _PandLContentState extends State<_PandLContent> {
  _ViewMode _mode = _ViewMode.table;

  // ---- Ordering helper: Income -> Expenses -> Others -> Totals ----
  List<ProfitLossRow> _orderPandL(List<ProfitLossRow> src) {
    final totals = <ProfitLossRow>[];
    final incomes = <ProfitLossRow>[];
    final expenses = <ProfitLossRow>[];
    final others = <ProfitLossRow>[];

    int _rank(ProfitLossRow e) {
      final d = e.description.trim().toUpperCase();
      if (d.contains('TOTAL INCOME') || d.contains('TOTAL EXPENSE') || d.contains('NET PROFIT')) return 3; // totals last
      if (d.contains('INCOME')) return 0;   // income first
      if (d.contains('EXPENSE')) return 1;  // then expenses
      return 2;                              // anything else
    }

    for (final e in src) {
      switch (_rank(e)) {
        case 0:
          incomes.add(e);
          break;
        case 1:
          expenses.add(e);
          break;
        case 2:
          others.add(e);
          break;
        default:
          totals.add(e);
          break;
      }
    }

    // Sort inside groups if needed (by description). Change comparator to amount if preferred.
    int byDesc(ProfitLossRow a, ProfitLossRow b) =>
        a.description.toLowerCase().compareTo(b.description.toLowerCase());
    incomes.sort(byDesc);
    expenses.sort(byDesc);
    others.sort(byDesc);
    // Keep totals as-is so that server order (Total Income, Total Expenses, Net Profit) is preserved.

    return [...incomes, ...expenses, ...others, ...totals];
  }

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
            Text('No data',
                style: TextStyle(color: AppTheme.adminWhite.withOpacity(.9), fontSize: 14.sp)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              children: [
                OutlinedButton(
                  onPressed: () => context.read<ProfitLossViewModel>().refresh(),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.adminGreen,
                    foregroundColor: Colors.black,
                  ),
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

    final ordered = _orderPandL(widget.rows);

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
                    if (dateStr.isNotEmpty)
                      Text(
                        'Date: $dateStr',
                        style: TextStyle(
                          color: AppTheme.adminWhite.withOpacity(.85),
                          fontSize: 12.sp,
                        ),
                      ),
                    _chipStat('Total Income', widget.totalIncome),
                    _chipStat('Total Expenses', widget.totalExpenses),
                    _chipStat('Net Profit', widget.netProfit, highlight: true),
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
                ? _PandLTable(items: ordered)
                : _PandLTiles(items: ordered),
          ),
        ),
      ],
    );
  }

  Widget _chipStat(String label, double value, {bool highlight = false}) {
    final bg = highlight
        ? AppTheme.adminGreen.withOpacity(.28)
        : AppTheme.adminWhite.withOpacity(.06);
    final br = highlight ? AppTheme.adminGreen : AppTheme.adminWhite.withOpacity(.12);
    final txt = highlight ? Colors.black : AppTheme.adminWhite;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: br),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
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
class _PandLTable extends StatefulWidget {
  final List<ProfitLossRow> items;
  const _PandLTable({required this.items});

  @override
  State<_PandLTable> createState() => _PandLTableState();
}

class _PandLTableState extends State<_PandLTable> {
  final _hCtrl = ScrollController();
  final _vCtrl = ScrollController();

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  // ---------- helpers ----------
  ProfitLossRow? _find(String key) {
    final i = widget.items.indexWhere(
          (e) => e.description.toLowerCase().contains(key.toLowerCase()),
    );
    return i == -1 ? null : widget.items[i];
  }

  DataRow _bandRow({
    required String title,
    Color? bg,
    Color? fg,
    FontWeight weight = FontWeight.w900,
  }) {
    return DataRow(
      color: bg != null ? WidgetStatePropertyAll(bg) : null,
      cells: [
        DataCell(Text(
          title,
          style: TextStyle(color: fg ?? AppTheme.adminWhite, fontWeight: weight),
        )),
        const DataCell(Text('')),
      ],
    );
  }

  DataRow _amountRow(String label, double amount) {
    return DataRow(cells: [
      DataCell(SizedBox(
        width: 255.w,
        child: Text(label, overflow: TextOverflow.ellipsis),
      )),
      DataCell(Text(amount.toStringAsFixed(2))),
    ]);
  }

  DataRow _netProfitRow(ProfitLossRow r) {
    return DataRow(cells: [
      DataCell(Text(
        r.description,
        style: const TextStyle(fontWeight: FontWeight.w900),
      )),
      const DataCell(SizedBox(width: 6)),
    ]); // amount in the next row for bold separation if desired
  }

  DataRow _netProfitAmountRow(ProfitLossRow r) {
    return DataRow(cells: [
      const DataCell(Text('')),
      DataCell(Text(
        r.amount.toStringAsFixed(2),
        style: const TextStyle(fontWeight: FontWeight.w900),
      )),
    ]);
  }

  DataRow _blankRow() => const DataRow(cells: [
    DataCell(Text('')),
    DataCell(Text('')),
  ]);

  @override
  Widget build(BuildContext context) {
    // pick rows by fuzzy keys
    final income              = _find('income');                   // INCOME (detail line)
    final agentReceivable     = _find('agent rece');               // AGENT RECEIVABLE
    final agentCollection     = _find('agent coll');               // AGENT COLLECTION
    final totalIncome         = _find('total inco');               // TOTAL INCOME
    final prizePayout         = _find('prize amount payout');      // PRIZE AMOUNT PAYOUT
    final incentivePayable    = _find('incentive payable');        // INCENTIVE PAYABLE
    final incentivePaid       = _find('incentive paid');           // INCENTIVE PAID
    final totalExpenses       = _find('total expe');               // TOTAL EXPENSES
    final netProfit           = _find('net prof');                 // NET PROFIT

    // colors to match your screenshot vibe
    final incomeBandBg   = AppTheme.adminWhite.withOpacity(.06);   // subtle band
    final blueBandBg     = const Color(0xFF3DA5FF).withOpacity(.18);
    final blueBandFg     = const Color(0xFF3DA5FF);
    final pinkBandBg     = const Color(0xFFFF5E8A).withOpacity(.18);
    final pinkBandFg     = const Color(0xFFFF5E8A);
    final incomeBlueBg        = const Color(0xFF3DA5FF).withOpacity(.18);
    final incomeBlueFg        = const Color(0xFF3DA5FF);

    final totalIncomeGreenBg  = AppTheme.adminGreen.withOpacity(.18);
    final totalIncomeGreenFg  = AppTheme.adminGreen;

    final orderedRows = <DataRow>[
      // INCOME (blue band)
      _bandRow(title: 'INCOME', bg: incomeBlueBg, fg: incomeBlueFg),
      if (agentReceivable != null)  _amountRow(agentReceivable.description, agentReceivable.amount),
      if (agentCollection != null)  _amountRow(agentCollection.description, agentCollection.amount),

      // TOTAL INCOME (green band)
      _bandRow(title: 'TOTAL INCOME', bg: totalIncomeGreenBg, fg: totalIncomeGreenFg),
      if (totalIncome != null)      _amountRow(totalIncome.description, totalIncome.amount),

      // Expense lines
      if (prizePayout != null)      _amountRow(prizePayout.description, prizePayout.amount),
      if (incentivePayable != null) _amountRow(incentivePayable.description, incentivePayable.amount),
      if (incentivePaid != null)    _amountRow(incentivePaid.description, incentivePaid.amount),

      // TOTAL EXPENSES (keep pink/red as before)
      _bandRow(title: 'TOTAL EXPENSES', bg: pinkBandBg, fg: pinkBandFg),
      if (totalExpenses != null)    _amountRow(totalExpenses.description, totalExpenses.amount),

      // NET PROFIT (no band per your screenshot)
      if (netProfit != null)        _amountRow(netProfit.description, netProfit.amount),

      _blankRow(),
    ];




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
                    DataColumn(label: Text('DESCRIPTION')),
                    DataColumn(label: Text('AMOUNT')),
                  ],
                  rows: orderedRows,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




class _PandLTiles extends StatelessWidget {
  final List<ProfitLossRow> items;
  const _PandLTiles({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, i) {
        final e = items[i];
        final isTotal = _isTotal(e.description);

        final bgColor = isTotal
            ? AppTheme.adminGreen.withOpacity(.25)
            : AppTheme.adminWhite.withOpacity(.06);

        final titleStyle = TextStyle(
          color: AppTheme.adminWhite,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        );

        final amountStyle = TextStyle(
          color: isTotal ? Colors.black : AppTheme.adminWhite,
          fontWeight: FontWeight.w800,
          fontSize: 14.sp,
        );

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppTheme.adminWhite.withOpacity(.10)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            title: Text(
              e.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            // keep subtitle empty (or add category/notes later)
            subtitle: null,
            trailing: Text(
              _fmt(e.amount),
              style: amountStyle,
            ),
          ),
        );
      },
    );
  }

  String _fmt(double v) =>
      v.toStringAsFixed(v % 1 == 0 ? 0 : 2); // 100 → 100 ; 100.5 → 100.50

  bool _isTotal(String d) {
    final s = d.trim().toUpperCase();
    return s == 'TOTAL INCOME' || s == 'TOTAL EXPENSES' || s == 'NET PROFIT';
  }
}

