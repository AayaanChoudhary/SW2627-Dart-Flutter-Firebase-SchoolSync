import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../utils/app_colors.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/school_card.dart';
import '../widgets/school_search_bar.dart';
import '../widgets/stat_card.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _districtId = 'DIST001';
  final DashboardService _dashboardService = DashboardService();
  late Future<DistrictDashboardSummary> _dashboardFuture;
  late final Timer _refreshTimer;
  int _currentIndex = 0;

  // ── Search state ────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.getDistrictSummary(_districtId);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }


  void _reload() {
    setState(() {
      _dashboardFuture = _dashboardService.getDistrictSummary(_districtId);
    });
  }

  Future<void> _handleLogout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'Priya');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<DistrictDashboardSummary>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _DashboardMessage(
                message: 'Unable to load dashboard data.\n${snapshot.error}',
                onRetry: _reload,
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.card),
              );
            }

            final summary = snapshot.data!;
            final schools = summary.schoolsData;

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await _dashboardFuture;
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardHeader(
                          userName: userName,
                          onLogout: _handleLogout,
                        ),

                        const SizedBox(height: 24),

                        // ── Stat Summary Cards ─────────────────────────
                        Row(
                          children: [
                            StatCard(
                              value: '${summary.averageAttendanceToday.toStringAsFixed(0)}%',
                              label: 'Attendance today',
                              percentage: summary.averageAttendanceToday / 100.0,
                            ),
                            StatCard(
                              value: _formatCurrency(summary.totalFeesCollected),
                              label: 'Fees collected',
                              percentage: 0.77,
                            ),
                            StatCard(
                              value: summary.examProgressStatus == 'Lagging'
                                  ? 'Lagging'
                                  : 'On track',
                              label: 'Exams this week',
                              isArrow: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── School Search Bar ───────────────────────────
                        SchoolSearchBar(
                          controller: _searchController,
                          query: _searchQuery,
                          onChanged: (q) =>
                              setState(() => _searchQuery = q.trim()),
                        ),

                        const SizedBox(height: 24),

                        // ── Filtered schools list ───────────────────────
                        Builder(
                          builder: (_) {
                            final q = _searchQuery.toLowerCase();
                            final filteredSchools = q.isEmpty
                                ? schools
                                : schools.where((s) {
                                    return s.school.name
                                            .toLowerCase()
                                            .contains(q) ||
                                        s.school.schoolId
                                            .toLowerCase()
                                            .contains(q);
                                  }).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pinned Schools Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Pinned Schools',
                                      style: TextStyle(
                                        color: AppColors.card,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      q.isEmpty
                                          ? '${schools.length} TOTAL'
                                          : '${filteredSchools.length} OF ${schools.length}',
                                      style: const TextStyle(
                                        color: Color(0xFFC7BDB3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Grid or empty states
                                if (schools.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Text(
                                        'No schools found for this district.',
                                        style:
                                            TextStyle(color: AppColors.card),
                                      ),
                                    ),
                                  )
                                else if (filteredSchools.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 40),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.search_off_rounded,
                                            color: Color(0xFFC7BDB3),
                                            size: 44,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No schools match "$_searchQuery".',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFC7BDB3),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredSchools.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.94,
                                    ),
                                    itemBuilder: (context, idx) => SchoolCard(
                                      schoolData: filteredSchools[idx],
                                      index: idx,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                ),

                // Floating Pill Bottom Navigation Bar Overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DashboardBottomNav(
                    currentIndex: _currentIndex,
                    onTap: (index) => setState(() => _currentIndex = index),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.card),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: AppColors.card)),
            ),
          ],
        ),
      ),
    );
  }
}


