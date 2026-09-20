double parseNumber(String value) {
  final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
  return parsed != null && parsed.isFinite ? parsed : 0;
}

bool _finite(double value) => value.isFinite;

double percentageOf(double amount, double percent) {
  if (!_finite(amount) || !_finite(percent)) return 0;
  final result = amount * percent / 100;
  return _finite(result) ? result : 0;
}

double discountedPrice(double price, double percent) {
  if (!_finite(price) || !_finite(percent)) return 0;
  final result = price - percentageOf(price, percent);
  return _finite(result) ? result : 0;
}

double priceWithIva(double base, double rate) {
  if (!_finite(base) || !_finite(rate)) return 0;
  final result = base * (1 + rate / 100);
  return _finite(result) ? result : 0;
}

double priceWithoutIva(double total, double rate) {
  if (!_finite(total) || !_finite(rate)) return 0;
  final divisor = 1 + rate / 100;
  if (divisor == 0 || !divisor.isFinite) return 0;
  final result = total / divisor;
  return _finite(result) ? result : 0;
}

double tipAmount(double bill, double percent) => percentageOf(bill, percent);

double tipPerPerson(double bill, double percent, int people) {
  if (!_finite(bill) || !_finite(percent) || people <= 0) return 0;
  final result = (bill + tipAmount(bill, percent)) / people;
  return _finite(result) ? result : 0;
}

double compound(double principal, double annualRate, int years) {
  if (!_finite(principal) || !_finite(annualRate) || years <= 0) {
    return years <= 0 && _finite(principal) ? principal : 0;
  }
  final result = principal * _pow(1 + annualRate / 100, years);
  return _finite(result) ? result : 0;
}

double _pow(double base, int exponent) {
  if (!_finite(base) || exponent < 0) return double.nan;
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= base;
    if (!_finite(result)) return double.nan;
  }
  return result;
}

double fuelLitres(double km, double litresPer100Km) {
  if (!_finite(km) || !_finite(litresPer100Km)) return 0;
  final result = km * litresPer100Km / 100;
  return _finite(result) ? result : 0;
}

double fuelCost(double km, double litresPer100Km, double pricePerLitre) {
  if (!_finite(pricePerLitre)) return 0;
  final result = fuelLitres(km, litresPer100Km) * pricePerLitre;
  return _finite(result) ? result : 0;
}

double costPerKm(double totalCost, double km) {
  if (!_finite(totalCost) || !_finite(km) || km <= 0) return 0;
  final result = totalCost / km;
  return _finite(result) ? result : 0;
}

double area(double length, double width) {
  if (!_finite(length) || !_finite(width)) return 0;
  final result = length * width;
  return _finite(result) ? result : 0;
}

double paintLitres(
  double wallArea,
  double coverageM2PerLitre, {
  int coats = 2,
}) {
  if (!_finite(wallArea) ||
      !_finite(coverageM2PerLitre) ||
      coverageM2PerLitre <= 0 ||
      coats <= 0) {
    return 0;
  }
  final result = wallArea * coats / coverageM2PerLitre;
  return _finite(result) ? result : 0;
}

double electricityCost(
  double watts,
  double hoursPerDay,
  double days,
  double pricePerKwh,
) {
  if (!_finite(watts) ||
      !_finite(hoursPerDay) ||
      !_finite(days) ||
      !_finite(pricePerKwh)) {
    return 0;
  }
  final result = watts / 1000 * hoursPerDay * days * pricePerKwh;
  return _finite(result) ? result : 0;
}

double bmi(double kg, double heightCm) {
  if (!_finite(kg) || !_finite(heightCm)) return 0;
  final m = heightCm / 100;
  if (m <= 0 || !m.isFinite) return 0;
  final result = kg / (m * m);
  return _finite(result) ? result : 0;
}

double gradeAverage(List<double> grades) {
  if (grades.isEmpty || grades.any((grade) => !_finite(grade))) return 0;
  final result = grades.reduce((a, b) => a + b) / grades.length;
  return _finite(result) ? result : 0;
}

double ruleOfThree(double a, double b, double c) {
  if (!_finite(a) || !_finite(b) || !_finite(c) || a == 0) return 0;
  final result = b * c / a;
  return _finite(result) ? result : 0;
}

double loanPayment(double principal, double annualRate, int months) {
  if (!_finite(principal) || !_finite(annualRate) || months <= 0) return 0;
  final r = annualRate / 100 / 12;
  if (!r.isFinite) return 0;
  if (r == 0) return principal / months;
  final base = 1 + r;
  if (base <= 0 || !base.isFinite) return 0;
  final factor = _pow(base, months);
  final denominator = factor - 1;
  if (denominator == 0 || !denominator.isFinite || !factor.isFinite) {
    return 0;
  }
  final payment = principal * r * factor / denominator;
  return payment.isFinite ? payment : 0;
}

double ageInYears(DateTime birthDate, [DateTime? today]) {
  final now = today ?? DateTime.now();
  var years = now.year - birthDate.year;
  final birthdayPassed =
      now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!birthdayPassed) years--;
  return years < 0 ? 0 : years.toDouble();
}

int dateDifferenceDays(DateTime from, DateTime to) =>
    to.difference(from).inDays.abs();

double workHours(double startHour, double endHour, double breakMinutes) {
  if (!_finite(startHour) || !_finite(endHour) || !_finite(breakMinutes)) {
    return 0;
  }
  var hours = endHour - startHour;
  if (hours < 0) hours += 24;
  hours -= breakMinutes / 60;
  return hours < 0 || !hours.isFinite ? 0 : hours;
}

int countdownSeconds(int hours, int minutes, int seconds) =>
    hours * 3600 + minutes * 60 + seconds;

const lengthFactors = <String, double>{
  'mm': 0.001,
  'cm': 0.01,
  'm': 1,
  'km': 1000,
  'in': 0.0254,
  'ft': 0.3048,
  'yd': 0.9144,
  'mi': 1609.344,
};

const weightFactors = <String, double>{
  'mg': 0.000001,
  'g': 0.001,
  'kg': 1,
  't': 1000,
  'oz': 0.028349523125,
  'lb': 0.45359237,
};

double metresToLength(double value, String unit) {
  final factor = lengthFactors[unit];
  if (factor == null || !_finite(value)) return double.nan;
  final result = value * factor;
  return _finite(result) ? result : double.nan;
}

double convertLength(double value, String from, String to) {
  final fromFactor = lengthFactors[from];
  final toFactor = lengthFactors[to];
  if (fromFactor == null || toFactor == null || !_finite(value)) {
    return double.nan;
  }
  final result = value * fromFactor / toFactor;
  return _finite(result) ? result : double.nan;
}

double convertWeight(double value, String from, String to) {
  final fromFactor = weightFactors[from];
  final toFactor = weightFactors[to];
  if (fromFactor == null || toFactor == null || !_finite(value)) {
    return double.nan;
  }
  final result = value * fromFactor / toFactor;
  return _finite(result) ? result : double.nan;
}
