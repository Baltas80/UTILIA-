import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/calculations.dart';

void main() {
  test('IVA can be added and removed', () {
    expect(priceWithIva(100, 21), closeTo(121, 0.0001));
    expect(priceWithoutIva(121, 21), closeTo(100, 0.0001));
  });
  test('loan payment is deterministic', () {
    expect(loanPayment(10000, 5, 12), closeTo(856.0748, 0.01));
  });
  test('fuel and vehicle costs', () {
    expect(fuelLitres(500, 6), closeTo(30, 0.0001));
    expect(fuelCost(500, 6, 1.5), closeTo(45, 0.0001));
    expect(costPerKm(45, 500), closeTo(0.09, 0.0001));
  });
  test('home and health calculations', () {
    expect(area(5, 4), 20);
    expect(paintLitres(40, 10), 8);
    expect(bmi(80, 180), closeTo(24.6914, 0.001));
  });
  test('study and proportion calculations', () {
    expect(gradeAverage([5, 7, 9]), closeTo(7, 0.0001));
    expect(ruleOfThree(2, 10, 3), 15);
  });
}
