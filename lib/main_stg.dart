import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();
  await EnvLoader.ensureInitialized(logger: logger);
  const config = EnvConfig(
    flavor: AppFlavor.staging,
    apiBaseUrl: Uri.parse('https://stg-api.example.com'),
    wsEndpoint: Uri.parse('wss://stg-api.example.com/ws'),
    objectStorageEndpoint: Uri.parse('https://stg-storage.example.com'),
  );
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const HomeworkApp(),
    ),
  );
}
