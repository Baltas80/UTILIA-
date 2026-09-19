import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/calculator_suite.dart';

void main() {
  group('CalculatorParser', () {
    test('handles arithmetic and precedence', () {
      expect(CalculatorParser('2+3*4').parse(), 14);
      expect(CalculatorParser('(2+3)*4').parse(), 20);
      expect(CalculatorParser('2^3^2').parse(), 512);
    });

    test('supports decimal commas and unary operators', () {
      expect(CalculatorParser('-2,5 + 1').parse(), closeTo(-1.5, 1e-12));
    });

    test('rejects division by zero', () {
      expect(() => CalculatorParser('10/0').parse(), throwsFormatException);
      expect(() => CalculatorParser('10÷(2-2)').parse(),
          throwsFormatException);
    });

    test('rejects non-finite powers', () {
      expect(() => CalculatorParser('2^10000').parse(), throwsFormatException);
    });

    test('rejects malformed input', () {
      expect(() => CalculatorParser('(2+3').parse(), throwsFormatException);
      expect(() => CalculatorParser('2+').parse(), throwsFormatException);
    });
  });
}
