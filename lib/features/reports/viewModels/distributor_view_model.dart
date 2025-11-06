// lib/features/reports/viewmodel/distributor_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/distributor_models.dart';
import '../service/distributor_service.dart';

class DistributorViewModel extends ChangeNotifier {
  final DistributorService _service;

  // UI state
  bool _isLoading = false;
  String? _error;

  // Data
  List<DistributorItem> _items = const [];
  DistributorItem? _selected;

  // Optional search/filter text
  String _query = '';

  DistributorViewModel({DistributorService? service})
      : _service = service ?? DistributorService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DistributorItem> get items => _items;
  DistributorItem? get selected => _selected;

  String get query => _query;

  // Filtered view (by distributor name)
  List<DistributorItem> get filteredItems {
    if (_query.trim().isEmpty) return _items;
    final q = _query.toLowerCase();
    return _items.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  // Load distributors (GET by default; set usePost/asJson if needed)
  Future<void> load({bool usePost = false, bool asJson = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _service.fetchDistributors(
        usePost: usePost,
        asJson: asJson,
      );
      _items = res.result;

      // Optional: auto-select first item if nothing selected yet
      _selected ??= _items.isNotEmpty ? _items.first : null;

      if (_items.isEmpty) {
        _setError('No distributors found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _items = const [];
      _selected = null;
      _setError('Failed to load distributors: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Select a distributor
  void select(DistributorItem? item) {
    _selected = item;
    notifyListeners();
  }

  // Convenience: select by id
  void selectById(int id) {
    final found = _items.where((e) => e.distributorId == id);
    _selected = found.isNotEmpty ? found.first : null;
    notifyListeners();
  }

  // Set search query for filtering
  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  // Reset list/selection/errors (keeps service)
  void clear() {
    _items = const [];
    _selected = null;
    _error = null;
    _query = '';
    notifyListeners();
  }

  // Internals
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
