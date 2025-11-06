// lib/features/reports/viewmodel/prize_search_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/prize_details_response.dart';
import '../service/prize_service.dart';

class PrizeSearchViewModel extends ChangeNotifier {
  PrizeSearchViewModel({PrizeService? service})
      : _service = service ?? PrizeService();

  final PrizeService _service;

  // UI state
  final TextEditingController slnoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<PrizeDetail> _results = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PrizeDetail> get results => _results;

  /// Trigger a search by SLNO.
  Future<void> search() async {
    final slno = slnoController.text.trim();
    if (slno.isEmpty) {
      _setError('Please enter SL No.');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final res = await _service.searchBySlno(slno);
      if (res == null) {
        _results = const [];
        _setError('No response from server.');
      } else {
        _results = res.result;
        if (_results.isEmpty) {
          _setError('No records found.');
        }
      }
    } catch (e) {
      _results = const [];
      _setError('Search failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearResults() {
    _results = const [];
    _errorMessage = null;
    notifyListeners();
  }

  void setSlno(String value) {
    slnoController.text = value;
    notifyListeners();
  }

  // --- internals ---
  void _setLoading(bool v) {
    if (_isLoading == v) return;
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void reset() {
    slnoController.clear();
    _results = const [];
    _errorMessage = null;
    _isLoading = false; // just in case
    notifyListeners();
  }


  @override
  void dispose() {
    slnoController.dispose();
    super.dispose();
  }
}
