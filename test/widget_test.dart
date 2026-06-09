import 'package:flutter_test/flutter_test.dart';
import 'package:hackathon_thing/main.dart';

void main() {
  testWidgets('Peejays application smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title "Peejays" renders on screen.
    expect(find.text('Peejays'), findsOneWidget);

    // Verify that the "Recent Entries" header is displayed.
    expect(find.text('Recent Entries'), findsOneWidget);
  });
}
