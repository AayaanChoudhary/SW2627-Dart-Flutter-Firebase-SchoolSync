import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../utils/app_colors.dart';
import '../utils/business_rules.dart';

enum DashboardTriageFilter {
  all,
  needsAttention,
  criticalAttendance,
  laggingExams,
  onTrack,
}

/// Executive decision-making alert hub spotlighting operational risks and
/// urgent administrative intervention points across district schools based on KPI thresholds.
class DashboardActionCenter extends StatelessWidget {
  final List<SchoolDashboardData> schools;
  final ValueChanged<DashboardTriageFilter>? onFilterSelected;

  const DashboardActionCenter({
    super.key,
    required this.schools,
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final criticalAttendanceSchools = schools
        .where((s) => s.attendanceStatus == KPIStatus.critical)
        .toList();

    final warningAttendanceSchools = schools
        .where((s) => s.attendanceStatus == KPIStatus.warning)
        .toList();

    final laggingExamSchools = schools
        .where((s) => s.examKPIStatus == KPIStatus.critical)
        .toList();

    final approachingExamSchools = schools
        .where((s) => s.examKPIStatus == KPIStatus.warning)
        .toList();

    final criticalFeeSchools = schools
        .where((s) => s.feeStatus == KPIStatus.critical && s.feesPending > 0)
        .toList();

    final warningFeeSchools = schools
        .where((s) => s.feeStatus == KPIStatus.warning && s.feesPending > 0)
        .toList();

    final totalCriticalIssues = criticalAttendanceSchools.length +
        laggingExamSchools.length +
        criticalFeeSchools.length;

    final totalWarningIssues = warningAttendanceSchools.length +
        approachingExamSchools.length +
        warningFeeSchools.length;

    final totalIssues = totalCriticalIssues + totalWarningIssues;
    final hasCriticalIssues = totalCriticalIssues > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCriticalIssues
              ? const Color(0xFFE0BAC0)
              : (totalWarningIssues > 0
                  ? const Color(0xFFF0E0B0)
                  : const Color(0xFFE2DCCE)),
          width: hasCriticalIssues ? 1.5 : 1.0,
        ),
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
          // ── Header: Title & Operational Health Status Pill ──────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Color(0xFF8B3A4A),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'DECISION & ACTION HUB',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: totalIssues > 0
                      ? (hasCriticalIssues
                          ? const Color(0xFFFAEAED)
                          : const Color(0xFFFFF9E6))
                      : const Color(0xFFE8F0E5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: totalIssues > 0
                        ? (hasCriticalIssues
                            ? const Color(0xFFC98591)
                            : const Color(0xFFCBB158))
                        : const Color(0xFF8FA57C),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  totalIssues > 0
                      ? (hasCriticalIssues
                          ? '$totalCriticalIssues CRITICAL · $totalWarningIssues WARNING'
                          : '$totalWarningIssues WARNING ${totalWarningIssues == 1 ? 'ALERT' : 'ALERTS'}')
                      : 'OPERATIONS HEALTHY',
                  style: TextStyle(
                    color: totalIssues > 0
                        ? (hasCriticalIssues
                            ? const Color(0xFFC98591)
                            : const Color(0xFF9E8424))
                        : const Color(0xFF4A6741),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── If no issues found: Reassuring status message ─────────────
          if (totalIssues == 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4A6741),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All district schools are currently meeting attendance, exam, and fee benchmarks.',
                      style: TextStyle(
                        color: Color(0xFF385231),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ── Critical Attendance Alert ──────────────────────────────
            if (criticalAttendanceSchools.isNotEmpty) ...[
              _buildAlertCard(
                icon: Icons.person_off_rounded,
                iconColor: const Color(0xFFC98591),
                bgColor: const Color(0xFFFAEAED),
                borderColor: const Color(0xFFE0BAC0),
                title: '${criticalAttendanceSchools.length} ${criticalAttendanceSchools.length == 1 ? 'School with Critical Attendance (<75%)' : 'Schools with Critical Attendance (<75%)'}',
                description: criticalAttendanceSchools
                    .map((s) => '${s.school.name} (${s.latestAttendancePercentage.toStringAsFixed(0)}%)')
                    .join(', '),
                actionLabel: 'Filter Critical',
                onAction: () => onFilterSelected?.call(DashboardTriageFilter.criticalAttendance),
              ),
              const SizedBox(height: 8),
            ],

            // ── Exam Schedule Delay / Overdue Alert ────────────────────
            if (laggingExamSchools.isNotEmpty) ...[
              _buildAlertCard(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFFB54C5D),
                bgColor: const Color(0xFFFDEEF0),
                borderColor: const Color(0xFFE0BAC0),
                title: '${laggingExamSchools.length} ${laggingExamSchools.length == 1 ? 'School with Overdue Exams (Critical)' : 'Schools with Overdue Exams (Critical)'}',
                description: laggingExamSchools
                    .map((s) => s.school.name)
                    .join(', '),
                actionLabel: 'Filter Lagging',
                onAction: () => onFilterSelected?.call(DashboardTriageFilter.laggingExams),
              ),
              const SizedBox(height: 8),
            ],

            // ── Critical Fee Collection Deficit Alert ──────────────────
            if (criticalFeeSchools.isNotEmpty) ...[
              _buildAlertCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFFC98591),
                bgColor: const Color(0xFFFAEAED),
                borderColor: const Color(0xFFE0BAC0),
                title: '${criticalFeeSchools.length} ${criticalFeeSchools.length == 1 ? 'School with Critical Fee Deficit (<75%)' : 'Schools with Critical Fee Deficit (<75%)'}',
                description: criticalFeeSchools
                    .map((s) => '${s.school.name} (${s.feeSubmissionRate.toStringAsFixed(0)}% collected)')
                    .join(', '),
                actionLabel: 'Review Fees',
                onAction: () => onFilterSelected?.call(DashboardTriageFilter.needsAttention),
              ),
              const SizedBox(height: 8),
            ],

            // ── Approaching Exam Deadlines (Warning) ───────────────────
            if (approachingExamSchools.isNotEmpty) ...[
              _buildAlertCard(
                icon: Icons.alarm_rounded,
                iconColor: const Color(0xFFCBB158),
                bgColor: const Color(0xFFFFF9E6),
                borderColor: const Color(0xFFF0E0B0),
                title: '${approachingExamSchools.length} ${approachingExamSchools.length == 1 ? 'School with Approaching Exam Deadlines (Warning)' : 'Schools with Approaching Exam Deadlines (Warning)'}',
                description: approachingExamSchools
                    .map((s) => s.school.name)
                    .join(', '),
                actionLabel: 'View Exams',
                onAction: () => onFilterSelected?.call(DashboardTriageFilter.laggingExams),
              ),
              const SizedBox(height: 8),
            ],

            // ── Attendance Warning (75% - 84.9%) ────────────────────────
            if (warningAttendanceSchools.isNotEmpty) ...[
              _buildAlertCard(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFFCBB158),
                bgColor: const Color(0xFFFFF9E6),
                borderColor: const Color(0xFFF0E0B0),
                title: '${warningAttendanceSchools.length} ${warningAttendanceSchools.length == 1 ? 'School in Attendance Warning Zone (75-84.9%)' : 'Schools in Attendance Warning Zone (75-84.9%)'}',
                description: warningAttendanceSchools
                    .map((s) => '${s.school.name} (${s.latestAttendancePercentage.toStringAsFixed(0)}%)')
                    .join(', '),
                actionLabel: 'Inspect',
                onAction: () => onFilterSelected?.call(DashboardTriageFilter.needsAttention),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.card,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

