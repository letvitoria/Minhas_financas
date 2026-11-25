import 'package:flutter_test/flutter_test.dart';
import 'package:grana_jovem/data/models/finance_models.dart';

void main() {
  test('FinanceTransaction lê metadata JSONB', () {
    final transaction = FinanceTransaction.fromMap({
      'id': '00000000-0000-0000-0000-000000000001',
      'title': 'Mercado',
      'type': 'expense',
      'category': 'Alimentação',
      'amount': 150,
      'occurred_on': '2026-11-24',
      'metadata': {
        'tags': ['mercado', 'semanal'],
        'location': 'Supermercado X',
      },
    });

    expect(transaction.amount, 150);
    expect(transaction.metadata['location'], 'Supermercado X');
    expect(transaction.metadata['tags'], ['mercado', 'semanal']);
  });

  test('WishlistGoal calcula progresso limitado', () {
    const goal = WishlistGoal(
      id: '00000000-0000-0000-0000-000000000002',
      title: 'Viagem',
      targetAmount: 1000,
      savedAmount: 250,
    );

    expect(goal.progress, 0.25);
  });
}
