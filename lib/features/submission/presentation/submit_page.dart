import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/submission_controller.dart';
import '../models/submission.dart';

class SubmitPage extends ConsumerStatefulWidget {
  const SubmitPage({super.key, required this.assignmentId});

  static const routeName = 'submit';

  final String assignmentId;

  @override
  ConsumerState<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends ConsumerState<SubmitPage> {
  int _imageCount = 1;

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(submissionControllerProvider);
    final controller = ref.read(submissionControllerProvider.notifier);
    final current = submissionState.current;

    return Scaffold(
      appBar: AppBar(
        title: Text('提交：${widget.assignmentId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模拟拍照上传流程',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('选择需要上传的图片数量（模拟批量拍照）：$_imageCount'),
            Slider(
              value: _imageCount.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _imageCount.toString(),
              onChanged: (value) {
                setState(() {
                  _imageCount = value.toInt();
                });
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: submissionState.isUploading
                  ? null
                  : () {
                      controller.create(
                        assignmentId: widget.assignmentId,
                        imageCount: _imageCount,
                      );
                    },
              icon: const Icon(Icons.camera_alt),
              label: const Text('开始上传'),
            ),
            const SizedBox(height: 24),
            if (submissionState.isUploading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('上传进度：${(submissionState.progress * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: submissionState.progress),
                ],
              ),
            const SizedBox(height: 24),
            Expanded(
              child: current == null
                  ? const Center(
                      child: Text('暂无提交记录，点击“开始上传”模拟一次完整流程。'),
                    )
                  : _StatusTimeline(status: current.status),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: SubmissionStatus.values.map((item) {
        final reached = item.index <= status.index;
        return ListTile(
          leading: Icon(
            reached ? Icons.check_circle : Icons.radio_button_unchecked,
            color: reached
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          title: Text(_label(item)),
          subtitle: Text(_description(item)),
        );
      }).toList(),
    );
  }

  String _label(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.queued:
        return '排队中';
      case SubmissionStatus.ocr:
        return 'OCR 识别';
      case SubmissionStatus.parsed:
        return '解析中';
      case SubmissionStatus.graded:
        return '判分完成';
      case SubmissionStatus.reported:
        return '报告生成';
    }
  }

  String _description(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.queued:
        return '等待上传到云端并准备 OCR。';
      case SubmissionStatus.ocr:
        return '执行图像矫正与 OCR 提取文本。';
      case SubmissionStatus.parsed:
        return '结构化题目与答案，准备判分。';
      case SubmissionStatus.graded:
        return '根据标准答案计算得分。';
      case SubmissionStatus.reported:
        return '生成错因解析与报告。';
    }
  }
}
