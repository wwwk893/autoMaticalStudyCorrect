import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_matical_study_correct/app.dart';

void main() {
  testWidgets('renders login screen on start', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HomeworkApp()));
    await tester.pumpAndSettle();
    expect(find.textContaining('登录'), findsWidgets);
  });
}
