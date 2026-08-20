import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// A reusable search bar widget for filtering schools by name or school ID.
///
/// This widget is intentionally a pure input/display component — it emits
/// the typed query via [onChanged] and lets the parent handle filtering.
/// Drop it into any page that needs to search the same school list.
///
/// Example usage:
/// ```dart
/// SchoolSearchBar(
///   controller: _searchController,
///   query: _searchQuery,
///   onChanged: (q) => setState(() => _searchQuery = q),
/// )
/// ```
class SchoolSearchBar extends StatelessWidget {
  /// Controls the underlying [TextField].
  final TextEditingController controller;

  /// The current search query string (used to show/hide the clear button).
  final String query;

  /// Called whenever the user changes the search text.
  final ValueChanged<String> onChanged;

  /// Placeholder text shown when the field is empty.
  final String hintText;

  const SchoolSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    this.hintText = 'Search by name or school ID…',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDD5C6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.secondaryText,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: AppColors.text,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFC4BCB0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Clear button — only visible when query is non-empty
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: const BoxConstraints(),
              splashRadius: 18,
              tooltip: 'Clear search',
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}
