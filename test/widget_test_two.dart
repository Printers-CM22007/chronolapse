// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chronolapse/backend/timelapse_storage/timelapse_metadata.dart';
import 'package:chronolapse/util/test_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('T2', (WidgetTester tester) async {
    await tester.pumpAndSettle();
    // await TimelapseStore.initialise();
    // // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp());
    //
    // await Future.delayed(const Duration(seconds: 2));
    expect(testFunctionTwo(), 2);
  });

  testWidgets('T3', (WidgetTester tester) async {
    await tester.pumpAndSettle();
    // await TimelapseStore.initialise();
    // // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp());
    //
    // await Future.delayed(const Duration(seconds: 2));
    final data = TimelapseMetaData.initial("testProject");
    expect(data.projectName, "testProject");
    expect(data.frames.length, 0);
  });
}
