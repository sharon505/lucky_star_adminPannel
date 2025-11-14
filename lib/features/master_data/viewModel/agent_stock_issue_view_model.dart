// lib/features/master_data/viewModel/agent_stock_issue_view_model.dart

import 'package:flutter/foundation.dart';

import '../services/agent_stock_issue_service.dart';
import '../models/agent_stock_Issue_response_model.dart';

class AgentIssueViewModel extends ChangeNotifier {
  final AgentStockIssueService _service;

  AgentIssueViewModel({AgentStockIssueService? service})
      : _service = service ?? AgentStockIssueService();

  bool _isSubmitting = false;
  String? _errorMessage;
  AgentStockIssueResponse? _lastResponse;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  AgentStockIssueResponse? get lastResponse => _lastResponse;

  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  /// Submit a new Agent Stock Issue
  ///
  /// teamCode    -> "JEBEL ALI"
  /// agent       -> "JEBEL ALI 1"
  /// product     -> "LUCKY STAR CARD"
  Future<AgentStockIssueResponse?> submitIssue({
    required String issueDate,
    required num currentStock,
    required String teamCode,
    required String agent,
    required String product,
    required int issueQuantity,
    required String user,
    required int locationId,
  }) async {
    if (_isSubmitting) return null;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _service.issueStock(
        issueDate: issueDate,
        currentStock: currentStock,
        teamCode: teamCode,
        agent: agent,
        product: product,
        issueQuantity: issueQuantity,
        user: user,
        locationId: locationId,
      );

      _lastResponse = resp;
      return resp;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void resetState() {
    _errorMessage = null;
    _lastResponse = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
