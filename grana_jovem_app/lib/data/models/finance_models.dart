class FinanceTransaction {
  const FinanceTransaction({required this.id, required this.title, required this.type, required this.category, required this.amount, required this.occurredOn});
  final String id;
  final String title;
  final String type;
  final String category;
  final double amount;
  final DateTime occurredOn;

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) => FinanceTransaction(
    id: map['id'] as String,
    title: map['title'] as String,
    type: map['type'] as String,
    category: (map['category'] ?? 'Geral') as String,
    amount: (map['amount'] as num).toDouble(),
    occurredOn: DateTime.parse(map['occurred_on'] as String),
  );
}

class Bill {
  const Bill({required this.id, required this.title, required this.amount, required this.dueDate, required this.recurrence, required this.isPaid});
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String recurrence;
  final bool isPaid;

  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
    id: map['id'] as String,
    title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(),
    dueDate: DateTime.parse(map['due_date'] as String),
    recurrence: map['recurrence'] as String,
    isPaid: map['is_paid'] as bool,
  );
}

class IncomeSource {
  const IncomeSource({required this.id, required this.title, required this.amount, required this.frequency, required this.receivedOn});
  final String id;
  final String title;
  final double amount;
  final String frequency;
  final DateTime receivedOn;

  factory IncomeSource.fromMap(Map<String, dynamic> map) => IncomeSource(
    id: map['id'] as String,
    title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(),
    frequency: map['frequency'] as String,
    receivedOn: DateTime.parse(map['received_on'] as String),
  );
}

class InvestmentPosition {
  const InvestmentPosition({required this.id, required this.title, required this.category, required this.amount});
  final String id;
  final String title;
  final String category;
  final double amount;

  factory InvestmentPosition.fromMap(Map<String, dynamic> map) => InvestmentPosition(
    id: map['id'] as String,
    title: map['title'] as String,
    category: map['category'] as String,
    amount: (map['amount'] as num).toDouble(),
  );
}

class WishlistGoal {
  const WishlistGoal({required this.id, required this.title, required this.targetAmount, required this.savedAmount, this.targetDate});
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;

  double get progress => targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1).toDouble();

  factory WishlistGoal.fromMap(Map<String, dynamic> map) => WishlistGoal(
    id: map['id'] as String,
    title: map['title'] as String,
    targetAmount: (map['target_amount'] as num).toDouble(),
    savedAmount: (map['saved_amount'] as num).toDouble(),
    targetDate: map['target_date'] == null ? null : DateTime.parse(map['target_date'] as String),
  );
}
