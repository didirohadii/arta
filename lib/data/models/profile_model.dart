class ProfileModel {
  final String name;
  final String financialGoal;
  final DateTime createdAt;
  final String avatar;

  const ProfileModel({
    required this.name,
    required this.financialGoal,
    required this.createdAt,
    required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "financialGoal": financialGoal,
      "createdAt": createdAt.toIso8601String(),
      "avatar": avatar,
    };
  }

  factory ProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return ProfileModel(
      name: map["name"] ?? "",
      financialGoal: map["financialGoal"] ?? "",
      createdAt: DateTime.parse(
        map["createdAt"] ?? DateTime.now().toIso8601String(),
      ),
      avatar: map["avatar"] ?? "avatar_1.png",
    );
  }

  ProfileModel copyWith({
    String? name,
    String? financialGoal,
    DateTime? createdAt,
    String? avatar,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      financialGoal: financialGoal ?? this.financialGoal,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
    );
  }
}
