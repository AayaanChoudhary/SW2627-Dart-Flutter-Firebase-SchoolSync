import 'package:flutter/material.dart';
import '../screens/school_detail_screen.dart';
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
    final isCriticalAtt = schoolData.latestAttendancePercentage < 70.0;
    final isGoodAtt = schoolData.latestAttendancePercentage >= 85.0;
    final needsAttention = isCriticalAtt || !isOnTrack || (schoolData.feeSubmissionRate < 50.0 && schoolData.feesPending > 0);

    final attColor = isCriticalAtt
        ? const Color(0xFFC98591)
        : (isGoodAtt ? const Color(0xFF4A6741) : const Color(0xFFCBB158));

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SchoolDetailScreen(schoolData: schoolData),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: needsAttention ? const Color(0xFFE0BAC0) : const Color(0xFFE2DCCE),
            width: needsAttention ? 1.5 : 1.0,
          ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        school.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (needsAttention) ...[
                      const SizedBox(width: 4),
                      const Tooltip(
                        message: 'Requires Attention',
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: Color(0xFFC98591),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_formatNumber(school.studentCount)} STU',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Text(
                      '  ·  ',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isCriticalAtt
                            ? const Color(0xFFFAEAED)
                            : (isGoodAtt ? const Color(0xFFE8F0E5) : const Color(0xFFFFF9E6)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ATT ${schoolData.latestAttendancePercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: attColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOnTrack ? const Color(0xFF8FA57C) : const Color(0xFFC98591),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOnTrack ? 'ON TRACK' : 'LAGGING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
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
      ),
    );
  }

  String _formatNumber(int number) =>
      number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
