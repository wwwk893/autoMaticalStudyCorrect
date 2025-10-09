import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../../../core/utils/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../submission/state/submission_controller.dart';
import '../../submission/state/submission_models.dart';
import '../application/upload_controller.dart';
import '../../../utils/image_preprocess.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key, required this.assignmentId});

  final String assignmentId;

  static const routeName = 'upload';

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final _uuid = const Uuid();
  final List<_DraftPage> _pages = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final uploadState = ref.watch(uploadControllerProvider);
    final progress = uploadState.progress;
    final compression = uploadState.compressionRatio;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.upload),
        actions: [
          IconButton(
            onPressed: () => _showLanguageSheet(context),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.homeGreeting, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: _pages.isEmpty
                    ? Center(
                        child: Text(loc.queueEmpty),
                      )
                    : ReorderableListView.builder(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _pages.removeAt(oldIndex);
                            _pages.insert(newIndex, item);
                            for (var i = 0; i < _pages.length; i++) {
                              _pages[i] = _pages[i].reorder(i + 1);
                            }
                          });
                        },
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          final page = _pages[index];
                          return Card(
                            key: ValueKey(page.id),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${page.payload.order}')),
                              title: Text('Page ${page.payload.order}'),
                              subtitle: Text(
                                '压缩比: ${page.payload.processed.compressionRatio.toStringAsFixed(2)}x',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() {
                                    _pages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_pages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: progress == 0 ? null : progress),
                    const SizedBox(height: 8),
                    Text('压缩后平均比：${compression.toStringAsFixed(2)}x'),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('拍摄/导入'),
                      onPressed: _isSubmitting ? null : _handleAddPage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(_isSubmitting ? '提交中…' : loc.upload),
                      onPressed: _pages.isEmpty || _isSubmitting
                          ? null
                          : () => _handleSubmit(context),
                    ),
                  ),
                ],
              ),
              if (uploadState.status == UploadStatus.failure &&
                  uploadState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    uploadState.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddPage() async {
    final bytes = await _generateMockImage();
    final processed = await preprocessForUpload(bytes);
    setState(() {
      final payload = SubmissionPagePayload(
        localPath: 'local://${_uuid.v4()}',
        processed: processed,
        order: _pages.length + 1,
      );
      _pages.add(_DraftPage(id: _uuid.v4(), payload: payload));
    });
  }

  Future<void> _handleSubmit(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });
    final pages = _pages.map((p) => p.payload).toList();
    try {
      final submissionId = await ref
          .read(submissionControllerProvider.notifier)
          .createSubmission(
            assignmentId: widget.assignmentId,
            pages: pages,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交成功：$submissionId')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败：$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<Uint8List> _generateMockImage() async {
    final rand = Random();
    final width = 1200;
    final height = 1800;
    final image = img.Image(width, height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        image.setPixelRgba(x, y, 255, 255, 255);
      }
    }
    img.drawString(image, img.arial_48, 60, 80, 'Page ${_pages.length + 1}');
    img.drawString(image, img.arial_24, 60, 160, 'Mock content ${rand.nextInt(999)}');
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('中文'),
                onTap: () {
                  ref.read(localeControllerProvider.notifier).switchTo(
                        const Locale('zh'),
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  ref.read(localeControllerProvider.notifier).switchTo(
                        const Locale('en'),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraftPage {
  const _DraftPage({required this.id, required this.payload});

  final String id;
  final SubmissionPagePayload payload;

  _DraftPage reorder(int order) {
    return _DraftPage(
      id: id,
      payload: SubmissionPagePayload(
        localPath: payload.localPath,
        processed: payload.processed,
        order: order,
      ),
    );
  }
}
