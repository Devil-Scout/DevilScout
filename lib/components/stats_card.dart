import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final double opr;
  final double ccwm;
  final double dpr;

  const StatsCard({
    super.key,
    required this.opr,
    required this.ccwm,
    required this.dpr,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _StatColumn(value: opr, label: 'OPR', context: context),
            const Spacer(),
            const VerticalDivider(),
            const Spacer(),
            _StatColumn(value: ccwm, label: 'CCWM', context: context),
            const Spacer(),
            const VerticalDivider(),
            const Spacer(),
            _StatColumn(value: dpr, label: 'DPR', context: context),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final double value;
  final String label;
  final BuildContext context;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
