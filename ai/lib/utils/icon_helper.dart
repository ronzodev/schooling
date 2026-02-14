import 'package:flutter/material.dart';

class IconHelper {
  // Static map for subject/course keywords affecting icon choice
  static final Map<String, IconData> _subjectIcons = {
    'math': Icons.calculate_rounded,
    'algebra': Icons.functions_rounded,
    'geometry': Icons.architecture_rounded,
    'physics': Icons.science_rounded,
    'chem': Icons.biotech_rounded,
    'bio': Icons.spa_rounded,
    'geography': Icons.public_rounded,
    'history': Icons.history_edu_rounded,
    'english': Icons.menu_book_rounded,
    'literature': Icons.auto_stories_rounded,
    'language': Icons.language_rounded,
    'computer': Icons.computer_rounded,
    'tech': Icons.memory_rounded,
    'art': Icons.palette_rounded,
    'music': Icons.music_note_rounded,
    'sport': Icons.sports_soccer_rounded,
    'exam': Icons.assignment_rounded,
    'past paper': Icons.description_rounded,
    'physical science': Icons.bolt_rounded,
    'life science': Icons.emoji_nature_rounded,
  };

  // Fallback icon if no match found
  static const IconData _defaultIcon = Icons.school_rounded;

  /// Returns an appropriate icon based on the subject/course name.
  static IconData getIconForSubject(String subjectName) {
    final lowerName = subjectName.toLowerCase();

    // Check for exact keys or keywords contained in the name
    for (var entry in _subjectIcons.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    return _defaultIcon;
  }

  /// Returns an appropriate icon based on the topic name.
  /// Reuses subject logic but can be extended for topic-specific icons.
  static IconData getIconForTopic(String topicName) {
    // We can add more specific topic mappings here if needed
    final lowerName = topicName.toLowerCase();

    if (lowerName.contains('introduction')) return Icons.start_rounded;
    if (lowerName.contains('advanced')) return Icons.trending_up_rounded;
    if (lowerName.contains('fundamental')) return Icons.foundation_rounded;
    if (lowerName.contains('practice')) return Icons.edit_note_rounded;
    if (lowerName.contains('quiz') || lowerName.contains('test'))
      return Icons.quiz_rounded;

    // Fallback to subject logic to catch things like "Algebra 101" -> Algebra icon
    return getIconForSubject(topicName);
  }
}
