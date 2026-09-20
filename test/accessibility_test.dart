import 'package:flutter_test/flutter_test.dart';

import 'package:utilia/main_premium.dart';

void main() {
  testWidgets('UTILIA meets Android tap target accessibility guideline',
      (tester) async {
    final semantics = tester.ensureSemantics();
    Object? failure;
    StackTrace? failureStack;

    await tester.pumpWidget(const UtiliaPremiumApp());
    await tester.pumpAndSettle();

    try {
      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
      );
    } catch (error, stackTrace) {
      failure = error;
      failureStack = stackTrace;
    } finally {
      semantics.dispose();
    }

    if (failure != null) {
      Error.throwWithStackTrace(failure, failureStack!);
    }
  });
}
