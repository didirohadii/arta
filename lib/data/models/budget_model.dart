class BudgetModel {
  final String id;
  final String category;
  final double amount;

  /// Periode budget
  final DateTime startDate;
  final DateTime endDate;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "amount": amount,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map["id"],
      category: map["category"],
      amount: (map["amount"] as num).toDouble(),
      startDate: DateTime.parse(map["startDate"]),
      endDate: DateTime.parse(map["endDate"]),
    );
  }
}
