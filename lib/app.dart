import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/locale_controller.dart';
import 'features/auth/application/auth_controller.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

class HomeworkApp extends ConsumerWidget {
  const HomeworkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated &&
          next.errorMessage != null &&
          router.routerDelegate.navigatorKey.currentContext != null) {
        final ctx = router.routerDelegate.navigatorKey.currentContext!;
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });
    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
    );
  }
}
