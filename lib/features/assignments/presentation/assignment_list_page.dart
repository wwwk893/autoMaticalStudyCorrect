import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/assignment_controller.dart';
import '../models/assignment.dart';
import '../../submission/presentation/submit_page.dart';
import '../../result/presentation/result_page.dart';

class AssignmentListPage extends ConsumerWidget {
  const AssignmentListPage({super.key});

  static const routeName = 'assignments';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(assignmentListProvider);
    final formatter = ref.watch(dateFormatterProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('作业列表'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${assignment.subject} · ${assignment.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('截止：${formatter.format(assignment.deadline)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(_statusLabel(assignment.status)),
                        backgroundColor: _statusColor(context, assignment.status),
                      ),
                      const Spacer(),
                      if (assignment.status == AssignmentStatus.notSubmitted)
                        FilledButton(
                          onPressed: () {
                            context.pushNamed(
                              SubmitPage.routeName,
                              pathParameters: {'id': assignment.id},
                            );
                          },
                          child: const Text('去提交'),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            context.pushNamed(
                              ResultPage.routeName,
                              pathParameters: {'sid': assignment.id},
                            );
                          },
                          child: const Text('查看'),
                        ),
                    ],
                  ),
                  if (assignment.score != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('分数：${assignment.score}'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.notSubmitted:
        return '未提交';
      case AssignmentStatus.submitted:
        return '已提交';
      case AssignmentStatus.graded:
        return '已判分';
    }
  }

  Color _statusColor(BuildContext context, AssignmentStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case AssignmentStatus.notSubmitted:
        return scheme.surfaceVariant;
      case AssignmentStatus.submitted:
        return scheme.tertiaryContainer;
      case AssignmentStatus.graded:
        return scheme.secondaryContainer;
    }
  }
}
