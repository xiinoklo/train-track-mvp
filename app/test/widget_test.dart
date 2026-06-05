import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('shows login screen when there is no saved token', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TrainTrackApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('TrainTrack'), findsOneWidget);
    expect(find.textContaining('Inicia'), findsOneWidget);
  });
}
