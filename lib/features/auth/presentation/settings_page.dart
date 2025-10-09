import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(auth.session?.userId ?? '未登录'),
            subtitle: Text(auth.session?.accessToken.substring(0, 8) ?? ''),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.bindWeChat, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(loc.bindWeChatDescription),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.of(context).pop();
            },
            child: Text(loc.logout),
          ),
        ],
      ),
    );
  }
}
