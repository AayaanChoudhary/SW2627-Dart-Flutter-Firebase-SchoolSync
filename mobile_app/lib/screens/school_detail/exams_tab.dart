import 'package:flutter/material.dart';
import '../../models/exam_model.dart';
import '../../services/dashboard_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/school_detail/section_header.dart';

/// Exams tab shown inside SchoolDetailScreen.
/// Groups exams into Upcoming, Overdue, and Completed sections.
class ExamsTab extends StatefulWidget {
  final SchoolDashboardData schoolData;

  const ExamsTab({super.key, required this.schoolData});

  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  final DashboardService _service = DashboardService();
  late Future<List<ExamModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getSchoolExams(widget.schoolData.school.schoolId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExamModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.text));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                snapshot.hasError
                    ? 'Could not load exam data.'
                    : 'No exam records found.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.secondaryText, fontSize: 14),
              ),
            ),
          );
        }

        final exams = snapshot.data!;
        final overdue =
            exams.where((e) => e.isOverdue).toList();
        final upcoming = exams
            .where((e) => e.status == 'scheduled' && !e.isOverdue)
            .toList();
        final completed =
            exams.where((e) => e.isCompleted).toList();
        final cancelled =
            exams.where((e) => e.isCancelled).toList();

        // Overall status pill
        final isLagging = overdue.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status banner ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isLagging
                      ? const Color(0xFFFAEAED)
                      : const Color(0xFFE8F0E5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLagging
                        ? const Color(0xFFE0BAC0)
                        : const Color(0xFFB5CEAD),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLagging
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded,
                      color: isLagging
                          ? const Color(0xFFC98591)
                          : const Color(0xFF4A6741),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isLagging
                          ? '${overdue.length} exam${overdue.length > 1 ? 's' : ''} overdue'
                          : 'All exams on track',
                      style: TextStyle(
                        color: isLagging
                            ? const Color(0xFFC98591)
                            : const Color(0xFF4A6741),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              if (overdue.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(
                    text: 'Overdue',
                    color: Color(0xFFC98591)),
                const SizedBox(height: 10),
                ...overdue.map((e) => _ExamCard(exam: e)),
              ],

              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(text: 'Upcoming'),
                const SizedBox(height: 10),
                ...upcoming.map((e) => _ExamCard(exam: e)),
              ],

              if (completed.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(text: 'Completed'),
                const SizedBox(height: 10),
                ...completed.map((e) => _ExamCard(exam: e)),
              ],

              if (cancelled.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(text: 'Cancelled'),
                const SizedBox(height: 10),
                ...cancelled.map((e) => _ExamCard(exam: e)),
              ],

              if (exams.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No exams scheduled.',
                      style: TextStyle(
                          color: AppColors.secondaryText, fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ExamCard extends StatelessWidget {
  final ExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    String statusLabel;
    IconData statusIcon;

    if (exam.isOverdue) {
      statusColor = const Color(0xFFC98591);
      statusBg = const Color(0xFFFAEAED);
      statusLabel = 'OVERDUE';
      statusIcon = Icons.warning_amber_rounded;
    } else if (exam.isCompleted) {
      statusColor = const Color(0xFF4A6741);
      statusBg = const Color(0xFFE8F0E5);
      statusLabel = 'DONE';
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (exam.isCancelled) {
      statusColor = AppColors.secondaryText;
      statusBg = const Color(0xFFF0EDE8);
      statusLabel = 'CANCELLED';
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = const Color(0xFF6B7F99);
      statusBg = const Color(0xFFE8EDF3);
      statusLabel = 'SCHEDULED';
      statusIcon = Icons.calendar_today_outlined;
    }

    final dateStr =
        '${exam.scheduledDate.day.toString().padLeft(2, '0')} ${_month(exam.scheduledDate.month)} ${exam.scheduledDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2DCCE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Subject chip
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),

          const SizedBox(width: 12),

          // Name, subject, date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.examName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exam.subject}  ·  Class ${exam.classNumber}  ·  $dateStr',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
