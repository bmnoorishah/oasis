class Expense {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['userId'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
