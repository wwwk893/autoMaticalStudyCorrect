import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../networking/dio_client.dart';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  final logger = ref.watch(loggerProvider);
  return AnalyticsService(logger);
});

class AnalyticsService {
  AnalyticsService(this._logger);

  final Logger _logger;

  void logEvent(String name, [Map<String, dynamic>? params]) {
    _logger.i('Analytics event: $name $params');
  }

  void logLoginSuccess(String userId) {
    logEvent('login_success', {'userId': userId});
  }

  void logSubmissionCreated(String submissionId, int pageCount) {
    logEvent('submission_created', {
      'submissionId': submissionId,
      'pageCount': pageCount,
    });
  }

  void logGradingDuration(String submissionId, Duration duration) {
    logEvent('grading_duration', {
      'submissionId': submissionId,
      'durationMs': duration.inMilliseconds,
    });
  }
}
