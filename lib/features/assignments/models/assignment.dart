enum AssignmentStatus { notSubmitted, submitted, graded }

class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.status,
    this.score,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime deadline;
  final AssignmentStatus status;
  final int? score;

  Assignment copyWith({
    AssignmentStatus? status,
    int? score,
  }) {
    return Assignment(
      id: id,
      title: title,
      subject: subject,
      deadline: deadline,
      status: status ?? this.status,
      score: score ?? this.score,
    );
  }
}
