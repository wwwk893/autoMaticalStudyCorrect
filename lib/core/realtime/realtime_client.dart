import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';
import '../network/api_client.dart';
import '../../features/submission/state/submission_models.dart';

final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(loggerProvider);
  return RealtimeClient(config: config, logger: logger);
});

class RealtimeClient {
  RealtimeClient({required this.config, required Logger logger})
      : _logger = logger;

  final EnvConfig config;
  final Logger _logger;

  Stream<SubmissionStage> watchSubmission(String submissionId) {
    final controller = StreamController<SubmissionStage>();
    WebSocketChannel? channel;
    Timer? fallbackTimer;

    void emitStages() {
      fallbackTimer?.cancel();
      fallbackTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (timer.tick - 1 >= SubmissionStage.values.length) {
          controller.add(SubmissionStage.reported);
          timer.cancel();
          controller.close();
        } else {
          controller.add(SubmissionStage.values[timer.tick - 1]);
        }
      });
    }

    Future<void>.delayed(Duration.zero, () {
      try {
        final uri = config.wsEndpoint.replace(
          queryParameters: {
            'topic': 'submission',
            'id': submissionId,
          },
        );
        channel = WebSocketChannel.connect(uri);
        channel!.stream.listen(
          (event) {
            final stage = SubmissionStageExt.tryParse(event.toString());
            if (stage != null) {
              controller.add(stage);
            }
          },
          onDone: () {
            emitStages();
          },
          onError: (error, stackTrace) {
            _logger.w('WebSocket error: $error');
            emitStages();
          },
        );
      } catch (error, stackTrace) {
        _logger.w('WebSocket connect failed, fallback to polling', error, stackTrace);
        emitStages();
      }
    });

    controller.onCancel = () {
      channel?.sink.close();
      fallbackTimer?.cancel();
    };
    return controller.stream;
  }
}
