import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DistrictSummaryMetric {
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final IconData? icon;

  const DistrictSummaryMetric({
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.icon,
  });
}

class DistrictSummaryBanner extends StatelessWidget {
  final String title;
  final List<DistrictSummaryMetric> metrics;
  final Widget? trailing;

  const DistrictSummaryBanner({
    super.key,
    required this.title,
    required this.metrics,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DCCE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: metrics.asMap().entries.map((entry) {
              final idx = entry.key;
              final metric = entry.value;
              final isLast = idx == metrics.length - 1;

              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    right: isLast ? 0 : 12,
                    left: idx == 0 ? 0 : 12,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(
                            right: BorderSide(
                              color: Color(0xFFE2DCCE),
                              width: 1,
                            ),
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (metric.icon != null) ...[
                            Icon(
                              metric.icon,
                              size: 16,
                              color: metric.valueColor ?? AppColors.text,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              metric.value,
                              style: TextStyle(
                                color: metric.valueColor ?? AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metric.label,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (metric.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          metric.subtitle!,
                          style: TextStyle(
                            color: metric.valueColor?.withAlpha(200) ??
                                AppColors.secondaryText,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
