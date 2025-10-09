import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Supported application flavors.
enum AppFlavor { dev, staging, prod }

/// Immutable environment configuration loaded at bootstrap.
class EnvConfig {
  const EnvConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.wsEndpoint,
    required this.objectStorageEndpoint,
    this.enableMockReview = false,
  });

  final AppFlavor flavor;
  final Uri apiBaseUrl;
  final Uri wsEndpoint;
  final Uri objectStorageEndpoint;
  final bool enableMockReview;

  static EnvConfig load({Logger? logger}) {
    final flavorName = EnvLoader.get('APP_FLAVOR', 'dev');
    final flavor = AppFlavor.values.firstWhere(
      (f) => f.name == flavorName,
      orElse: () => AppFlavor.dev,
    );
    logger?.i('Loading configuration for flavor=$flavorName');
    return EnvConfig(
      flavor: flavor,
      apiBaseUrl: Uri.parse(
        EnvLoader.get('API_BASE_URL', 'https://api.dev.example.com'),
      ),
      wsEndpoint: Uri.parse(
        EnvLoader.get('WS_ENDPOINT', 'wss://api.dev.example.com/ws'),
      ),
      objectStorageEndpoint: Uri.parse(
        EnvLoader.get(
          'OBJECT_STORAGE_ENDPOINT',
          'https://storage.dev.example.com',
        ),
      ),
      enableMockReview:
          EnvLoader.get('ENABLE_MOCK_REVIEW', 'false').toLowerCase() == 'true',
    );
  }
}

/// Helper to load values from `.env` files with `--dart-define` fallback.
class EnvLoader {
  static bool _initialized = false;

  static Future<void> ensureInitialized({Logger? logger}) async {
    if (_initialized) return;
    final flavor = const String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');
    final fileName = '.env.$flavor';
    try {
      await dotenv.load(fileName: fileName);
      logger?.i('Loaded dotenv file $fileName');
    } catch (_) {
      logger?.w('Dotenv file $fileName not found, using dart-define values');
    }
    _initialized = true;
  }

  static String get(String key, String fallback) {
    final fromDotEnv = dotenv.maybeGet(key);
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) {
      return fromDotEnv;
    }
    return const String.fromEnvironment(key, defaultValue: fallback);
  }
}
