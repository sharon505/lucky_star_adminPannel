// lib/features/reports/viewModels/cash_collection_by_agent_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/cash_received_by_agent_models.dart';
import '../service/cash_collection_by_agent_service.dart';

class CashCollectionByAgentViewModel with ChangeNotifier {
  final CashCollectionByAgentService _service;

  CashCollectionByAgentViewModel({
    CashCollectionByAgentService? service,
  }) : _service = service ?? CashCollectionByAgentService();

  // ---- State ----
  bool _isLoading = false;
  String? _error;
  List<CashReceivedItem> _items = [];

  // ---- Current filters (remember last successful fetch) ----
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _agentId;    // 0 => ALL (if backend supports)
  int? _productId;

  // ---- Getters ----
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CashReceivedItem> get items => _items;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get agentId => _agentId;
  int? get productId => _productId;

  double get totalReceived =>
      _items.fold<double>(0, (s, e) => s + e.receivedAmt);

  // ---- Actions ----
  Future<void> fetch({
    required DateTime fromDate,
    required DateTime toDate,
    required int agentId,
    required int productId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fromDate = fromDate;
      _toDate = toDate;
      _agentId = agentId;
      _productId = productId;

      final data = await _service.fetch(
        fromDate: fromDate,
        toDate: toDate,
        agentId: agentId,
        productId: productId,
      );

      // Sort: newest date first, then name ASC, then SN ASC
      data.sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        final byName =
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
        if (byName != 0) return byName;
        return a.sn.compareTo(b.sn);
      });

      _items = data;
    } catch (e) {
      _items = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-run the last successful query.
  Future<void> refresh() async {
    if (_fromDate == null ||
        _toDate == null ||
        _agentId == null ||
        _productId == null) {
      _error =
      'Missing filters: set From/To Date, Product and Agent first.';
      notifyListeners();
      return;
    }
    await fetch(
      fromDate: _fromDate!,
      toDate: _toDate!,
      agentId: _agentId!,
      productId: _productId!,
    );
  }

  /// Convenience bootstrapping: fetch last [daysBack] days, ALL agent (0), first product, etc.
  /// Call this from your screen after products/agents lists are loaded.
  Future<void> autoBootstrap({
    required int productId,
    int agentId = 0, // 0 => ALL if backend accepts it
    int daysBack = 1,
  }) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final from = startOfToday.subtract(Duration(days: daysBack));
    final to = startOfToday;
    await fetch(
      fromDate: from,
      toDate: to,
      agentId: agentId,
      productId: productId,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
