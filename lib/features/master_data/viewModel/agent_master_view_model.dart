import 'package:flutter/foundation.dart';

import '../models/agent_master_model.dart';
import '../services/agent_master_service.dart';

class AgentMasterViewModel extends ChangeNotifier {
  final AgentMasterService _service;

  AgentMasterViewModel({AgentMasterService? service})
      : _service = service ?? AgentMasterService();

  bool isSubmitting = false;
  String? errorMessage;

  AgentMasterResponse? lastResponse;

  // --------------------------------------------------------------------------
  // CREATE AGENT
  // --------------------------------------------------------------------------
  Future<bool> createAgent({
    required String name,
    required String code,
    required String address,
    required int locationId,
    required int teamId,
    required String phone,
    required String email,
    required String user,
  }) async {
    if (isSubmitting) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resp = await _service.createAgent(
        name: name,
        code: code,
        address: address,
        locationId: locationId,
        teamId: teamId,
        phone: phone,
        email: email,
        user: user,
      );

      lastResponse = resp;
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
