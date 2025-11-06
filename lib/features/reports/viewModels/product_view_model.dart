// lib/features/reports/viewmodel/product_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/product_models.dart';
import '../service/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _service;

  // UI state
  bool _isLoading = false;
  String? _error;

  // Data
  List<ProductItem> _items = const [];
  ProductItem? _selected;

  // Optional search/filter
  String _query = '';

  ProductViewModel({ProductService? service})
      : _service = service ?? ProductService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ProductItem> get items => _items;
  ProductItem? get selected => _selected;

  String get query => _query;

  // Filtered view (by name)
  List<ProductItem> get filteredItems {
    if (_query.trim().isEmpty) return _items;
    final q = _query.toLowerCase();
    return _items.where((p) => p.productName.toLowerCase().contains(q)).toList();
  }

  // Actions
  Future<void> load({bool usePost = false, bool asJson = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _service.fetchProducts(
        usePost: usePost,
        asJson: asJson,
      );
      _items = res.result;
      // If nothing selected yet, pick first (optional)
      _selected ??= _items.isNotEmpty ? _items.first : null;

      if (_items.isEmpty) {
        _setError('No products found.');
      } else {
        notifyListeners();
      }
    } catch (e) {
      _items = const [];
      _selected = null;
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  void select(ProductItem? item) {
    _selected = item;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

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
