import 'package:flutter/material.dart';
import '../models/chart_data.dart';

class CustomTooltip extends StatelessWidget {
  final ChartItem item;
  final TextStyle? textStyle;

  const CustomTooltip({Key? key, required this.item, this.textStyle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style:
                textStyle?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Значение: ${item.value.toStringAsFixed(2)}',
            style:
                textStyle?.copyWith(color: Colors.white70) ??
                const TextStyle(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
          if (item.description != null) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style:
                  textStyle?.copyWith(color: Colors.white60) ??
                  const TextStyle(color: Colors.white60),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}
