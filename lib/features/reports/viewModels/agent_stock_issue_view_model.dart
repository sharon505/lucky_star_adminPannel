// lib/features/reports/viewmodel/agent_stock_issue_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/agent_stock_issue_models.dart';
import '../service/agent_stock_issue_service.dart';

/// ViewModel for "Agent Stock Issue Details" (simplified/normal)
class AgentStockIssueViewModel extends ChangeNotifier {
  final AgentStockIssueService _service;

  // ---- Filters ----
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateTo   = DateTime.now();
  int? _productId;       // required before fetch
  int? _distributorId;   // a.k.a. agentId (required before fetch)

  // ---- UI state ----
  bool _isLoading = false;
  String? _error;

  // ---- Data ----
  List<AgentStockIssueItem> _items = const [];

  // ---- Optional local search filter ----
  String _query = '';

  AgentStockIssueViewModel({AgentStockIssueService? service})
      : _service = service ?? AgentStockIssueService();

  // ---- Getters ----
  DateTime get dateFrom => _dateFrom;
  DateTime get dateTo => _dateTo;
  int? get productId => _productId;
  int? get distributorId => _distributorId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AgentStockIssueItem> get items => _items;

  String get query => _query;

  /// Filtered view by query (product/distributor/code/date)
  List<AgentStockIssueItem> get filteredItems {
    if (_query.trim().isEmpty) return _items;
    final q = _query.toLowerCase();
    return _items.where((e) {
      return e.productName.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q) ||
          e.distributorCode.toLowerCase().contains(q) ||
          e.issueDate.toLowerCase().contains(q);
    }).toList();
  }

  /// Total aggregation of issue count
  double get totalIssueCount =>
      _items.fold<double>(0.0, (sum, e) => sum + e.issueCount);

  bool get hasData => _items.isNotEmpty && _error == null;

  // ---- Public API ----

  /// Loads with the currently set filters.
  Future<void> load() async {
    if (_productId == null || _distributorId == null) {
      _setError('Please select product and distributor.');
      return;
    }
    await fetch(
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      productId: _productId!,
      distributorId: _distributorId!,
    );
  }

  /// Fetch with explicit filters (updates local state too).
  Future<void> fetch({
    required DateTime dateFrom,
    required DateTime dateTo,
    required int productId,
    required int distributorId, // maps to AGENT_ID in service
  }) async {
    _setLoading(true);
    _setError(null);

    // Update filters first so UI reflects them immediately
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    _productId = productId;
    _distributorId = distributorId;
    notifyListeners();

    try {
      final res = await _service.fetchIssues(
        productId: productId,
        agentId: distributorId, // IMPORTANT: distributorId -> agentId
        fromDate: dateFrom,
        toDate: dateTo,
      );
      _items = res.result;
      if (_items.isEmpty) {
        _setError('No records found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _items = const [];
      _setError('Failed to fetch issues: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---- Mutators for filters ----

  void setRange(DateTime from, DateTime to, {bool auto = false}) {
    _dateFrom = from;
    _dateTo = to.isBefore(from) ? from : to;
    notifyListeners();
    if (auto) load();
  }

  void setProduct(int? id, {bool auto = false}) {
    _productId = id;
    notifyListeners();
    if (auto) load();
  }

  void setDistributor(int? id, {bool auto = false}) {
    _distributorId = id;
    notifyListeners();
    if (auto) load();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  /// Clears only data and error (keeps filters)
  void clearData() {
    _items = const [];
    _error = null;
    notifyListeners();
  }

  /// Full reset (also clears filters)
  void reset() {
    final now = DateTime.now();
    _dateFrom = now.subtract(const Duration(days: 30));
    _dateTo   = now;
    _productId = null;
    _distributorId = null;
    _query = '';
    _items = const [];
    _error = null;
    notifyListeners();
  }


  // ---- internals ----
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
