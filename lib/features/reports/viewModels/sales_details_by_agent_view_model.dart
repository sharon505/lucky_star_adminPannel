// lib/features/reports/viewModels/sales_details_by_agent_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/agent_stock_sale_models.dart';
import '../service/sales_details_by_agent_service.dart';

class SalesDetailsByAgentViewModel with ChangeNotifier {
  final SalesDetailsByAgentService _service;
  SalesDetailsByAgentViewModel({SalesDetailsByAgentService? service})
      : _service = service ?? SalesDetailsByAgentService();

  bool _isLoading = false;
  String? _error;
  List<StockSaleItem> _items = [];

  DateTime? _fromDate;
  DateTime? _toDate;
  int? _productId;
  int? _agentId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StockSaleItem> get items => _items;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get productId => _productId;
  int? get agentId => _agentId;

  double get totalStockSale =>
      _items.fold<double>(0, (s, e) => s + e.stockSale);

  Future<void> fetch({
    required DateTime fromDate,
    required DateTime toDate,
    required int productId,
    required int agentId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fromDate = fromDate;
      _toDate = toDate;
      _productId = productId;
      _agentId = agentId;

      final data = await _service.fetch(
        fromDate: fromDate,
        toDate: toDate,
        productId: productId,
        agentId: agentId,
      );

      data.sort((a, b) {
        final d = b.date.compareTo(a.date);
        if (d != 0) return d;
        final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        if (n != 0) return n;
        return a.sn.compareTo(b.sn);
      });

      _items = data;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call after providers are ready to auto-load
  Future<void> autoBootstrap({
    required int productId,
    required int agentId,
    int daysBack = 1,
  }) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final from = startOfToday.subtract(Duration(days: daysBack));
    final to = startOfToday;
    await fetch(fromDate: from, toDate: to, productId: productId, agentId: agentId);
  }

  Future<void> refresh() async {
    if (_fromDate == null || _toDate == null || _productId == null || _agentId == null) {
      _error = 'Missing filters: set date range, product and agent first.';
      notifyListeners();
      return;
    }
    await fetch(
      fromDate: _fromDate!,
      toDate: _toDate!,
      productId: _productId!,
      agentId: _agentId!,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
