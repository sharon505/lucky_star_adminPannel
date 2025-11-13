// lib/features/financial_overview/viewModels/agent_collection_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/agent_collection_model.dart';
import '../services/agent_collection_service.dart';

class AgentCollectionViewModel extends ChangeNotifier {
  final AgentCollectionService _service;

  AgentCollectionViewModel({AgentCollectionService? service})
      : _service = service ?? AgentCollectionService();

  // ---- Form state ----
  DateTime date = DateTime.now();
  int? productId;
  int? agentId;
  num? amount;
  String? user;

  // Editable controller for the Amount field
  final TextEditingController amountCtrl = TextEditingController(text: '0.00');

  // ---- UI state ----
  bool isSubmitting = false;
  String? error;
  AgentCollectionResponse? lastResponse;

  // ---- Mutators ----
  void setDate(DateTime d) {
    date = DateTime(d.year, d.month, d.day);
    notifyListeners();
  }

  void setProduct(int id) {
    productId = id;
    notifyListeners();
  }

  void setAgent(int id) {
    agentId = id;
    notifyListeners();
  }

  void setUser(String u) {
    user = u.trim();
    notifyListeners();
  }

  /// IMPORTANT: Do NOT rewrite the controller while the user is typing.
  /// Just parse/store. This prevents the cursor jump / blocking issue.
  void setAmountFromString(String raw) {
    amount = num.tryParse(raw.trim());
    // No amountCtrl.text rewrite here!
    notifyListeners();
  }

  /// Use when you intentionally want to format (e.g., after submit).
  void setAmount(num v) {
    amount = v;
    amountCtrl.text = v.toStringAsFixed(2);
    notifyListeners();
  }

  void bootstrap({
    DateTime? initialDate,
    int? initialProductId,
    int? initialAgentId,
    num? initialAmount,
    String? initialUser,
  }) {
    date = initialDate ?? DateTime.now();
    productId = initialProductId ?? productId;
    agentId = initialAgentId ?? agentId;
    amount = initialAmount ?? amount ?? 0;
    user = (initialUser ?? user)?.trim();
    amountCtrl.text = (amount ?? 0).toStringAsFixed(2);
    error = null;
    notifyListeners();
  }

  String? _validate() {
    if (productId == null) return 'Please select a product.';
    if (agentId == null) return 'Please select an agent.';
    if (user == null || user!.isEmpty) return 'User is required.';
    final a = amount ?? num.tryParse(amountCtrl.text.trim()) ?? 0;
    if (a <= 0) return 'Amount must be greater than zero.';
    return null;
  }

  Future<AgentCollectionModel?> submit() async {
    error = _validate();
    if (error != null) {
      notifyListeners();
      return null;
    }

    try {
      isSubmitting = true;
      notifyListeners();

      final resp = await _service.submit(
        date: date,
        productId: productId!,
        agentId: agentId!,
        amount: amount ?? num.tryParse(amountCtrl.text.trim()) ?? 0,
        user: user!,
      );

      lastResponse = resp;
      isSubmitting = false;

      // Optional: pretty-format after a successful round-trip
      final a = amount ?? num.tryParse(amountCtrl.text.trim());
      if (a != null) {
        amountCtrl.text = a.toStringAsFixed(2);
      }

      notifyListeners();
      return resp.result.isNotEmpty ? resp.result.first : null;
    } catch (e) {
      isSubmitting = false;
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  bool get isSuccess =>
      (lastResponse?.result.isNotEmpty == true) &&
          (lastResponse!.result.first.statusId == 1);

  void clearError() {
    error = null;
    notifyListeners();
  }

  void reset() {
    date = DateTime.now();
    productId = null;
    agentId = null;
    amount = 0;
    user = null;
    amountCtrl.text = '0.00';
    error = null;
    lastResponse = null;
    isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    _service.dispose();
    super.dispose();
  }
}
