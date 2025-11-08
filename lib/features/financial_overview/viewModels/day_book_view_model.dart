// lib/features/reports/viewModels/day_book_view_model.dart
import 'package:flutter/foundation.dart';

import '../models/day_book_models.dart';
import '../services/day_book_service.dart';

class DayBookViewModel with ChangeNotifier {
  final DayBookService _service;

  DayBookViewModel({DayBookService? service})
      : _service = service ?? DayBookService();

  // ---- State ----
  bool _isLoading = false;
  String? _error;
  List<DayBookItem> _items = [];

  // ---- Current filter ----
  DateTime? _date;

  // ---- Getters ----
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DayBookItem> get items => _items;
  DateTime? get date => _date;

  double get totalDebit =>
      _items.fold<double>(0.0, (s, e) => s + e.debit);

  double get totalCredit =>
      _items.fold<double>(0.0, (s, e) => s + e.credit);

  double get net => totalDebit - totalCredit;

  // ---- Actions ----
  Future<void> fetch({required DateTime date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _date = DateTime(date.year, date.month, date.day);

      final data = await _service.fetch(date: _date!);

      // Keep server order, or sort by time/description if needed.
      // Example sort: by description ASC, then debit DESC
      // data.sort((a, b) {
      //   final byDesc = a.description.toLowerCase().compareTo(b.description.toLowerCase());
      //   if (byDesc != 0) return byDesc;
      //   return b.debit.compareTo(a.debit);
      // });

      _items = data;
    } catch (e) {
      _items = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_date == null) {
      _error = 'Select a date first.';
      notifyListeners();
      return;
    }
    await fetch(date: _date!);
  }

  /// Convenience: load today's day-book.
  Future<void> autoBootstrap() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await fetch(date: today);
  }

  void setDate(DateTime d, {bool fetchNow = false}) {
    _date = DateTime(d.year, d.month, d.day);
    notifyListeners();
    if (fetchNow) {
      fetch(date: _date!);
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
