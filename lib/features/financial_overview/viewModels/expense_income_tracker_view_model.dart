// lib/features/financial_overview/viewModels/expense_income_tracker_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/expense_Income_tracker.dart';
import '../services/expense_income_tracker_service.dart';

class ExpenseIncomeTrackerViewModel with ChangeNotifier {
  final ExpenseIncomeTrackerService _service;

  ExpenseIncomeTrackerViewModel({ExpenseIncomeTrackerService? service})
      : _service = service ?? ExpenseIncomeTrackerService();

  // ---- State ----
  bool _isLoading = false;
  String? _error;
  List<CashBookItem> _items = [];

  // ---- Current filters ----
  DateTime? _from;
  DateTime? _to;
  String _group = 'EXPENSE'; // normalized uppercase

  // ---- Getters ----
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CashBookItem> get items => _items;

  DateTime? get fromDate => _from;
  DateTime? get toDate => _to;
  String get group => _group;

  double get totalDebit =>
      _items.fold<double>(0.0, (s, e) => s + e.debit);

  double get totalCredit =>
      _items.fold<double>(0.0, (s, e) => s + e.credit);

  double get net => totalDebit - totalCredit;

  // Optional quick buckets
  Map<String, double> get totalByLedger => _sumBy<String>(
    keyOf: (e) => e.ledgerName,
    valueOf: (e) => e.debit - e.credit,
  );

  Map<String, double> get totalByMode => _sumBy<String>(
    keyOf: (e) => e.mode.name.toUpperCase(),
    valueOf: (e) => e.debit - e.credit,
  );

  // ---- Actions ----
  Future<void> fetch({
    required DateTime from,
    required DateTime to,
    required String group,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _from = DateTime(from.year, from.month, from.day);
      _to   = DateTime(to.year,   to.month,   to.day);
      _group = group; // can be any casing; service normalizes

      final rows = await _service.fetchRangeItems(
        from: _from!,
        to: _to!,
        group: _group,
      );

      _items = rows;
    } catch (e) {
      _items = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_from == null || _to == null) {
      _error = 'Select a date range first.';
      notifyListeners();
      return;
    }
    await fetch(from: _from!, to: _to!, group: _group);
  }

  /// Convenience: defaults to today..today for EXPENSE.
  Future<void> autoBootstrap() async {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from  = DateTime(today.year, today.month, 1); // 1st of this month
    await fetch(from: from, to: today, group: _group);
  }


  void setRange(DateTime from, DateTime to, {bool fetchNow = false}) {
    _from = DateTime(from.year, from.month, from.day);
    _to   = DateTime(to.year,   to.month,   to.day);
    notifyListeners();
    if (fetchNow) {
      fetch(from: _from!, to: _to!, group: _group);
    }
  }

  void setGroup(String group, {bool fetchNow = false}) {
    _group = group;
    notifyListeners();
    if (fetchNow && _from != null && _to != null) {
      fetch(from: _from!, to: _to!, group: _group);
    }
  }

  // ---- utils ----
  Map<K, double> _sumBy<K>({
    required K Function(CashBookItem) keyOf,
    required double Function(CashBookItem) valueOf,
  }) {
    final map = <K, double>{};
    for (final e in _items) {
      final k = keyOf(e);
      map[k] = (map[k] ?? 0.0) + valueOf(e);
    }
    return map;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
