import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';

class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  static const routeName = 'review';

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  String _selectedFilter = 'reason';
  int _topN = 3;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cards = _selectedFilter == 'reason'
        ? _mockReasons.take(_topN).toList()
        : _mockKnowledge.take(_topN).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.review),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已提交导出请求')),
              );
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('导出'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text('错因 TopN'),
                  selected: _selectedFilter == 'reason',
                  onSelected: (value) {
                    setState(() => _selectedFilter = 'reason');
                  },
                ),
                ChoiceChip(
                  label: const Text('知识点'),
                  selected: _selectedFilter == 'knowledge',
                  onSelected: (value) {
                    setState(() => _selectedFilter = 'knowledge');
                  },
                ),
                DropdownButton<int>(
                  value: _topN,
                  items: const [3, 5, 10]
                      .map((value) => DropdownMenuItem(value: value, child: Text('Top$value')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _topN = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(card.description),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: card.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewCardData {
  const ReviewCardData({
    required this.title,
    required this.description,
    this.tags = const [],
  });

  final String title;
  final String description;
  final List<String> tags;
}

const _mockReasons = [
  ReviewCardData(
    title: '错因：书写错误',
    description: '共 12 题出现错别字，集中在“晓/消”、“荷/菏”等同音字。',
    tags: ['建议：错字本训练', '注意：同音字'],
  ),
  ReviewCardData(
    title: '错因：步骤漏写',
    description: '数学题目 8 次未写出关键步骤，导致扣分。',
    tags: ['建议：演算板', '评分规则'],
  ),
  ReviewCardData(
    title: '错因：粗心漏题',
    description: '英语阅读题 3 次未勾选答案。',
    tags: ['注意：提交前检查'],
  ),
];

const _mockKnowledge = [
  ReviewCardData(
    title: '知识点：古诗词默写',
    description: '错误率 37%，重点关注《春晓》《静夜思》。',
    tags: ['语文', '背诵'],
  ),
  ReviewCardData(
    title: '知识点：二次函数',
    description: '函数求值、配方法易错。',
    tags: ['数学', '函数'],
  ),
  ReviewCardData(
    title: '知识点：单词拼写',
    description: '错词 Top5：science、language、exercise...',
    tags: ['英语', '拼写'],
  ),
];
