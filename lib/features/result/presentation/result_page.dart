import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../submission/state/submission_controller.dart';
import '../../submission/state/submission_models.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key, required this.submissionId});

  static const routeName = 'result';

  final String submissionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(submissionControllerProvider);
    final submission = state.history.firstWhere(
      (element) => element.id == submissionId,
      orElse: () => state.active ??
          SubmissionSummary(
            id: submissionId,
            assignmentId: submissionId,
            stage: SubmissionStage.reported,
            score: 90,
          ),
    );
    final isChinese = submission.assignmentId.contains('cn');

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.review),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('提交编号：${submission.id}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('当前状态：${submission.stage.badgeLabel}'),
          if (submission.score != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('得分：${submission.score}/100'),
            ),
          const SizedBox(height: 24),
          if (isChinese)
            const _ChineseResultSection()
          else
            const _MathResultSection(),
        ],
      ),
    );
  }
}

class _ChineseResultSection extends StatelessWidget {
  const _ChineseResultSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('语文·古诗词默写',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('第1题（1分/行）'),
            const SizedBox(height: 8),
            const Text('标准答案：春眠不觉晓'),
            const SizedBox(height: 4),
            RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 16),
                children: [
                  TextSpan(text: '你的答案：春眠不觉'),
                  TextSpan(
                    text: '小',
                    style: TextStyle(
                      backgroundColor: Color(0xFFFFCDD2),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('错因：错别字')),
                Chip(label: Text('建议：加强默写练习')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MathResultSection extends StatelessWidget {
  const _MathResultSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('数学·等式等价验证',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('你的答案： (x + 1)^2'),
            const Text('标准答案： x^2 + 2x + 1'),
            const SizedBox(height: 12),
            DataTable(columns: const [
              DataColumn(label: Text('x')),
              DataColumn(label: Text('学生答案')),
              DataColumn(label: Text('标准答案')),
            ], rows: const [
              DataRow(cells: [
                DataCell(Text('1.2')),
                DataCell(Text('5.04')),
                DataCell(Text('5.04')),
              ]),
              DataRow(cells: [
                DataCell(Text('-0.5')),
                DataCell(Text('0.25')),
                DataCell(Text('0.25')),
              ]),
            ]),
            const SizedBox(height: 12),
            const Text('✅ 在采样点上等价，表达式正确。'),
          ],
        ),
      ),
    );
  }
}
