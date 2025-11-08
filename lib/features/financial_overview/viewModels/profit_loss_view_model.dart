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
  List<ProfitLossRow> _rows = const [];

  // ---- Last-used filter ----
  DateTime? _date; // last requested date (date-only)

  // ---- Getters ----
  bool get isLoading => _loading;
  String? get error => _error;
  List<ProfitLossRow> get items => _rows;
  DateTime? get date => _date;
  bool get hasData => _rows.isNotEmpty && _error == null;

  // ---- Derived totals (using description keys from API) ----
  double get totalIncome   => _byDesc('TOTAL INCOME');
  double get totalExpenses => _byDesc('TOTAL EXPENSES');
  double get netProfit     => _byDesc('NET PROFIT');

  /// Sum of all amounts (in case backend doesn't send total rows)
  double get sumAll => _rows.fold(0.0, (s, e) => s + e.amount);

  // ---- Actions ----
  Future<void> loadByDate({required DateTime date}) async {
    // normalize to date-only
    final d = DateTime(date.year, date.month, date.day);

    _set(loading: true, error: null);
    try {
      _date = d;

      final res = await _service.fetchByDate(date: d);
      final data = [...res.result];

      // Optional: presentation order
      int rank(String d) {
        final s = d.trim().toUpperCase();
        if (s == 'INCOME' || s.contains('AGENT RECEIVABLE') || s.contains('AGENT COLLECTION')) return 0;
        if (s == 'TOTAL INCOME') return 1;
        if (s.contains('PRIZE') || s.contains('INCENTIVE')) return 2; // expenses group
        if (s == 'TOTAL EXPENSES') return 3;
        if (s == 'NET PROFIT') return 4;
        return 5;
      }

      data.sort((a, b) {
        final r = rank(a.description).compareTo(rank(b.description));
        return r != 0
            ? r
            : a.description.toLowerCase().compareTo(b.description.toLowerCase());
      });

      _rows = data;
      if (_rows.isEmpty) {
        _set(error: 'No records found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _rows = const [];
      _set(error: 'Failed to load Profit & Loss: $e');
    } finally {
      _set(loading: false);
    }
  }

  /// Re-run the last successful query
  Future<void> refresh() async {
    if (_date == null) {
      _set(error: 'Pick a date first.');
      return;
    }
    await loadByDate(date: _date!);
  }

  /// Optional helper to just change the date (without fetching)
  void setDate(DateTime d) {
    _date = DateTime(d.year, d.month, d.day);
    notifyListeners();
  }

  /// Convenience: load with today’s date (if you want an auto fetch)
  Future<void> autoBootstrap() async {
    final now = DateTime.now();
    await loadByDate(date: DateTime(now.year, now.month, now.day));
  }

  // ---- Helpers ----
  double _byDesc(String key) {
    final k = key.toUpperCase();
    final r = _rows.firstWhere(
          (e) => e.description.trim().toUpperCase() == k,
      orElse: () => const ProfitLossRow(description: '', amount: 0.0),
    );
    return r.amount;
  }

  void clear() {
    _rows = const [];
    _error = null;
    _loading = false;
    _date = null;
    notifyListeners();
  }

  void _set({bool? loading, String? error}) {
    var shouldNotify = false;
    if (loading != null && _loading != loading) {
      _loading = loading;
      shouldNotify = true;
    }
    if (error != _error) {
      _error = error;
      shouldNotify = true;
    }
    if (shouldNotify) notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
