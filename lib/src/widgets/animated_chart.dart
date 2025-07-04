import 'package:flutter/material.dart';
import '../models/chart_config.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedPieChart extends StatefulWidget {
  final ChartConfig config;
  final VoidCallback? onAnimationComplete;

  const AnimatedPieChart({
    super.key,
    required this.config,
    this.onAnimationComplete,
  });

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

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.1415926535).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _rotationController.addListener(() {
      if (_rotationController.value >= 0.5 && !_fadeController.isCompleted) {
        _fadeController.forward();
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _oldConfig = null;
        });
        _fadeController.reverse();
      }
    });

    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _fadeController]),
      builder: (context, child) {
        return _buildChart();
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

    return Stack(
      alignment: Alignment.center,
      children: [
        if (currentConfig.showLegend) ...[
          SizedBox(
            width: currentConfig.radius * 1.414213562, // sqrt(2)
            child: Center(child: _buildLegend(currentConfig)),
          ),
        ],

        if (_oldConfig != null)
          Opacity(
            opacity: 1 - _fadeAnimation.value,
            child: _buildPieChart(_oldConfig!),
          ),
        Opacity(
          opacity: _isAnimating ? _fadeAnimation.value : 1.0,
          child: _buildPieChart(currentConfig),
        ),
      ],
    );
  }

  PieTouchData _buildTouchData(ChartConfig config) {
    return PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        // Обработка тач-событий для тултипов
      },
      mouseCursorResolver: (FlTouchEvent event, pieTouchResponse) {
        return pieTouchResponse?.touchedSection != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic;
      },
    );
  }

  List<PieChartSectionData> _buildSections(ChartConfig config) {
    return config.items.map((item) {
      return PieChartSectionData(
        showTitle: false,
        value: item.value,
        color: item.color,
        radius: config.radius * (1 - config.centerSpaceRatio),
      );
    }).toList();
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
    final total = currentConfig.items.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return Wrap(
      direction: Axis.vertical,
      spacing: 16,
      runSpacing: 8,
      children: currentConfig.items.map((item) {
        final percentage = (item.value / total * 100);

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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: currentConfig.radius * 1.414213562 - 24,
              ),
              child: Text(
                '${percentage.toStringAsFixed(2)}% ${item.label}',
                style:
                    currentConfig.legendTextStyle ??
                    Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPieChart(ChartConfig currentConfig) {
    return Transform.rotate(
      angle: _rotationAnimation.value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: currentConfig.radius * 2,
            width: currentConfig.radius * 2,
            child: PieChart(
              PieChartData(
                sections: _buildSections(currentConfig),
                centerSpaceRadius: currentConfig.isDoughnut
                    ? currentConfig.radius * currentConfig.centerSpaceRatio
                    : 0,
                sectionsSpace: 0,
                pieTouchData: currentConfig.enableTooltips
                    ? _buildTouchData(currentConfig)
                    : PieTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
