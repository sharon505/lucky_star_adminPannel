import 'package:flutter/foundation.dart';

import '../models/get_current_stock_model.dart';
import '../services/current_stock_service.dart';

class CurrentStockViewModel extends ChangeNotifier {
  final CurrentStockService _service;

  CurrentStockViewModel({CurrentStockService? service})
      : _service = service ?? CurrentStockService();

  // ---- Data state ----
  GetCurrentStockModel? lastResponse;
  int currentStock = 0; // recptQnty
  String? lastProduct;

  // ---- UI state ----
  bool isLoading = false;
  String? error;

  // ---- Actions ----

  /// Fetch current stock for a given product name.
  Future<void> fetch({required String product}) async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _service.fetch(product: product);
      lastResponse = res;
      currentStock = res.recptQnty;
      lastProduct = product;
    } catch (e) {
      error = e.toString();
      currentStock = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    lastResponse = null;
    currentStock = 0;
    lastProduct = null;
    isLoading = false;
    error = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
