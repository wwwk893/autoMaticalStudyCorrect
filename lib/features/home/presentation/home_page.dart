import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/offline_queue/offline_queue.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/settings_page.dart';
import '../../review/presentation/review_page.dart';
import '../../upload/presentation/upload_page.dart';
import '../../submission/state/submission_controller.dart';
import '../../submission/state/submission_models.dart';
import '../../assignments/presentation/assignment_list_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final submissions = ref.watch(submissionControllerProvider);
    final queue = ref.watch(offlineQueueControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(SettingsPage.routeName),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.homeGreeting, style: Theme.of(context).textTheme.titleLarge),
            if (auth.session != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('ID: ${auth.session!.userId}'),
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: Text(loc.assignments),
                subtitle: const Text('查看班级作业与状态'),
                onTap: () => context.pushNamed(AssignmentListPage.routeName),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: Text(loc.upload),
                subtitle: const Text('拍照上传、弱网重试、分块直传'),
                onTap: () => context.pushNamed(
                  UploadPage.routeName,
                  pathParameters: {'id': 'cn-001'},
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: Text(loc.review),
                subtitle: const Text('错因聚合与讲评页'),
                onTap: () => context.pushNamed(ReviewPage.routeName),
              ),
            ),
            const SizedBox(height: 16),
            Text(loc.progress, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (submissions.active != null)
              _SubmissionBadge(summary: submissions.active!)
            else
              Text(loc.queueEmpty),
            const SizedBox(height: 16),
            Text(loc.offlineQueue, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (queue.tasks.isEmpty)
              Text(loc.queueEmpty)
            else
              Wrap(
                spacing: 8,
                children: queue.tasks
                    .map((task) => Chip(
                          label: Text(task.payload['assignmentId']?.toString() ?? task.id),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionBadge extends StatelessWidget {
  const _SubmissionBadge({required this.summary});

  final SubmissionSummary summary;

  @override
  Widget build(BuildContext context) {
    final stage = summary.stage;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stage.badgeColor,
          child: Text(stage.badgeLabel),
        ),
        title: Text('Submission ${summary.id}'),
        subtitle: LinearProgressIndicator(
          value: (SubmissionStage.values.indexOf(stage) + 1) /
              SubmissionStage.values.length,
        ),
      ),
    );
  }
}
