import 'package:flutter_test/flutter_test.dart';
import 'package:runner/main.dart';

void main() {
  testWidgets('App renders connection list', (WidgetTester tester) async {
    await tester.pumpWidget(const RunnerApp());
    expect(find.text('Runner'), findsOneWidget);
  });
}
