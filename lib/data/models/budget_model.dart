class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final int month;
  final int year;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "amount": amount,
      "month": month,
      "year": year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map["id"],
      category: map["category"],
      amount: (map["amount"] as num).toDouble(),
      month: map["month"],
      year: map["year"],
    );
  }
}
