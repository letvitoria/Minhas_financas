import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceRepository {
  FinanceRepository(this._client);
  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Sessão expirada. Entre novamente.');
    return id;
  }

  Future<List<Map<String, dynamic>>> _list(String table, String orderBy, {bool ascending = false}) async {
    final rows = await _client.from(table).select().eq('user_id', _userId).order(orderBy, ascending: ascending);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> getTransactions() => _list('transactions', 'occurred_on');
  Future<List<Map<String, dynamic>>> getBills() => _list('bills', 'due_date', ascending: true);
  Future<List<Map<String, dynamic>>> getIncomeSources() => _list('income_sources', 'received_on');
  Future<List<Map<String, dynamic>>> getInvestments() => _list('investments', 'created_at');
  Future<List<Map<String, dynamic>>> getWishlist() => _list('wishlist_goals', 'created_at');

  Future<void> addBill({required String title, required double amount, required DateTime dueDate, required String recurrence}) async {
    await _client.from('bills').insert({
      'user_id': _userId, 'title': title, 'amount': amount,
      'due_date': _date(dueDate), 'recurrence': recurrence,
    });
  }

  Future<void> addIncome({required String title, required double amount, required String frequency, required DateTime receivedOn}) async {
    await _client.from('income_sources').insert({
      'user_id': _userId, 'title': title, 'amount': amount,
      'frequency': frequency, 'received_on': _date(receivedOn),
    });
  }

  Future<void> addExpense({required String title, required double amount, required String category, required DateTime date}) async {
    await _client.from('transactions').insert({
      'user_id': _userId, 'title': title, 'type': 'expense', 'category': category,
      'amount': amount, 'occurred_on': _date(date),
    });
  }

  Future<void> addInvestment({required String title, required String category, required double amount}) async {
    await _client.from('investments').insert({'user_id': _userId, 'title': title, 'category': category, 'amount': amount});
  }

  Future<void> addGoal({required String title, required double targetAmount, required DateTime? targetDate}) async {
    await _client.from('wishlist_goals').insert({
      'user_id': _userId, 'title': title, 'target_amount': targetAmount,
      'saved_amount': 0, 'target_date': targetDate == null ? null : _date(targetDate),
    });
  }

  Future<void> addToGoal(String id, double amount, double currentSaved, double target) async {
    final updated = currentSaved + amount;
    if (updated > target) throw const PostgrestException(message: 'O valor ultrapassa a meta.');
    await _client.from('wishlist_goals').update({'saved_amount': updated}).eq('id', id).eq('user_id', _userId);
  }

  Future<void> toggleBillPaid(String id, bool isPaid) async {
    await _client.from('bills').update({'is_paid': isPaid}).eq('id', id).eq('user_id', _userId);
  }

  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
