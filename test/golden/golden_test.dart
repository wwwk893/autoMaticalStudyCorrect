import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
const _goldenNames = <String>[
  'assignment_card',
  'upload_progress',
  'review_page',
];

Future<void> _materializeGolden(String name) async {
  final pngFile = File('test/golden/$name.png');
  if (await pngFile.exists()) {
    return;
  }

  final encodedFile = File('${pngFile.path}.b64');
  if (!await encodedFile.exists()) {
    throw StateError('Missing base64 reference for golden $name');
  }

  final encoded = await encodedFile.readAsString();
  final bytes = base64Decode(encoded);
  await pngFile.writeAsBytes(bytes, flush: true);
}

Future<void> _cleanupGolden(String name) async {
  final pngFile = File('test/golden/$name.png');
  if (await pngFile.exists()) {
    await pngFile.delete();
  }
}

void main() {
  setUpAll(() async {
    for (final name in _goldenNames) {
      await _materializeGolden(name);
    }
  });

  tearDownAll(() async {
    for (final name in _goldenNames) {
      await _cleanupGolden(name);
    }
  });

  testWidgets('assignment card golden', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Placeholder()));
    await expectLater(
      find.byType(Placeholder),
      matchesGoldenFile('test/golden/assignment_card.png'),
    );
  });

  testWidgets('upload progress golden', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LinearProgressIndicator(value: 0.5)));
    await expectLater(
      find.byType(LinearProgressIndicator),
      matchesGoldenFile('test/golden/upload_progress.png'),
    );
  });

  testWidgets('review page golden', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Icon(Icons.analytics)));
    await expectLater(
      find.byType(Icon),
      matchesGoldenFile('test/golden/review_page.png'),
    );
  });
}
