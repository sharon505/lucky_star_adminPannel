import 'package:flutter/foundation.dart';

import '../models/agent_model.dart';
import '../services/get_team_agent_service.dart';

class TeamAgentViewModel extends ChangeNotifier {
  final GetTeamAgentService _service;

  TeamAgentViewModel({GetTeamAgentService? service})
      : _service = service ?? GetTeamAgentService();

  // --- State ---------------------------------------------------------------

  List<AgentModel> items = [];
  AgentModel? selected;

  bool isLoading = false;
  String? error;

  // --- Computed ------------------------------------------------------------

  int? get selectedDisId => selected?.disId;
  String? get selectedName => selected?.name;
  String? get selectedCode => selected?.code;

  bool get hasData => items.isNotEmpty;

  // --- Actions -------------------------------------------------------------

  Future<void> load({required int teamId, bool forceRefresh = false}) async {
    if (isLoading) return;
    if (!forceRefresh && items.isNotEmpty) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.fetch(teamId: teamId);
      items = result;

      // Default to first agent if nothing selected
      if (selected == null && items.isNotEmpty) {
        selected = items.first;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  void select(AgentModel agent) {
    selected = agent;
    notifyListeners();
  }

  void selectByDisId(int disId) {
    try {
      final a = items.firstWhere((e) => e.disId == disId);
      selected = a;
      notifyListeners();
    } catch (_) {
      // ignore if not found
    }
  }

  void clearSelection() {
    selected = null;
    notifyListeners();
  }

  void reset() {
    items = [];
    selected = null;
    isLoading = false;
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
