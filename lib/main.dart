import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();
  FlutterError.onError = (details) {
    logger.e('Flutter error', details.exception, details.stack);
  };
  await EnvLoader.ensureInitialized(logger: logger);
  runApp(const ProviderScope(child: HomeworkApp()));
}
