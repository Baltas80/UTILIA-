double parseNumber(String value) => double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;

double percentageOf(double amount, double percent) => amount * percent / 100;
double discountedPrice(double price, double percent) => price - percentageOf(price, percent);
double priceWithIva(double base, double rate) => base * (1 + rate / 100);
double priceWithoutIva(double total, double rate) => total / (1 + rate / 100);
double tipAmount(double bill, double percent) => percentageOf(bill, percent);
double tipPerPerson(double bill, double percent, int people) => people <= 0 ? 0 : (bill + tipAmount(bill, percent)) / people;
double compound(double principal, double annualRate, int years) => principal * _pow(1 + annualRate / 100, years);
double _pow(double base, int exponent) { var result = 1.0; for (var i = 0; i < exponent; i++) { result *= base; } return result; }
double fuelLitres(double km, double litresPer100Km) => km * litresPer100Km / 100;
double fuelCost(double km, double litresPer100Km, double pricePerLitre) => fuelLitres(km, litresPer100Km) * pricePerLitre;
double costPerKm(double totalCost, double km) => km <= 0 ? 0 : totalCost / km;
double area(double length, double width) => length * width;
double paintLitres(double wallArea, double coverageM2PerLitre, {int coats = 2}) => coverageM2PerLitre <= 0 ? 0 : wallArea * coats / coverageM2PerLitre;
double electricityCost(double watts, double hoursPerDay, double days, double pricePerKwh) => watts / 1000 * hoursPerDay * days * pricePerKwh;
double bmi(double kg, double heightCm) { final m = heightCm / 100; return m <= 0 ? 0 : kg / (m * m); }
double gradeAverage(List<double> grades) => grades.isEmpty ? 0 : grades.reduce((a, b) => a + b) / grades.length;
double ruleOfThree(double a, double b, double c) => a == 0 ? 0 : b * c / a;
double loanPayment(double principal, double annualRate, int months) { if (months <= 0) return 0; final r = annualRate / 100 / 12; if (r == 0) return principal / months; final factor = _pow(1 + r, months); return principal * r * factor / (factor - 1); }
