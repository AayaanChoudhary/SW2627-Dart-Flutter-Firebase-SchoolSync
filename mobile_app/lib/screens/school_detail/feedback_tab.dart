import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/feedback_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/feedback_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/school_detail/section_header.dart';

/// Feedback tab shown inside SchoolDetailScreen.
/// Provides a form to file a new feedback report (stored in Firestore)
/// and shows the history of past feedback below.
class FeedbackTab extends StatefulWidget {
  final SchoolDashboardData schoolData;

  const FeedbackTab({super.key, required this.schoolData});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  final FeedbackService _service = FeedbackService();
  final TextEditingController _textController = TextEditingController();

  late Future<List<FeedbackModel>> _historyFuture;
  String _selectedSymbol = 'good'; // 'good' or 'needs_review'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    _historyFuture =
        _service.getSchoolFeedback(widget.schoolData.school.schoolId);
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your observation before filing.'),
          backgroundColor: Color(0xFFC98591),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final createdBy = user?.email ?? user?.displayName ?? 'district_admin';

      await _service.fileFeedbackReport(
        schoolId: widget.schoolData.school.schoolId,
        text: text,
        symbol: _selectedSymbol,
        createdBy: createdBy,
      );

      _textController.clear();
      setState(() {
        _loadHistory(); // refresh history
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report filed successfully.'),
            backgroundColor: Color(0xFF4A6741),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to file report: $e'),
            backgroundColor: const Color(0xFFC98591),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Form card ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2DCCE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                    text: "File a note for this school's records"),
                const SizedBox(height: 14),

                // Text area
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCBC5B8),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    minLines: 5,
                    maxLines: 8,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Write your observation here...',
                      hintStyle: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                      contentPadding: EdgeInsets.all(14),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Symbol toggle — Good Standing / Needs Review
                Row(
                  children: [
                    _SymbolButton(
                      label: 'Good Standing',
                      icon: Icons.thumb_up_outlined,
                      isSelected: _selectedSymbol == 'good',
                      selectedColor: const Color(0xFF4A6741),
                      selectedBg: const Color(0xFFE8F0E5),
                      onTap: () =>
                          setState(() => _selectedSymbol = 'good'),
                    ),
                    const SizedBox(width: 10),
                    _SymbolButton(
                      label: 'Needs Review',
                      icon: Icons.flag_outlined,
                      isSelected: _selectedSymbol == 'needs_review',
                      selectedColor: const Color(0xFFC98591),
                      selectedBg: const Color(0xFFFAEAED),
                      onTap: () =>
                          setState(() => _selectedSymbol = 'needs_review'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.text,
                      foregroundColor: AppColors.card,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.card,
                            ),
                          )
                        : const Text(
                            'File report',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── History ────────────────────────────────────────────────────
          FutureBuilder<List<FeedbackModel>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.text));
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Unable to load past feedback records: ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final entries = snapshot.data!;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2DCCE)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(text: 'Past Reports'),
                    const SizedBox(height: 12),
                    ...entries.map((f) => _FeedbackHistoryRow(feedback: f)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SymbolButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBg;
  final VoidCallback onTap;

  const _SymbolButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? selectedColor : const Color(0xFFCBC5B8),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isSelected ? selectedColor : AppColors.secondaryText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? selectedColor : AppColors.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackHistoryRow extends StatelessWidget {
  final FeedbackModel feedback;

  const _FeedbackHistoryRow({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final isGood = feedback.symbol == 'good';
    final dotColor =
        isGood ? const Color(0xFF4A6741) : const Color(0xFFC98591);
    final badgeText = isGood ? 'GOOD' : 'REVIEW';
    final badgeBg =
        isGood ? const Color(0xFFE8F0E5) : const Color(0xFFFAEAED);

    final dateStr =
        '${feedback.createdAt.day.toString().padLeft(2, '0')} ${_month(feedback.createdAt.month)} ${feedback.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: dotColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              feedback.text,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(color: Color(0xFFEDE8DF), height: 1),
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
