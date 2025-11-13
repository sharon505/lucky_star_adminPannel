import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/location_stock_issue_model.dart';
import '../services/location_stock_issue_service.dart';

class LocationStockIssueViewModel extends ChangeNotifier {
  final LocationStockIssueService _service;

  LocationStockIssueViewModel({LocationStockIssueService? service})
      : _service = service ?? LocationStockIssueService();

  // ---- Form state ----
  DateTime issueDate = DateTime.now();
  int? productId;
  int? locationId;
  int currentStock = 0;
  int? issueQuantity;
  String? user;

  // Editable controller for Issue Quantity
  final TextEditingController issueQtyCtrl =
  TextEditingController(text: '0');

  // ---- UI state ----
  bool isSubmitting = false;
  String? error;
  LocationStockIssueModel? lastResponse;

  // ---- Mutators ----

  void setIssueDate(DateTime d) {
    issueDate = DateTime(d.year, d.month, d.day);
    notifyListeners();
  }

  void setProduct(int id) {
    productId = id;
    notifyListeners();
  }

  void setLocation(int id) {
    locationId = id;
    notifyListeners();
  }

  void setCurrentStock(int value) {
    currentStock = value;
    notifyListeners();
  }

  void setUser(String u) {
    user = u.trim();
    notifyListeners();
  }

  /// Parse from user input without rewriting the controller
  void setIssueQuantityFromString(String raw) {
    issueQuantity = int.tryParse(raw.trim());
    notifyListeners();
  }

  /// Explicit setter (used if you already have the value as int)
  void setIssueQuantity(int value) {
    issueQuantity = value;
    issueQtyCtrl.text = value.toString();
    notifyListeners();
  }

  /// Setup initial state (optional, call from dialog before show)
  void bootstrap({
    DateTime? initialDate,
    int? initialProductId,
    int? initialLocationId,
    int? initialCurrentStock,
    int? initialIssueQuantity,
    String? initialUser,
  }) {
    issueDate = initialDate ?? DateTime.now();
    productId = initialProductId ?? productId;
    locationId = initialLocationId ?? locationId;
    currentStock = initialCurrentStock ?? currentStock;
    issueQuantity = initialIssueQuantity ?? issueQuantity ?? 0;
    user = (initialUser ?? user)?.trim();

    issueQtyCtrl.text = (issueQuantity ?? 0).toString();

    error = null;
    notifyListeners();
  }

  String? _validate() {
    if (locationId == null) return 'Please select a location.';
    if (productId == null) return 'Please select a product.';
    if (user == null || user!.isEmpty) return 'User is required.';

    final q = issueQuantity ?? int.tryParse(issueQtyCtrl.text.trim()) ?? 0;
    if (q <= 0) return 'Issue quantity must be greater than zero.';

    if (currentStock > 0 && q > currentStock) {
      return 'Cannot issue more than current stock.';
    }

    return null;
  }

  Future<LocationStockIssueModel?> submit() async {
    error = _validate();
    if (error != null) {
      notifyListeners();
      return null;
    }

    try {
      isSubmitting = true;
      notifyListeners();

      final qty = issueQuantity ?? int.tryParse(issueQtyCtrl.text.trim()) ?? 0;

      final resp = await _service.submit(
        issueDate: issueDate,
        productId: productId!,
        currentStock: currentStock,
        issueQuantity: qty,
        locationId: locationId!,
        user: user!,
      );

      lastResponse = resp;
      isSubmitting = false;

      // keep controller synced with parsed value
      issueQtyCtrl.text = qty.toString();

      notifyListeners();
      return resp;
    } catch (e) {
      isSubmitting = false;
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  bool get hasSuccessResponse => lastResponse != null;

  void clearError() {
    error = null;
    notifyListeners();
  }

  void reset() {
    issueDate = DateTime.now();
    productId = null;
    locationId = null;
    currentStock = 0;
    issueQuantity = 0;
    user = null;
    issueQtyCtrl.text = '0';
    error = null;
    lastResponse = null;
    isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    issueQtyCtrl.dispose();
    _service.dispose();
    super.dispose();
  }
}
