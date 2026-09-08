import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/scientific_engine.dart';

void main() {
  group('ScientificEngine', () {
    test('evaluates arithmetic and precedence', () {
      expect(ScientificEngine.evaluate('2+3*4'), 14);
      expect(ScientificEngine.evaluate('(2+3)*4'), 20);
      expect(ScientificEngine.evaluate('2^3^2'), 512);
    });

    test('accepts decimal comma and unary signs', () {
      expect(ScientificEngine.evaluate('-2,5 + +1'), closeTo(-1.5, 1e-12));
    });

    test('supports degree and radian trigonometry', () {
      expect(ScientificEngine.evaluate('sin(90)'), closeTo(1, 1e-12));
      expect(ScientificEngine.evaluate('sin(pi/2)', degrees: false),
          closeTo(1, 1e-12));
      expect(ScientificEngine.evaluate('asin(1)'), closeTo(90, 1e-12));
    });

    test('supports logarithms, roots, constants and helpers', () {
      expect(ScientificEngine.evaluate('sqrt(16)'), 4);
      expect(ScientificEngine.evaluate('ln(e)'), closeTo(1, 1e-12));
      expect(ScientificEngine.evaluate('log(1000)'), closeTo(3, 1e-12));
      expect(ScientificEngine.evaluate('abs(-7)'), 7);
      expect(ScientificEngine.evaluate('floor(2.9)'), 2);
      expect(ScientificEngine.evaluate('ceil(2.1)'), 3);
      expect(ScientificEngine.evaluate('exp(1)'), closeTo(math.e, 1e-12));
    });

    test('rejects malformed expressions and division by zero', () {
      expect(() => ScientificEngine.evaluate('2/0'), throwsFormatException);
      expect(() => ScientificEngine.evaluate('(2+3'), throwsFormatException);
      expect(
          () => ScientificEngine.evaluate('unknown(2)'), throwsFormatException);
      expect(() => ScientificEngine.evaluate('2+'), throwsFormatException);
    });
  });
}
