// lib/features/reports/viewModels/cash_book_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/cash_book_model.dart';
import '../services/cash_book_service.dart';

class CashBookViewModel with ChangeNotifier {
  final CashBookService _service;

  CashBookViewModel({CashBookService? service})
      : _service = service ?? CashBookService();

  // ---- State ----
  bool _loading = false;
  String? _error;
  List<CashBookRow> _rows = [];

  // ---- Last-used filter ----
  String? _agentId; // keep as string because service expects string

  // ---- Getters ----
  bool get loading => _loading;
  String? get error => _error;
  List<CashBookRow> get rows => _rows;
  String? get agentId => _agentId;

  double get totalDebit =>
      _rows.fold<double>(0.0, (sum, e) => sum + e.debit);

  double get totalCredit =>
      _rows.fold<double>(0.0, (sum, e) => sum + e.credit);

  // ---- Actions ----
  Future<void> load({required String agentId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _agentId = agentId;

      final res = await _service.fetchCashBook(agentId: agentId);

      // Optional sort: keep "OPENING BAL" first, "CLOSING BAL" last
      // and others alphabetically by DESCR. Comment out if not needed.
      final data = [...res.result];
      data.sort((a, b) {
        int rank(String d) {
          final s = d.trim().toUpperCase();
          if (s == 'OPENING BAL') return 0;
          if (s == 'CLOSING BAL') return 2;
          return 1; // middle
        }

        final r = rank(a.descr).compareTo(rank(b.descr));
        if (r != 0) return r;
        return a.descr.toLowerCase().compareTo(b.descr.toLowerCase());
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

  /// Re-run the last successful query.
  Future<void> refresh() async {
    if (_agentId == null) {
      _error = 'Missing filter: choose an Agent first.';
      notifyListeners();
      return;
    }
    await load(agentId: _agentId!);
  }

  /// Convenience: directly call with an agentId after agents load.
  Future<void> autoBootstrap({required int agentId}) async {
    await load(agentId: '$agentId');
  }

  void clear() {
    _rows = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
