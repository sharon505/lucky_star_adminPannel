import 'package:flutter/foundation.dart';

import '../models/agent_receivables_model.dart';
import '../services/agent_receivables_service.dart';

class AgentReceivablesViewModel extends ChangeNotifier {
  final AgentReceivablesService _service;

  // UI state
  bool _isLoading = false;
  String? _error;

  // Input selections (optional – handy if you want to persist)
  int? _agentId;
  int? _productId;

  // Data
  double? _amount; // receivable amount

  AgentReceivablesViewModel({AgentReceivablesService? service})
      : _service = service ?? AgentReceivablesService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  int? get agentId => _agentId;
  int? get productId => _productId;

  double? get amount => _amount;
  String get amountStr => (_amount ?? 0.0).toStringAsFixed(2);

  // Setters (selection)
  void setAgentId(int? id) {
    _agentId = id;
    notifyListeners();
  }

  void setProductId(int? id) {
    _productId = id;
    notifyListeners();
  }

  /// Main fetch
  Future<double> fetch({
    required int agentId,
    required int productId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final AgentReceivablesResponse res =
      await _service.fetch(agentId: agentId, productId: productId);

      final amt = res.result.isNotEmpty ? res.result.first.amount : 0.0;
      _amount = amt;

      // persist last selection (optional)
      _agentId = agentId;
      _productId = productId;

      notifyListeners();
      return amt;
    } catch (e) {
      _amount = null;
      _setError('Failed to load receivable: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Convenience: use stored selection (if both present)
  Future<double?> fetchForSelection() async {
    if (_agentId == null || _productId == null) return null;
    return fetch(agentId: _agentId!, productId: _productId!);
  }

  void clear() {
    _isLoading = false;
    _error = null;
    _agentId = null;
    _productId = null;
    _amount = null;
    notifyListeners();
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
