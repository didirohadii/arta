class ChartDataModel {
  final String label;
  final double income;
  final double expense;

  const ChartDataModel({
    required this.label,
    required this.income,
    required this.expense,
  });

  double get cashFlow => income - expense;
}
