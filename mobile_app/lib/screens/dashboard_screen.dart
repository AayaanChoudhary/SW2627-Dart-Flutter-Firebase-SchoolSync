import 'package:flutter/material.dart';

import '../models/school.dart';
import '../utils/app_colors.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/school_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Temporary data.
  // Later this will come from your backend/Firebase.
  final List<School> _schools = const [
    School(
      name: 'Greenwood Public School',
      students: 1240,
      attendance: 94,
      status: 'ON TRACK',
    ),
    School(
      name: 'Riverdale High',
      students: 980,
      attendance: 88,
      status: 'LAGGING',
    ),
    School(
      name: "St. Xavier's Academy",
      students: 1120,
      attendance: 91,
      status: 'ON TRACK',
    ),
    School(
      name: 'Northgate Convent',
      students: 890,
      attendance: 86,
      status: 'LAGGING',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // Everything that should scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------
                    // HEADER
                    // -------------------------
                    const DashboardHeader(
                      userName: 'Priya',
                    ),

                    const SizedBox(height: 28),

                    // -------------------------
                    // STATISTICS
                    // -------------------------
                    Row(
                      children: const [
                        StatCard(
                          value: '92%',
                          label: 'Attendance today',
                        ),
                        StatCard(
                          value: '₹18.4L',
                          label: 'Fees collected',
                        ),
                        StatCard(
                          value: '↑',
                          label: 'Exams this week',
                          icon: Icons.arrow_upward,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // -------------------------
                    // PINNED SCHOOLS HEADER
                    // -------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Pinned Schools',
                          style: TextStyle(
                            color: AppColors.card,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          '${_schools.length} TOTAL',
                          style: const TextStyle(
                            color: AppColors.card,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // -------------------------
                    // SCHOOL GRID
                    // -------------------------
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _schools.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.88,
                      ),
                      itemBuilder: (context, index) {
                        return SchoolCard(
                          school: _schools[index],
                          index: index,
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // -------------------------
            // BOTTOM NAVIGATION
            // -------------------------
            DashboardBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}