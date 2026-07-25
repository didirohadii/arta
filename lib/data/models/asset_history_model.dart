class AssetHistoryModel {
  final DateTime date;
  final double amount;

  const AssetHistoryModel({required this.date, required this.amount});

  Map<String, dynamic> toMap() {
    return {"date": date.toIso8601String(), "amount": amount};
  }

  factory AssetHistoryModel.fromMap(Map<String, dynamic> map) {
    return AssetHistoryModel(
      date: DateTime.parse(map["date"]),
      amount: (map["amount"] as num).toDouble(),
    );
  }
}
