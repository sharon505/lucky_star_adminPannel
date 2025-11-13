import 'package:flutter/foundation.dart';

import '../models/get_location_model.dart';
import '../services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _service;

  LocationViewModel({LocationService? service})
      : _service = service ?? LocationService();

  // ---- Data state ----
  List<GetLocation> items = [];
  int? selectedLocationId; // e.g. 0 for "ALL"

  // ---- UI state ----
  bool isLoading = false;
  String? error;

  // ---- Mutators ----

  /// Optional bootstrap, e.g. call from initState or parent VM
  Future<void> bootstrap({bool selectAllIfAvailable = true}) async {
    error = null;
    notifyListeners();

    await load();

    if (selectAllIfAvailable && items.isNotEmpty) {
      final allItem = items.firstWhere(
            (e) => e.locationId == 0 || e.locationName.toUpperCase() == 'ALL',
        orElse: () => items.first,
      );
      selectedLocationId = allItem.locationId;
      notifyListeners();
    }
  }

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _service.fetchAll();
      items = res;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setLocation(int id) {
    selectedLocationId = id;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void reset() {
    items = [];
    selectedLocationId = null;
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
