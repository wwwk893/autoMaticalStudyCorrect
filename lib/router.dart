import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/assignments/presentation/assignment_list_page.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/settings_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/result/presentation/result_page.dart';
import 'features/review/presentation/review_page.dart';
import 'features/submission/state/submission_controller.dart';
import 'features/upload/presentation/upload_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final notifier = GoRouterRefreshStream(
    ref.watch(submissionControllerProvider.notifier).stream,
  );
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/login',
        name: LoginPage.routeName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'assignments',
            name: AssignmentListPage.routeName,
            builder: (context, state) => const AssignmentListPage(),
          ),
          GoRoute(
            path: 'upload/:id',
            name: UploadPage.routeName,
            builder: (context, state) {
              final assignmentId = state.pathParameters['id']!;
              return UploadPage(assignmentId: assignmentId);
            },
          ),
          GoRoute(
            path: 'result/:sid',
            name: ResultPage.routeName,
            builder: (context, state) {
              final submissionId = state.pathParameters['sid']!;
              return ResultPage(submissionId: submissionId);
            },
          ),
          GoRoute(
            path: 'review',
            name: ReviewPage.routeName,
            builder: (context, state) => const ReviewPage(),
          ),
          GoRoute(
            path: 'settings',
            name: SettingsPage.routeName,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final loggingIn = state.fullPath == '/login';
      if (!isAuthenticated) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn && isAuthenticated) {
        return '/';
      }
      return null;
    },
  );
});
