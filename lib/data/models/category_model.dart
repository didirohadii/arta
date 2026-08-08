class CategoryModel {
  final String id;
  final String name;
  final String type; // income / expense

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name, "type": type};
  }

  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return CategoryModel(id: map["id"], name: map["name"], type: map["type"]);
  }
}
