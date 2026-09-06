import 'package:flutter_test/flutter_test.dart';

double pct(double amount, double percent) => amount * percent / 100;
double discount(double price, double percent) => price - pct(price, percent);
double fuelCost(double km, double litresPer100Km, double pricePerLitre) => km * litresPer100Km / 100 * pricePerLitre;

double ivaAdd(double base, double rate) => base * (1 + rate / 100);
double ivaRemove(double total, double rate) => total / (1 + rate / 100);

void main() {
  group('UTILIA calculations', () {
    test('percentage', () => expect(pct(100, 21), 21));
    test('discount', () => expect(discount(100, 20), 80));
    test('fuel cost', () => expect(fuelCost(300, 6.5, 1.55), closeTo(30.225, 0.001)));
    test('IVA add', () => expect(ivaAdd(100, 21), 121));
    test('IVA remove', () => expect(ivaRemove(121, 21), closeTo(100, 0.0001)));
  });
}
