// lib/features/financial_overview/viewModels/dashboard_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/stock_summary_model.dart';
import '../service/dashboard_service.dart';

class DashboardViewModel with ChangeNotifier {
  final DashboardService _service;

  DashboardViewModel({DashboardService? service})
      : _service = service ?? DashboardService();

  // ---- State ----
  bool _isLoading = false;
  String? _error;
  StockSummaryResponse? _data;

  // ---- Getters ----
  bool get isLoading => _isLoading;
  String? get error => _error;
  StockSummaryResponse? get data => _data;

  // Individual convenience getters
  double get totalStock => _data?.result.totalStock ?? 0.0;
  double get issuedStock => _data?.data.issuedStock ?? 0.0;
  double get currentStock => _data?.table2.currentStock ?? 0.0;
  double get todaysSaleCount => _data?.table3.todaysSaleCount ?? 0.0;
  double get todaysSaleValue => _data?.table4.todaysSaleValue ?? 0.0;
  double get todaysPrizedCount => _data?.table5.todaysPrizedCount ?? 0.0;
  double get todaysPrizedPayout => _data?.table6.todaysPrizedPayout ?? 0.0;

  // ---- Actions ----
  Future<void> fetch() async {
    _setLoading(true);
    _error = null;

    try {
      final resp = await _service.fetch();
      _data = resp;
    } catch (e) {
      _error = e.toString();
      _data = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async => fetch();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
