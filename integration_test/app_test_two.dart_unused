import 'package:chronolapse/native_methods/test_function.dart'
    as native_methods;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chronolapse/main.dart' as app;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  print("Waiting 4 seconds for app to load");
  await Future.delayed(const Duration(seconds: 4));

  testWidgets('Counter increments', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(await native_methods.testFunction(3), 4);
  });

  testWidgets('Long Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 10));

    expect(await native_methods.testFunction(3), 4);
  });
}
