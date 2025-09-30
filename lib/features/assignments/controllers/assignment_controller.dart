import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/assignment.dart';

final assignmentListProvider = Provider<List<Assignment>>((ref) {
  final now = DateTime.now();
  return [
    Assignment(
      id: 'cn-001',
      title: '古诗词默写',
      subject: '语文',
      deadline: now.add(const Duration(days: 1)),
      status: AssignmentStatus.notSubmitted,
    ),
    Assignment(
      id: 'math-002',
      title: '等式与算式',
      subject: '数学',
      deadline: now.add(const Duration(days: 2)),
      status: AssignmentStatus.graded,
      score: 85,
    ),
  ];
});

final dateFormatterProvider = Provider<DateFormat>((ref) {
  return DateFormat('MM/dd HH:mm');
});
