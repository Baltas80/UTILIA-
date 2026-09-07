double parseNumber(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;

double percentageOf(double amount, double percent) => amount * percent / 100;
double discountedPrice(double price, double percent) =>
    price - percentageOf(price, percent);
double priceWithIva(double base, double rate) => base * (1 + rate / 100);
double priceWithoutIva(double total, double rate) => total / (1 + rate / 100);
double tipAmount(double bill, double percent) => percentageOf(bill, percent);
double tipPerPerson(double bill, double percent, int people) =>
    people <= 0 ? 0 : (bill + tipAmount(bill, percent)) / people;
double compound(double principal, double annualRate, int years) =>
    years <= 0 ? principal : principal * _pow(1 + annualRate / 100, years);

double _pow(double base, int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}

double fuelLitres(double km, double litresPer100Km) =>
    km * litresPer100Km / 100;
double fuelCost(double km, double litresPer100Km, double pricePerLitre) =>
    fuelLitres(km, litresPer100Km) * pricePerLitre;
double costPerKm(double totalCost, double km) =>
    km <= 0 ? 0 : totalCost / km;
double area(double length, double width) => length * width;
double paintLitres(double wallArea, double coverageM2PerLitre,
        {int coats = 2}) =>
    coverageM2PerLitre <= 0 ? 0 : wallArea * coats / coverageM2PerLitre;
double electricityCost(
        double watts, double hoursPerDay, double days, double pricePerKwh) =>
    watts / 1000 * hoursPerDay * days * pricePerKwh;
double bmi(double kg, double heightCm) {
  final m = heightCm / 100;
  return m <= 0 ? 0 : kg / (m * m);
double gradeAverage(List<double> grades) =>
    grades.isEmpty ? 0 : grades.reduce((a, b) => a + b) / grades.length;
double ruleOfThree(double a, double b, double c) => a == 0 ? 0 : b * c / a;
double loanPayment(double principal, double annualRate, int months) {
  if (months <= 0) return 0;
  final r = annualRate / 100 / 12;
  if (r == 0) return principal / months;
  final factor = _pow(1 + r, months);
  return principal * r * factor / (factor - 1);
}

double ageInYears(DateTime birthDate, [DateTime? today]) {
  final now = today ?? DateTime.now();
  var years = now.year - birthDate.year;
  final birthdayPassed = now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!birthdayPassed) years--;
  return years < 0 ? 0 : years.toDouble();
}

int dateDifferenceDays(DateTime from, DateTime to) =>
    to.difference(from).inDays.abs();

double workHours(double startHour, double endHour, double breakMinutes) {
  var hours = endHour - startHour;
  if (hours < 0) hours += 24;
  hours -= breakMinutes / 60;
  return hours < 0 ? 0 : hours;
}

int countdownSeconds(int hours, int minutes, int seconds) =>
    hours * 3600 + minutes * 60 + seconds;

double metresToLength(double value, String unit) {
  const factors = <String, double>{
    'mm': 0.001,
    'cm': 0.01,
    'm': 1,
    'km': 1000,
    'in': 0.0254,
    'ft': 0.3048,
    'yd': 0.9144,
    'mi': 1609.344,
  };
  return value * (factors[unit] ?? 1);
}

double convertLength(double value, String from, String to) {
  final metres = metresToLength(value, from);
  const factors = <String, double>{
    'mm': 0.001,
    'cm': 0.01,
    'm': 1,
    'km': 1000,
    'in': 0.0254,
    'ft': 0.3048,
    'yd': 0.9144,
    'mi': 1609.344,
  };
  return metres / (factors[to] ?? 1);
}

double convertWeight(double value, String from, String to) {
  const factors = <String, double>{
    'mg': 0.000001,
    'g': 0.001,
    'kg': 1,
    't': 1000,
    'oz': 0.028349523125,
    'lb': 0.45359237,
  };
  final kg = value * (factors[from] ?? 1);
  return kg / (factors[to] ?? 1);
}
