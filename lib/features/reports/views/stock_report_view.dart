// lib/features/reports/views/stock_report_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../core/constants/app_appbar.dart';        // AppAppbar(text: ...)
import '../../../core/constants/app_floatAction.dart';  // AppFloatAction

import '../../../core/theme/text_styles.dart';
import '../viewModels/product_view_model.dart';
import '../viewModels/stock_report_view_model.dart';
import '../models/product_models.dart';
import '../models/stock_summary_models.dart';

class StockReportView extends StatelessWidget {
  const StockReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return _StockReportScaffold();
  }
}

class _StockReportScaffold extends StatefulWidget {
  const _StockReportScaffold();

  @override
  State<_StockReportScaffold> createState() => _StockReportScaffoldState();
}

class _StockReportScaffoldState extends State<_StockReportScaffold> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(context));
  }

  Future<void> _bootstrap(BuildContext context) async {
    if (_bootstrapped) return;

    final productVm = context.read<ProductViewModel>();
    final stockVm   = context.read<StockReportViewModel>();

    // Wait briefly for products to load (since ProductViewModel.load() runs elsewhere)
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (productVm.isLoading && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 120));
    }

    // If still no products or error, don't block the screen; user can open filter dialog to retry
    List<ProductItem> list = productVm.filteredItems.isNotEmpty
        ? productVm.filteredItems
        : productVm.items;

    if (list.isEmpty) {
      setState(() => _bootstrapped = true);
      return;
    }

    // Prefer VM’s already-selected product if present, else first available
    final int productId = stockVm.productId != 0
        ? stockVm.productId
        : (productVm.selected?.productId ?? list.first.productId);

    // Use VM’s date (it already holds last-picked date or a sensible default)
    final DateTime date = stockVm.date;

    await stockVm.fetch(date: date, productId: productId);

    if (mounted) setState(() => _bootstrapped = true);
  }

  @override
  Widget build(BuildContext context) {
    final stockVm = context.watch<StockReportViewModel>();

    return Scaffold(
      appBar: const AppAppbar(text: 'Stock Report'),
      backgroundColor: AppTheme.adminGreenLite,
      floatingActionButton: AppFloatAction(
        onPressed: () => _openFilterDialog(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: _StockTable(
          items: stockVm.items,
          // While bootstrapping, force the spinner so there’s clear feedback
          isLoading: stockVm.isLoading || !_bootstrapped,
          error: stockVm.error,
          date: stockVm.date,
          productId: stockVm.productId,
        ),
      ),
    );
  }
}


/// ---------------- Dialog ----------------

Future<void> _openFilterDialog(BuildContext context) async {
  final stockVm = context.read<StockReportViewModel>();
  final productVm = context.read<ProductViewModel>();

  // seed with current values
  DateTime selectedDate = stockVm.date;
  ProductItem? selectedProduct = productVm.selected;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final formKey = GlobalKey<FormState>();

      return AlertDialog(
        backgroundColor: AppTheme.adminGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Stock Report',
          style: AppTypography.heading1.copyWith(
            fontSize: 17.sp,
            color: AppTheme.adminGreen
          ),
          //style: TextStyle(color: AppTheme.adminWhite, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Dropdown from ProductViewModel
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

                  final items = pvm.filteredItems;
                  if (selectedProduct == null && items.isNotEmpty) {
                    selectedProduct = items.first;
                  }

                  return DropdownButtonFormField<ProductItem>(
                    value: selectedProduct,
                    items: items
                        .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.productName, overflow: TextOverflow.ellipsis),
                    ))
                        .toList(),
                    onChanged: (v) => selectedProduct = v,
                    validator: (v) => v == null ? 'Select a product' : null,
                    decoration: _inputDeco('Product'),
                    dropdownColor: AppTheme.adminGreenDark,
                    style: const TextStyle(color: AppTheme.adminWhite),
                  );
                },
              ),
              SizedBox(height: 12.h),

              // Date picker
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
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
                    selectedDate = d;
                    (ctx as Element).markNeedsBuild();
                  }
                },
                child: InputDecorator(
                  decoration: _inputDeco('Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmtDate(selectedDate),
                          style: const TextStyle(color: AppTheme.adminWhite)),
                      const Icon(Icons.calendar_today_rounded, color: AppTheme.adminGreen),
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
              if (!formKey.currentState!.validate()) return;
              if (selectedProduct == null) return;

              await stockVm.fetch(
                date: selectedDate,
                productId: selectedProduct!.productId,
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

/// ---------------- Table ----------------

class _StockTable extends StatelessWidget {
  final List<StockSummaryItem> items;
  final bool isLoading;
  final String? error;
  final DateTime date;
  final int productId;

  const _StockTable({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.date,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.adminGreen));
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.redAccent)));
    }
    if (items.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: AppTheme.adminWhite)));
    }

    // Read product name via ProductViewModel, with ScreenUtil spacing
    final productName = context.select<ProductViewModel, String?>((pvm) {
      final sel = pvm.selected;
      if (sel != null && sel.productId == productId) return sel.productName;
      final found = pvm.items.where((e) => e.productId == productId);
      return found.isNotEmpty ? found.first.productName : null;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header summary (Date + Product Name) with ScreenUtil
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Date: ${_fmtDate(date)}',
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(.85),
                  fontSize: 12.sp,
                ),
              ),
              Text(
                'Product: ${productName ?? '-'}',
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(.85),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),

        // Compact DataTable, constrained width
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520.w), // shrink table width
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.w,
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
                    DataColumn(label: Text('STOCK')),
                    DataColumn(label: Text('BALANCE')),
                  ],
                  rows: items.map((e) {
                    return DataRow(cells: [
                      DataCell(
                        SizedBox(
                          width: 220.w,
                          child: Text(
                            e.descriptions,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text('${e.stock}')),
                      DataCell(Text('${e.balanceStock}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
