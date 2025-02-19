import 'package:chronolapse/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (
      tester,
    ) async {
      // Load app widget.
      await tester.pumpWidget(const MyApp());

      const MethodChannel platform =
          MethodChannel('com.example.chronolapse/channel');

      expect(await platform.invokeMethod("testFunction", {"count": 4}), 5);
    });

    testWidgets('tap on the floating action button, verify counter 2', (
      tester,
    ) async {
      // Load app widget.
      await tester.pumpWidget(const MyApp());

      const MethodChannel platform =
          MethodChannel('com.example.chronolapse/channel');

      expect(await platform.invokeMethod("testFunction", {"count": 3}), 4);
    });
  });

  print("Done");
}
