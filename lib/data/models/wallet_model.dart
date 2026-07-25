import 'dart:convert';

enum WalletType { cash, bank, investment, gold }

class WalletModel {
  final String id;
  final String name;
  final double initialBalance;
  final WalletType type;

  /// Hanya dipakai kalau wallet emas
  final double? gram;

  const WalletModel({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.type,
    this.gram,
  });

  bool get isGold => type == WalletType.gold;

  WalletModel copyWith({
    String? id,
    String? name,
    double? initialBalance,
    WalletType? type,
    double? gram,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      type: type ?? this.type,
      gram: gram ?? this.gram,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "initialBalance": initialBalance,
      "type": type.index,
      "gram": gram,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json["id"],
      name: json["name"],
      initialBalance: (json["initialBalance"] as num).toDouble(),
      type: WalletType.values[json["type"]],
      gram: json["gram"] == null ? null : (json["gram"] as num).toDouble(),
    );
  }

  String encode() => jsonEncode(toJson());

  factory WalletModel.decode(String source) =>
      WalletModel.fromJson(jsonDecode(source));
}
