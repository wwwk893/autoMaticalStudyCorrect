import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment { dev, stg, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.webSocketUrl,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String webSocketUrl;
}

const devConfig = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: 'https://dev-api.example.com',
  webSocketUrl: 'wss://dev-ws.example.com',
);

const stgConfig = AppConfig(
  environment: AppEnvironment.stg,
  apiBaseUrl: 'https://stg-api.example.com',
  webSocketUrl: 'wss://stg-ws.example.com',
);

const prodConfig = AppConfig(
  environment: AppEnvironment.prod,
  apiBaseUrl: 'https://prod-api.example.com',
  webSocketUrl: 'wss://prod-ws.example.com',
);

final appConfigProvider = Provider<AppConfig>((ref) => devConfig);
