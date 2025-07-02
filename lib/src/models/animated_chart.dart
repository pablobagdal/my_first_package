import 'package:flutter/material.dart';
import '../widgets/chart_config.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedPieChart extends StatefulWidget {
  final ChartConfig config;
  final VoidCallback? onAnimationComplete;

  const AnimatedPieChart({
    Key? key,
    required this.config,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  ChartConfig? _oldConfig;
  ChartConfig? _newConfig;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _newConfig = widget.config;
  }

  @override
  void didUpdateWidget(AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _updateChart(widget.config);
    }
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.config.animationDuration.inMilliseconds ~/ 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _fadeController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Opacity(
            opacity: _isAnimating ? _fadeAnimation.value : 1.0,
            child: _buildChart(),
          ),
        );
      },
    );
  }

  void _updateChart(ChartConfig newConfig) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _oldConfig = _newConfig;
      _newConfig = newConfig;
    });

    _rotationController.reset();
    _fadeController.reset();
    _rotationController.forward();
  }

  Widget _buildChart() {
    final currentConfig = _getCurrentConfig();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: currentConfig.radius * 2,
          width: currentConfig.radius * 2,
          child: PieChart(
            PieChartData(
              // TODO
            ),
          ),
        ),
        if (currentConfig.showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(currentConfig),
        ],
      ],
    );
  }

  // can throw an exception if the config is null
  // this is to ensure that the chart always has a valid configuration
  ChartConfig _getCurrentConfig() {
    final oldConfig = _oldConfig;
    if (_isAnimating && _rotationController.value < 0.5 && oldConfig != null) {
      return oldConfig;
    } else {
      final newConfig = _newConfig;
      if (newConfig == null) {
        throw Exception("New config cannot be null during animation.");
      }
      return newConfig;
    }
  }

  Widget _buildLegend(ChartConfig currentConfig) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: currentConfig.items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4.0),
            Text(
              item.label,
              style:
                  currentConfig.legendTextStyle ??
                  Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }).toList(),
    );
  }
}
