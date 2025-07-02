import 'package:flutter/material.dart';
import 'chart_data.dart';

class ChartConfig {
  final List<ChartItem> items;
  final bool showLegend;
  final bool enableTooltips;
  final Duration animationDuration;
  final double radius;
  final TextStyle? tooltipTextStyle;
  final TextStyle? legendTextStyle;

  const ChartConfig({
    required this.items,
    this.showLegend = true,
    this.enableTooltips = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.radius = 100.0,
    this.tooltipTextStyle,
    this.legendTextStyle,
  });
}
