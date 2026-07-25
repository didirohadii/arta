import 'package:flutter/material.dart';

import '../../../data/models/asset_history_model.dart';

class NetWorthPainter extends CustomPainter {
  final List<AssetHistoryModel> data;

  NetWorthPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final max = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    final min = data.map((e) => e.amount).reduce((a, b) => a < b ? a : b);

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final dx = i * (size.width / (data.length - 1));

      final percent =
          (data[i].amount - min) / ((max - min) == 0 ? 1 : (max - min));

      final dy = size.height - percent * (size.height - 30);

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }

      canvas.drawCircle(Offset(dx, dy), 4, pointPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: "${(data[i].amount / 1000).round()}K",
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

      tp.layout();

      tp.paint(canvas, Offset(dx - tp.width / 2, dy - 22));
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
