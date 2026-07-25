import 'dart:convert';

enum SavingTargetUnit { money, gold }

class SavingTargetModel {
  final String id;
  final String title;

  /// target rupiah / gram
  final double targetAmount;

  /// wallet yang dihitung
  final List<String> walletIds;

  /// uang / emas
  final SavingTargetUnit unit;

  final DateTime targetDate;

  const SavingTargetModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.walletIds,
    this.unit = SavingTargetUnit.money,
    required this.targetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "targetAmount": targetAmount,
      "walletIds": walletIds,
      "unit": unit.name,
      "targetDate": targetDate.toIso8601String(),
    };
  }

  factory SavingTargetModel.fromMap(Map<dynamic, dynamic> map) {
    return SavingTargetModel(
      id: map["id"],
      title: map["title"],
      targetAmount: (map["targetAmount"] as num).toDouble(),
      walletIds: List<String>.from(map["walletIds"]),
      unit: SavingTargetUnit.values.firstWhere((e) => e.name == map["unit"]),
      targetDate: DateTime.parse(map["targetDate"]),
    );
  }

  String encode() => jsonEncode(toMap());

  factory SavingTargetModel.decode(String source) =>
      SavingTargetModel.fromMap(jsonDecode(source));
}
