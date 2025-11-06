import 'package:flutter/foundation.dart';

import '../models/cash_receivables_models.dart';
import '../service/cash_receivables_service.dart';

class CashReceivablesViewModel extends ChangeNotifier {
  final CashReceivablesService _service;

  CashReceivablesViewModel({CashReceivablesService? service})
      : _service = service ?? CashReceivablesService();

  // ---- Filters ----
  int _agentId = 0;     // 0 = ALL (adjust if your API differs)
  int _productId = 0;   // 0 = ALL

  // ---- UI state ----
  bool _isLoading = false;
  String? _error;

  // ---- Data ----
  List<CashReceivableItem> _items = const [];

  // ---- Local search ----
  String _query = '';

  // ---------------- Getters ----------------
  int get agentId => _agentId;
  int get productId => _productId;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CashReceivableItem> get items => _items;

  String get query => _query;

  /// Client-side filtered items
  List<CashReceivableItem> get filteredItems {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.productName.toLowerCase().contains(q) ||
          e.distributorId.toString() == q;
    }).toList();
  }

  // ---- Totals (convenience) ----
  double get totalDebit          => _sum((e) => e.debit);
  double get totalCredit         => _sum((e) => e.credit);
  double get totalPayout         => _sum((e) => e.payout);
  double get totalBalanceReceive => _sum((e) => e.balanceReceive);
  double get totalReceivable     => _sum((e) => e.receivable);

  bool get hasData => _items.isNotEmpty && _error == null;

  // ---------------- Public API ----------------

  /// Load using current filters
  Future<void> load() async {
    await fetch(agentId: _agentId, productId: _productId);
  }

  /// Fetch from API (updates filters if provided)
  Future<void> fetch({int? agentId, int? productId}) async {
    _setLoading(true);
    _setError(null);

    if (agentId != null) _agentId = agentId;
    if (productId != null) _productId = productId;
    notifyListeners();

    try {
      final res = await _service.fetchByAgent(
        agentId: _agentId,
        productId: _productId,
      );
      _items = res.result;
      if (_items.isEmpty) {
        _setError('No records found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _items = const [];
      _setError('Failed to fetch data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---- Mutators ----
  void setAgent(int id, {bool auto = false}) {
    _agentId = id;
    notifyListeners();
    if (auto) load();
  }

  void setProduct(int id, {bool auto = false}) {
    _productId = id;
    notifyListeners();
    if (auto) load();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void clearData() {
    _items = const [];
    _error = null;
    notifyListeners();
  }

  void reset() {
    _agentId = 0;
    _productId = 0;
    _query = '';
    _items = const [];
    _error = null;
    notifyListeners();
  }

  // ---------------- Internals ----------------
  double _sum(double Function(CashReceivableItem e) pick) {
    return _items.fold<double>(0.0, (s, e) => s + pick(e));
  }

  void _setLoading(bool v) {
    if (_isLoading == v) return;
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
