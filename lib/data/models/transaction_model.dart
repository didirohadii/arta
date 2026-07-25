import 'dart:convert';

enum TransactionType { income, expense, transfer }

class TransactionModel {
  final String id;
  final TransactionType type;
  final String title;
  final double amount;
  final DateTime date;
  final String? sourceWalletId;
  final String? destinationWalletId;
  final String category;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.sourceWalletId,
    this.destinationWalletId,
    required this.category,
    this.note,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type.name,
      "title": title,
      "amount": amount,
      "date": date.toIso8601String(),
      "sourceWalletId": sourceWalletId,
      "destinationWalletId": destinationWalletId,
      "category": category,
      "note": note,
    };
  }

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map["id"],
      type: TransactionType.values.firstWhere((e) => e.name == map["type"]),
      title: map["title"],
      amount: (map["amount"] as num).toDouble(),
      date: DateTime.parse(map["date"]),
      sourceWalletId: map["sourceWalletId"],
      destinationWalletId: map["destinationWalletId"],
      category: map["category"],
      note: map["note"],
    );
  }

  String encode() => jsonEncode(toMap());

  factory TransactionModel.decode(String source) =>
      TransactionModel.fromMap(jsonDecode(source));
}
