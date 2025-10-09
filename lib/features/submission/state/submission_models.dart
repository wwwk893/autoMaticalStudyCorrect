import 'package:flutter/material.dart';

import '../../../utils/image_preprocess.dart';

enum SubmissionStage { queued, ocr, parsed, graded, reported }

extension SubmissionStageExt on SubmissionStage {
  String get badgeLabel {
    switch (this) {
      case SubmissionStage.queued:
        return '排队中';
      case SubmissionStage.ocr:
        return 'OCR';
      case SubmissionStage.parsed:
        return '解析';
      case SubmissionStage.graded:
        return '判分';
      case SubmissionStage.reported:
        return '报告';
    }
  }

  Color get badgeColor {
    switch (this) {
      case SubmissionStage.queued:
        return Colors.blueGrey;
      case SubmissionStage.ocr:
        return Colors.deepPurple;
      case SubmissionStage.parsed:
        return Colors.blue;
      case SubmissionStage.graded:
        return Colors.teal;
      case SubmissionStage.reported:
        return Colors.green;
    }
  }

  static SubmissionStage? tryParse(String value) {
    for (final stage in SubmissionStage.values) {
      if (stage.name == value) {
        return stage;
      }
    }
    return null;
  }
}

class SubmissionPagePayload {
  SubmissionPagePayload({
    required this.localPath,
    required this.processed,
    required this.order,
  });

  final String localPath;
  final ImagePreprocessResult processed;
  final int order;
}

class SubmissionSummary {
  SubmissionSummary({
    required this.id,
    required this.assignmentId,
    required this.stage,
    this.score,
    this.pages = const [],
  });

  final String id;
  final String assignmentId;
  final SubmissionStage stage;
  final int? score;
  final List<SubmissionPagePayload> pages;

  SubmissionSummary copyWith({
    SubmissionStage? stage,
    int? score,
    List<SubmissionPagePayload>? pages,
  }) {
    return SubmissionSummary(
      id: id,
      assignmentId: assignmentId,
      stage: stage ?? this.stage,
      score: score ?? this.score,
      pages: pages ?? this.pages,
    );
  }
}
