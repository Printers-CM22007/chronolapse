import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Example Test', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    final counterTextFinder = find.byValueKey('counter');
    final incrementButtonFinder = find.byValueKey('increment');

    test('Waiting 4s for app load', () async {
      await Future.delayed(const Duration(seconds: 5));
    });

    test('starts at 0', () async {
      expect(await driver.getText(counterTextFinder), '0');
    });

    test('increments the counter', () async {
      await driver.tap(incrementButtonFinder);
      expect(await driver.getText(counterTextFinder), '1');
    });
  });
}
