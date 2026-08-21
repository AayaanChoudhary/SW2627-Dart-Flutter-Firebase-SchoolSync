import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../utils/app_colors.dart';
import 'school_detail/attendance_tab.dart';
import 'school_detail/fees_tab.dart';
import 'school_detail/exams_tab.dart';
import 'school_detail/feedback_tab.dart';

/// Full-page detail view for a single school, accessed by tapping a
/// SchoolCard on the dashboard. Provides four tabs:
///   0 – Attendance
///   1 – Fees
///   2 – Exams
///   3 – Feedback
class SchoolDetailScreen extends StatefulWidget {
  final SchoolDashboardData schoolData;

  const SchoolDetailScreen({super.key, required this.schoolData});

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Attend.', 'Fees', 'Exams', 'Feedback'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final school = widget.schoolData.school;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x30000000),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.text,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // School name
                      Expanded(
                        child: Text(
                          school.name,
                          style: const TextStyle(
                            color: AppColors.card,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // School ID · Address
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Text(
                      '${school.schoolId.toUpperCase()}  ·  ${school.address.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFFC7BDB3),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),

            // ── Tab bar + content ────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Custom tab bar sits on the card's rounded top
                    _SchoolTabBar(
                      tabController: _tabController,
                      tabs: _tabs,
                    ),

                    // Tab body
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          AttendanceTab(schoolData: widget.schoolData),
                          FeesTab(schoolData: widget.schoolData),
                          ExamsTab(schoolData: widget.schoolData),
                          FeedbackTab(schoolData: widget.schoolData),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom tab bar ────────────────────────────────────────────────────────────

class _SchoolTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const _SchoolTabBar({
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = tabController.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => tabController.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.card : Colors.transparent,
                  borderRadius: isSelected
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )
                      : BorderRadius.zero,
                ),
                child: Text(
                  tabs[i].toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? AppColors.text : const Color(0xFFC7BDB3),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
