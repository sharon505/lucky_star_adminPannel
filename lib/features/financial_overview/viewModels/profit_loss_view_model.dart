// lib/features/reports/viewModels/profit_loss_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/profit_loss_model.dart';
import '../services/profit_loss_service.dart';

class ProfitLossViewModel with ChangeNotifier {
  final ProfitLossService _service;

  ProfitLossViewModel({ProfitLossService? service})
      : _service = service ?? ProfitLossService();

  // ---- State ----
  bool _loading = false;
  String? _error;
  List<ProfitLossRow> _rows = [];

  // ---- Last-used filter ----
  DateTime? _date; // last requested date

  // ---- Getters ----
  bool get isLoading => _loading;
  String? get error => _error;
  List<ProfitLossRow> get items => _rows;
  DateTime? get date => _date;

  // ---- Derived totals (using description keys from API) ----
  double get totalIncome => _byDesc('TOTAL INCOME');
  double get totalExpenses => _byDesc('TOTAL EXPENSES');
  double get netProfit => _byDesc('NET PROFIT');

  // Fallback sums if backend doesn’t send those rows:
  double get sumAll => _rows.fold(0.0, (s, e) => s + e.amount);

  // ---- Actions ----
  Future<void> loadByDate({required DateTime date}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _date = date;

      final res = await _service.fetchByDate(date: date);
      final data = [...res.result];

      // Optional presentation order:
      // income group, expenses group, then total rows
      int rank(String d) {
        final s = d.trim().toUpperCase();
        if (s == 'INCOME' || s.contains('AGENT RECEIVABLE') || s.contains('AGENT COLLECTION')) return 0;
        if (s == 'TOTAL INCOME') return 1;
        if (s.contains('PRIZE') || s.contains('INCENTIVE')) return 2; // expenses group
        if (s == 'TOTAL EXPENSES') return 3;
        if (s == 'NET PROFIT') return 4;
        return 5; // misc/end
      }

      data.sort((a, b) {
        final r = rank(a.description).compareTo(rank(b.description));
        if (r != 0) return r;
        return a.description.toLowerCase().compareTo(b.description.toLowerCase());
      });

      _rows = data;
    } catch (e) {
      _rows = [];
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Re-run the last successful query
  Future<void> refresh() async {
    if (_date == null) {
      _error = 'Pick a date first.';
      notifyListeners();
      return;
    }
    await loadByDate(date: _date!);
  }

  /// Convenience: load with today’s date
  Future<void> autoBootstrap() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await loadByDate(date: today);
  }

  // ---- Helpers ----
  double _byDesc(String key) {
    final r = _rows.firstWhere(
          (e) => e.description.trim().toUpperCase() == key.toUpperCase(),
      orElse: () => const ProfitLossRow(description: '', amount: 0.0),
    );
    return r.amount;
  }

  void clear() {
    _rows = [];
    _error = null;
    _loading = false;
    _date = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
