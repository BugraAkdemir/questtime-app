import 'package:flutter/material.dart';
import 'enums.dart';

/// Utility class for mapping Subject enum to Material Icons
class SubjectIcons {
  static IconData getIcon(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return Icons.calculate;
      case Subject.physics:
        return Icons.science;
      case Subject.chemistry:
        return Icons.science;
      case Subject.biology:
        return Icons.biotech;
      case Subject.geography:
        return Icons.public;
      case Subject.history:
        return Icons.history_edu;
      case Subject.literature:
        return Icons.menu_book;
      case Subject.english:
        return Icons.language;
      case Subject.software:
        return Icons.code;
      case Subject.algorithms:
        return Icons.settings;
      case Subject.philosophy:
        return Icons.psychology;
      case Subject.economics:
        return Icons.trending_up;
      case Subject.psychology:
        return Icons.psychology;
      case Subject.art:
        return Icons.palette;
      case Subject.examRevision:
        return Icons.assignment;
    }
  }

  static Color getIconColor(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return const Color(0xFF6366F1);
      case Subject.physics:
        return const Color(0xFF8B5CF6);
      case Subject.chemistry:
        return const Color(0xFF06B6D4);
      case Subject.biology:
        return const Color(0xFF10B981);
      case Subject.geography:
        return const Color(0xFF3B82F6);
      case Subject.history:
        return const Color(0xFFF59E0B);
      case Subject.literature:
        return const Color(0xFFEF4444);
      case Subject.english:
        return const Color(0xFF6366F1);
      case Subject.software:
        return const Color(0xFF06B6D4);
      case Subject.algorithms:
        return const Color(0xFF8B5CF6);
      case Subject.philosophy:
        return const Color(0xFFEC4899);
      case Subject.economics:
        return const Color(0xFF10B981);
      case Subject.psychology:
        return const Color(0xFFEC4899);
      case Subject.art:
        return const Color(0xFFF59E0B);
      case Subject.examRevision:
        return const Color(0xFF6366F1);
    }
  }
}

