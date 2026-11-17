import 'package:flutter/foundation.dart';

import '../data/models/finance_models.dart';
import '../data/repositories/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  FinanceProvider(this._repository);
  final FinanceRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<FinanceTransaction> transactions = [];
  List<Bill> bills = [];
  List<IncomeSource> incomes = [];
  List<InvestmentPosition> investments = [];
  List<WishlistGoal> goals = [];

  double get incomeTotal => incomes.fold(0, (sum, item) => sum + item.amount);
  double get expenseTotal => transactions.where((item) => item.type == 'expense').fold(0, (sum, item) => sum + item.amount);
  double get investmentTotal => investments.fold(0, (sum, item) => sum + item.amount);
  double get availableBalance => incomeTotal - expenseTotal - investmentTotal;
  double get totalOutflow => expenseTotal + investmentTotal;
  double get pendingBills => bills.where((bill) => !bill.isPaid).fold(0, (sum, bill) => sum + bill.amount);

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getTransactions(), _repository.getBills(), _repository.getIncomeSources(),
        _repository.getInvestments(), _repository.getWishlist(),
      ]);
      transactions = results[0].map((row) => FinanceTransaction.fromMap(row)).toList();
      bills = results[1].map((row) => Bill.fromMap(row)).toList();
      incomes = results[2].map((row) => IncomeSource.fromMap(row)).toList();
      investments = results[3].map((row) => InvestmentPosition.fromMap(row)).toList();
      goals = results[4].map((row) => WishlistGoal.fromMap(row)).toList();
    } catch (error) {
      errorMessage = 'Não foi possível carregar seus dados. Verifique a conexão e o schema do Supabase.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBill({required String title, required double amount, required DateTime dueDate, required String recurrence}) async {
    await _repository.addBill(title: title, amount: amount, dueDate: dueDate, recurrence: recurrence);
    await refresh();
  }

  Future<void> addIncome({required String title, required double amount, required String frequency, required DateTime receivedOn}) async {
    await _repository.addIncome(title: title, amount: amount, frequency: frequency, receivedOn: receivedOn);
    await refresh();
  }

  Future<void> addExpense({required String title, required double amount, required String category, required DateTime date}) async {
    await _repository.addExpense(title: title, amount: amount, category: category, date: date);
    await refresh();
  }

  Future<void> addInvestment({required String title, required String category, required double amount}) async {
    await _repository.addInvestment(title: title, category: category, amount: amount);
    await refresh();
  }

  Future<void> addGoal({required String title, required double targetAmount, required DateTime? targetDate}) async {
    await _repository.addGoal(title: title, targetAmount: targetAmount, targetDate: targetDate);
    await refresh();
  }

  Future<void> addToGoal(WishlistGoal goal, double amount) async {
    await _repository.addToGoal(goal.id, amount, goal.savedAmount, goal.targetAmount);
    await refresh();
  }

  Future<void> toggleBill(Bill bill) async {
    await _repository.toggleBillPaid(bill.id, !bill.isPaid);
    await refresh();
  }
}
