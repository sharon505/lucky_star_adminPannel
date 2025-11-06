// lib/features/reports/viewModels/current_stock_by_agent_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/agent_stock_summary_models.dart';
import '../service/current_stock_by_agent_service.dart';

/// ViewModel for "Current Stock By Agent" (REPORT_STOCK_BALANCE_OF_DISTRIBUTOR)
class CurrentStockByAgentViewModel extends ChangeNotifier {
  final CurrentStockByAgentService _service;

  // ---- Filters ----
  int? _productId;   // required before fetch
  int _agentId = 0;  // 0 = ALL (backend convention)

  // ---- UI state ----
  bool _isLoading = false;
  String? _error;

  // ---- Data ----
  List<AgentStockSummaryItem> _items = const [];

  // ---- Optional local search filter (by name/product) ----
  String _query = '';

  CurrentStockByAgentViewModel({CurrentStockByAgentService? service})
      : _service = service ?? CurrentStockByAgentService();

  // ---- Getters ----
  int? get productId => _productId;
  int get agentId => _agentId;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AgentStockSummaryItem> get items => _items;

  String get query => _query;

  /// Client-side filtered items by query
  List<AgentStockSummaryItem> get filteredItems {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((e) {
      return e.productName.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q);
    }).toList();
  }

  // ---- Aggregations ----
  double get totalIssued =>
      _items.fold<double>(0.0, (sum, e) => sum + e.issued);
  double get totalSale =>
      _items.fold<double>(0.0, (sum, e) => sum + e.sale);
  double get totalBalance =>
      _items.fold<double>(0.0, (sum, e) => sum + e.balanceStock);

  bool get hasData => _items.isNotEmpty && _error == null;

  // ---- Public API ----

  /// Fetch using current filters (requires productId to be set).
  Future<void> load() async {
    if (_productId == null) {
      _setError('Please select a product.');
      return;
    }
    await fetch(productId: _productId!, agentId: _agentId);
  }

  /// Fetch with explicit filters (also updates internal filters).
  Future<void> fetch({required int productId, required int agentId}) async {
    _setLoading(true);
    _setError(null);

    // Update local filters first
    _productId = productId;
    _agentId = agentId;
    notifyListeners();

    try {
      final json = await _service.fetch(
        productId: productId,
        agentId: agentId,
        asJson: false, // using form-url-encoded by default
      );

      final resp = AgentStockSummaryResponse.fromJson(json);
      _items = resp.result;

      if (_items.isEmpty) {
        _setError('No records found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _items = const [];
      _setError('Failed to fetch current stock: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---- Mutators ----

  void setProduct(int? id, {bool auto = false}) {
    _productId = id;
    notifyListeners();
    if (auto && id != null) load();
  }

  void setAgent(int id, {bool auto = false}) {
    _agentId = id; // 0 = ALL
    notifyListeners();
    if (auto && _productId != null) load();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  /// Clears table data & error, keeps filters
  void clearData() {
    _items = const [];
    _error = null;
    notifyListeners();
  }

  /// Full reset (clears filters and data)
  void reset() {
    _productId = null;
    _agentId = 0;
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
