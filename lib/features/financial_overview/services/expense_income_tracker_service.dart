// lib/features/financial_overview/services/expense_income_tracker_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/expense_Income_tracker.dart'; // CashBookResponse / CashBookItem

class ExpenseIncomeTrackerService {
  final http.Client _client;
  final Duration timeout;

  ExpenseIncomeTrackerService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Fetch journal entries between [from]..[to] for a given [group].
  /// group examples: 'expense' / 'expence' / 'income' / 'asset' / 'liability'
  Future<CashBookResponse> fetchRange({
    required DateTime from,
    required DateTime to,
    required String group,
  }) async {
    final res = await _client
        .post(
      ApiEndpoints.expenseIncomeTracker, // static final Uri expenseIncomeTracker = _u('USP_GETJOURNALENTRYREPORT');
      headers: ApiEndpoints.formHeaders,
      body: {
        'FROM_DATE': _fmtDate(from),
        'TO_DATE': _fmtDate(to),
        'GROUP': _normalizeGroup(group), // e.g., 'EXPENSE'
      },
    )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('USP_GETJOURNALENTRYREPORT failed (${res.statusCode}): ${res.body}');
    }

    final Map<String, dynamic> decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return CashBookResponse.fromJson(decoded);
  }

  /// Convenience if you just want the list of rows.
  Future<List<CashBookItem>> fetchRangeItems({
    required DateTime from,
    required DateTime to,
    required String group,
  }) async {
    final r = await fetchRange(from: from, to: to, group: group);
    return r.items;
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  /// Normalize common spellings and casing. Defaults to upper-cased input.
  String _normalizeGroup(String g) {
    final s = (g).trim().toLowerCase();
    if (s.startsWith('exp')) return 'EXPENSE'; // handles 'expense', 'expence'
    if (s == 'income' || s == 'incomes') return 'INCOME';
    if (s == 'asset' || s == 'assets') return 'ASSET';
    if (s == 'liability' || s == 'liabilities') return 'LIABILITY';
    return s.toUpperCase();
  }

  void dispose() {
    _client.close();
  }
}
