import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../utils/app_colors.dart';

class SchoolCard extends StatelessWidget {
  final SchoolDashboardData schoolData;
  final int index;

  const SchoolCard({
    super.key,
    required this.schoolData,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final school = schoolData.school;
    final isOnTrack = schoolData.examStatus.toLowerCase() == 'on track';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2DCCE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_formatNumber(school.studentCount)} STU  ·  ATT ${schoolData.latestAttendancePercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOnTrack ? const Color(0xFF8FA57C) : const Color(0xFFC98591),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOnTrack ? 'ON TRACK' : 'LAGGING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Icon(
                isOnTrack ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                size: 18,
                color: isOnTrack ? const Color(0xFF5A7552) : const Color(0xFFB54C5D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) =>
      number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
