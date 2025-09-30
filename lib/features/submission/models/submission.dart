enum SubmissionStatus { queued, ocr, parsed, graded, reported }

class Submission {
  const Submission({
    required this.id,
    required this.assignmentId,
    required this.status,
    this.score,
  });

  final String id;
  final String assignmentId;
  final SubmissionStatus status;
  final int? score;

  Submission copyWith({
    SubmissionStatus? status,
    int? score,
  }) {
    return Submission(
      id: id,
      assignmentId: assignmentId,
      status: status ?? this.status,
      score: score ?? this.score,
    );
  }
}
