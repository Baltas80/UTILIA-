import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/calculations.dart';

void main() {
  group('UTILIA calculations', () {
    test('percentage', () => expect(percentageOf(100, 21), 21));
    test('discount', () => expect(discountedPrice(100, 20), 80));
    test('fuel cost', () => expect(fuelCost(300, 6.5, 1.55), closeTo(30.225, 0.001)));
    test('IVA add', () => expect(priceWithIva(100, 21), 121));
    test('IVA remove', () => expect(priceWithoutIva(121, 21), closeTo(100, 0.0001)));
    test('tip per person', () => expect(tipPerPerson(100, 10, 2), 55));
    test('loan payment', () => expect(loanPayment(1200, 0, 12), 100));
    test('compound interest', () => expect(compound(1000, 10, 2), closeTo(1210, 0.001)));
    test('area', () => expect(area(5, 4), 20));
    test('paint', () => expect(paintLitres(40, 10), 8));
    test('electricity', () => expect(electricityCost(1000, 2, 30, .20), 12));
    test('BMI', () => expect(bmi(80, 180), closeTo(24.691, .001)));
    test('grade average', () => expect(gradeAverage([5, 7, 8]), closeTo(6.6667, .001)));
    test('rule of three', () => expect(ruleOfThree(2, 3, 4), 6));
    test('age', () {
      final birth = DateTime(2000, 9, 6);
      expect(ageInYears(birth, DateTime(2026, 9, 6)), 26);
    });
    test('date difference', () {
      expect(dateDifferenceDays(DateTime(2026, 1, 1), DateTime(2026, 1, 11)), 10);
    });
    test('work hours', () => expect(workHours(8, 17, 60), 8));
    test('countdown seconds', () => expect(countdownSeconds(1, 2, 3), 3723));
    test('length conversion', () => expect(convertLength(1, 'km', 'm'), 1000));
    test('weight conversion', () => expect(convertWeight(1, 'kg', 'g'), 1000));
  });
}
