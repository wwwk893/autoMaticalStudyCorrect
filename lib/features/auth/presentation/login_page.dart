import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const routeName = 'login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginChannel _channel = LoginChannel.email;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.authenticating;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(loc.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              SegmentedButton<LoginChannel>(
                segments: const [
                  ButtonSegment(value: LoginChannel.email, label: Text('邮箱登录')),
                  ButtonSegment(value: LoginChannel.phone, label: Text('手机号登录')),
                ],
                selected: <LoginChannel>{_channel},
                onSelectionChanged: (selection) {
                  setState(() {
                    _channel = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_channel == LoginChannel.email)
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: loc.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                )
              else
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: loc.phoneLabel),
                  keyboardType: TextInputType.phone,
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: loc.passwordLabel),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : () => _submit(context),
                  child: isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : Text(loc.loginButton),
                ),
              ),
              if (authState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    authState.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final notifier = ref.read(authStateProvider.notifier);
    final identifier = _channel == LoginChannel.email
        ? _emailController.text.trim()
        : _phoneController.text.trim();
    if (identifier.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).invalidForm)),
      );
      return;
    }
    notifier.login(
      identifier: identifier,
      password: _passwordController.text,
      channel: _channel,
    );
  }
}
