import 'package:flutter_test/flutter_test.dart';

import 'package:utilia/main_premium.dart';

void main() {
  testWidgets('UTILIA meets Android tap target accessibility guideline',
      (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(const UtiliaPremiumApp());
    await tester.pumpAndSettle();

    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
    );
  });
}
