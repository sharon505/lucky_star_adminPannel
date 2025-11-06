import 'package:flutter/foundation.dart';
import '../models/stock_summary_models.dart';
import '../service/stock_report_service.dart';

class StockReportViewModel extends ChangeNotifier {
  final StockReportService _service;

  // --- Filters ---
  DateTime _date;
  int _productId;

  // --- UI state ---
  bool _isLoading = false;
  String? _error;
  List<StockSummaryItem> _items = const [];

  StockReportViewModel({
    StockReportService? service,
    DateTime? initialDate,
    int initialProductId = 1,
  })  : _service = service ?? StockReportService(),
        _date = initialDate ?? DateTime.now(),
        _productId = initialProductId;

  // ---- Getters ----
  DateTime get date => _date;
  int get productId => _productId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StockSummaryItem> get items => _items;

  bool get hasData => _items.isNotEmpty && _error == null;

  // Optional aggregations
  int get totalStock => _items.fold<int>(0, (sum, e) => sum + e.stock);
  int get totalBalance => _items.fold<int>(0, (sum, e) => sum + e.balanceStock);

  // ---- Public API ----

  /// Load using the current filters.
  Future<void> load() async {
    await fetch(date: _date, productId: _productId);
  }

  /// Fetch with explicit filters (also updates the current filters).
  Future<void> fetch({required DateTime date, required int productId}) async {
    _setLoading(true);
    _setError(null);

    _date = date;
    _productId = productId;
    notifyListeners(); // so dependent UI (chips/filters) update immediately

    try {
      final res = await _service.fetchStockSummary(date: _date, productId: _productId);
      _items = res.result;
      if (_items.isEmpty) {
        _setError('No records found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _items = const [];
      _setError('Failed to fetch: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Change only the date (does not auto-fetch unless [auto] true).
  void setDate(DateTime d, {bool auto = false}) {
    _date = d;
    notifyListeners();
    if (auto) load();
  }

  /// Change only the product (does not auto-fetch unless [auto] true).
  void setProduct(int id, {bool auto = false}) {
    _productId = id;
    notifyListeners();
    if (auto) load();
  }

  /// Clear current data & error (keep filters).
  void clear() {
    _items = const [];
    _error = null;
    notifyListeners();
  }

  // ---- Internals ----
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
