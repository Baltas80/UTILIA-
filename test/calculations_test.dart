import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/calculations.dart';

void main() {
  group('UTILIA calculations', () {
    test('parse decimal comma', () => expect(parseNumber('12,5'), 12.5));
    test('empty input parses safely', () => expect(parseNumber(''), 0));

    test('percentage', () => expect(percentageOf(100, 21), 21));
    test('percentage decimal', () => expect(percentageOf(80, 12.5), 10));
    test('discount', () => expect(discountedPrice(100, 20), 80));
    test('discount full amount', () => expect(discountedPrice(100, 100), 0));
    test('IVA add', () => expect(priceWithIva(100, 21), 121));
    test('IVA remove',
        () => expect(priceWithoutIva(121, 21), closeTo(100, 0.0001)));

    test('tip per person', () => expect(tipPerPerson(100, 10, 2), 55));
    test('tip with zero people is safe',
        () => expect(tipPerPerson(100, 10, 0), 0));

    test('loan payment zero interest',
        () => expect(loanPayment(1200, 0, 12), 100));
    test('loan payment standard',
        () => expect(loanPayment(10000, 12, 12), closeTo(888.4879, .001)));
    test('loan with invalid months is safe',
        () => expect(loanPayment(1200, 5, 0), 0));

    test('compound interest',
        () => expect(compound(1000, 10, 2), closeTo(1210, 0.001)));
    test('compound zero years returns principal',
        () => expect(compound(1000, 10, 0), 1000));

    test('area', () => expect(area(5, 4), 20));
    test('paint', () => expect(paintLitres(40, 10), 8));
    test('paint custom coats', () => expect(paintLitres(40, 10, coats: 1), 4));
    test('paint invalid coverage is safe', () => expect(paintLitres(40, 0), 0));

    test('electricity', () => expect(electricityCost(1000, 2, 30, .20), 12));
    test('electricity fractional power',
        () => expect(electricityCost(500, 4, 30, .25), 15));
    test('fuel litres', () => expect(fuelLitres(500, 6), 30));
    test('fuel cost', () => expect(fuelCost(500, 6, 1.5), 45));
    test('cost per km', () => expect(costPerKm(45, 500), .09));
    test(
        'cost per km zero distance is safe', () => expect(costPerKm(45, 0), 0));

    test('BMI uses height in centimetres',
        () => expect(bmi(80, 180), closeTo(24.691, .001)));
    test('BMI invalid height is safe', () => expect(bmi(80, 0), 0));

    test('grade average',
        () => expect(gradeAverage([5, 7, 8]), closeTo(6.6667, .001)));
    test('empty grade average is safe', () => expect(gradeAverage([]), 0));
    test('rule of three', () => expect(ruleOfThree(2, 3, 4), 6));
    test('rule of three zero divisor is safe',
        () => expect(ruleOfThree(0, 3, 4), 0));

    test('age', () {
      final birth = DateTime(2000, 9, 6);
      expect(ageInYears(birth, DateTime(2026, 9, 6)), 26);
      expect(ageInYears(birth, DateTime(2026, 9, 5)), 25);
    });

    test('date difference', () {
      expect(
          dateDifferenceDays(DateTime(2026, 1, 1), DateTime(2026, 1, 11)), 10);
      expect(
          dateDifferenceDays(DateTime(2026, 1, 11), DateTime(2026, 1, 1)), 10);
      expect(
          dateDifferenceDays(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
    });

    test('work hours', () => expect(workHours(8, 17, 60), 8));
    test('work hours crossing midnight', () => expect(workHours(22, 6, 0), 8));
    test('negative resulting work hours are safe',
        () => expect(workHours(8, 8, 60), 0));

    test('countdown seconds', () => expect(countdownSeconds(1, 2, 3), 3723));
    test('countdown zero', () => expect(countdownSeconds(0, 0, 0), 0));
    test('length conversion', () => expect(convertLength(1, 'km', 'm'), 1000));
    test('length conversion round trip',
        () => expect(convertLength(250, 'cm', 'm'), 2.5));
    test('length imperial conversion',
        () => expect(convertLength(1, 'mi', 'km'), closeTo(1.609344, .000001)));
    test('invalid length unit returns NaN',
        () => expect(convertLength(1, 'foo', 'm').isNaN, isTrue));
    test('weight conversion', () => expect(convertWeight(1, 'kg', 'g'), 1000));
    test('weight conversion round trip',
        () => expect(convertWeight(1000, 'g', 'kg'), 1));
    test(
        'weight imperial conversion',
        () => expect(
            convertWeight(1, 'lb', 'kg'), closeTo(.45359237, .00000001)));
    test('invalid weight unit returns NaN',
        () => expect(convertWeight(1, 'kg', 'foo').isNaN, isTrue));
  });
}
