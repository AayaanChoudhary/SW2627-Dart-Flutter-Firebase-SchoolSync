import 'dart:math';

import 'package:flutter/material.dart';

import '../models/school.dart';
import '../utils/app_colors.dart';

class SchoolCard extends StatelessWidget {
  final School school;
  final int index;

  const SchoolCard({
    super.key,
    required this.school,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final rotation = index.isEven ? -0.015 : 0.015;

    return Transform.rotate(
      angle: rotation * pi,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 175,
            ),
            padding: const EdgeInsets.fromLTRB(18, 28, 14, 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  offset: Offset(3, 5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '${_formatStudents(school.students)} STU  ·  ATT ${school.attendance}%',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  color: school.isOnTrack
                      ? AppColors.green
                      : AppColors.pink,
                  child: Text(
                    school.status,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pin
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index.isEven
                      ? const Color(0xFF8FA58A)
                      : const Color(0xFFC98791),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      offset: Offset(1, 3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStudents(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match.group(1)},',
        );
  }
}