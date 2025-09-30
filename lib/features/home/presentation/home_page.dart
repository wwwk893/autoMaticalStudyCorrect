import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../assignments/presentation/assignment_list_page.dart';
import '../../submission/controllers/submission_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(submissionSummaryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('自动批作业'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '欢迎回来！',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(summary),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pushNamed(AssignmentListPage.routeName),
              icon: const Icon(Icons.assignment),
              label: const Text('查看作业'),
            ),
          ],
        ),
      ),
    );
  }
}
