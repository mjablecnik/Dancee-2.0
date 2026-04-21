import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../data/event_repository.dart';
import '../../../shared/sections/dance_styles_filter_section.dart';
import 'sections/all_courses_section.dart';
import 'sections/courses_header_section.dart';
import 'sections/featured_courses_section.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  int _selectedStyleIndex = 0;
  List<String> _styles = [];

  @override
  void initState() {
    super.initState();
    const EventRepository().getCourseStyleFilters().then((styles) {
      if (mounted) setState(() => _styles = styles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appBg,
      child: Column(
        children: [
          CoursesHeaderSection(onFilterTap: () {}),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16, top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DanceStylesFilterSection(
                    styles: _styles,
                    selectedIndex: _selectedStyleIndex,
                    onSelected: (index) =>
                        setState(() => _selectedStyleIndex = index),
                  ),
                  const SizedBox(height: 24),
                  FeaturedCoursesSection(
                    onCourseTap: (_) => context.push('/courses/detail'),
                  ),
                  const SizedBox(height: 24),
                  AllCoursesSection(
                    onCourseTap: (_) => context.push('/courses/detail'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
