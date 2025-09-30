import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/assignments/presentation/assignment_list_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/result/presentation/result_page.dart';
import 'features/submission/presentation/submit_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/assignments',
        name: AssignmentListPage.routeName,
        builder: (context, state) => const AssignmentListPage(),
      ),
      GoRoute(
        path: '/submit/:id',
        name: SubmitPage.routeName,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubmitPage(assignmentId: id);
        },
      ),
      GoRoute(
        path: '/result/:sid',
        name: ResultPage.routeName,
        builder: (context, state) {
          final submissionId = state.pathParameters['sid']!;
          return ResultPage(submissionId: submissionId);
        },
      ),
    ],
  );
});
