import 'package:flutter/material.dart';

class ChartItem {
  final String label;
  final double value;
  final Color color;
  final String? description;

  const ChartItem({
    required this.label,
    required this.value,
    required this.color,
    this.description,
  });
}
