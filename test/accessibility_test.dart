import 'package:flutter_test/flutter_test.dart';

import 'package:utilia/main_premium.dart';

void main() {
  testWidgets('UTILIA meets Android tap target accessibility guideline',
      (tester) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(const UtiliaPremiumApp());
      await tester.pumpAndSettle();

      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
      );
    } finally {
      semantics.dispose();
    }
  });
}
