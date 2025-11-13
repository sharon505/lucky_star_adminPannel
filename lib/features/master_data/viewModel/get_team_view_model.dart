import 'package:flutter/foundation.dart';

import '../models/get_team_model.dart';
import '../services/get_team_service.dart';

class GetTeamViewModel extends ChangeNotifier {
  final GetTeamService _service;

  GetTeamViewModel({GetTeamService? service})
      : _service = service ?? GetTeamService();

  // --- State ---------------------------------------------------------------

  List<GetTeam> items = [];
  GetTeam? selected;

  bool isLoading = false;
  String? error;

  // --- Computed ------------------------------------------------------------

  int? get selectedTeamId => selected?.teamId;
  String? get selectedTeamName => selected?.teamName;

  bool get hasData => items.isNotEmpty;

  // --- Actions -------------------------------------------------------------

  Future<void> load({required int locationId, bool forceRefresh = false}) async {
    if (isLoading) return;
    if (!forceRefresh && items.isNotEmpty) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.fetch(locationId: locationId);
      items = result;

      // If nothing selected and we have items, default to first
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

  void select(GetTeam team) {
    selected = team;
    notifyListeners();
  }

  void selectById(int teamId) {
    try {
      final t = items.firstWhere((e) => e.teamId == teamId);
      selected = t;
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
