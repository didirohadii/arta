import 'package:flutter/material.dart';

class InsightModel {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final int priority;

  const InsightModel({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.priority,
  });
}
