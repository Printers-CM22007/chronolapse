import 'package:chronolapse/native_methods/test_function.dart'
as native_methods;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Basic Native Method Test', (WidgetTester tester) async {
    expect(await native_methods.testFunction(3), 4);
  });
}
