import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Generate Video', (WidgetTester tester) async {
    await setup();
    await tester.pumpWidget(const AppRoot(DashboardPage()));
    await tester.pumpAndSettle();

    final buttonFinder = //find.byKey(const Key("create_new_project"));//text("Create New");
        find.text("Create New");
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    final projectNameFinder = find.text("Enter project name");
    expect(projectNameFinder, findsOneWidget);
    /*
    final projectCreateFinder = find.text("Create");
    expect(projectCreateFinder, findsOneWidget);

    //MAYBE TAP???
    await tester.enterText(projectNameFinder, "video_generation_test_project");
    */
  });
}
