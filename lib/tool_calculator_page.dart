import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'calculations.dart';
import 'localization.dart';
import 'models/tool.dart';
import 'storage.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.tool, required this.storage, this.onHistory, required this.s});
  final UtiliaTool tool;
  final UtiliaStorage storage;
  final Future<void> Function()? onHistory;
  final UtiliaStrings s;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final controllers = List.generate(4, (_) => TextEditingController());
  double? result;
  String unit = '';
  String? _fromUnit;
  String? _toUnit;

  @override
  void dispose() {
    for (final c in controllers) c.dispose();
    super.dispose();
  }

  List<String> get labels {
    final id = widget.tool.type.name;
    final count = switch (widget.tool.type) {
      ToolType.age => 1,
      ToolType.dateDifference => 2,
      ToolType.workHours => 3,
      ToolType.countdown => 3,
      ToolType.length => 3,
      ToolType.weight => 3,
      ToolType.bmi => 2,
      ToolType.fuel => 3,
      ToolType.tip => 3,
      ToolType.loan => 3,
      ToolType.compoundInterest => 3,
      ToolType.area => 2,
      ToolType.paint => 2,
      ToolType.electricity => 4,
      ToolType.costPerKm => 2,
      ToolType.gradeAverage => 1,
      ToolType.ruleOfThree => 3,
      _ => 2,
    };
    return List.generate(count, (i) => widget.tool.type == ToolType.electricity && i == 3 ? _priceLabel : widget.s.inputLabel(id, i));
  }

  String get _priceLabel => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => 'Price per kWh (€)',
        UtiliaLanguage.fr => 'Prix du kWh (€)',
        UtiliaLanguage.de => 'Preis pro kWh (€)',
        UtiliaLanguage.it => 'Prezzo per kWh (€)',
        UtiliaLanguage.pt => 'Preço do kWh (€)',
        _ => 'Precio del kWh (€)',
      };

  DateTime? _date(String v) {
    final p = v.trim().split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    final x = DateTime(y, m, d);
    return x.day == d && x.month == m && x.year == y ? x : null;
  }

  String _unit(String es, String en, String fr, String de, String it, String pt) => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => en,
        UtiliaLanguage.fr => fr,
        UtiliaLanguage.de => de,
        UtiliaLanguage.it => it,
        UtiliaLanguage.pt => pt,
        _ => es,
      };

  Map<String, String> get _unitOptions => widget.tool.type == ToolType.length
      ? {
          'mm': _unit('Milímetros (mm)', 'Millimeters (mm)', 'Millimètres (mm)', 'Millimeter (mm)', 'Millimetri (mm)', 'Milímetros (mm)'),
          'cm': _unit('Centímetros (cm)', 'Centimeters (cm)', 'Centimètres (cm)', 'Zentimeter (cm)', 'Centimetri (cm)', 'Centímetros (cm)'),
          'm': _unit('Metros (m)', 'Meters (m)', 'Mètres (m)', 'Meter (m)', 'Metri (m)', 'Metros (m)'),
          'km': _unit('Kilómetros (km)', 'Kilometers (km)', 'Kilomètres (km)', 'Kilometer (km)', 'Chilometri (km)', 'Quilómetros (km)'),
          'in': _unit('Pulgadas (in)', 'Inches (in)', 'Pouces (in)', 'Zoll (in)', 'Pollici (in)', 'Polegadas (in)'),
          'ft': _unit('Pies (ft)', 'Feet (ft)', 'Pieds (ft)', 'Fuß (ft)', 'Piedi (ft)', 'Pés (ft)'),
          'yd': _unit('Yardas (yd)', 'Yards (yd)', 'Yards (yd)', 'Yards (yd)', 'Iarde (yd)', 'Jardas (yd)'),
          'mi': _unit('Millas (mi)', 'Miles (mi)', 'Miles (mi)', 'Meilen (mi)', 'Miglia (mi)', 'Milhas (mi)'),
        }
      : {
          'mg': _unit('Miligramos (mg)', 'Milligrams (mg)', 'Milligrammes (mg)', 'Milligramm (mg)', 'Milligrammi (mg)', 'Miligramas (mg)'),
          'g': _unit('Gramos (g)', 'Grams (g)', 'Grammes (g)', 'Gramm (g)', 'Grammi (g)', 'Gramas (g)'),
          'kg': _unit('Kilogramos (kg)', 'Kilograms (kg)', 'Kilogrammes (kg)', 'Kilogramm (kg)', 'Chilogrammi (kg)', 'Quilogramas (kg)'),
          't': _unit('Toneladas (t)', 'Tonnes (t)', 'Tonnes (t)', 'Tonnen (t)', 'Tonnellate (t)', 'Toneladas (t)'),
          'oz': _unit('Onzas (oz)', 'Ounces (oz)', 'Onces (oz)', 'Unzen (oz)', 'Once (oz)', 'Onças (oz)'),
          'lb': _unit('Libras (lb)', 'Pounds (lb)', 'Livres (lb)', 'Pfund (lb)', 'Libbre (lb)', 'Libras (lb)'),
        };

  bool get _isConverter => widget.tool.type == ToolType.length || widget.tool.type == ToolType.weight;

  bool _needsTextInput(int index) => switch (widget.tool.type) {
        ToolType.age || ToolType.dateDifference => true,
        ToolType.length || ToolType.weight => index > 0,
        ToolType.gradeAverage => true,
        _ => false,
      };

  bool _hasRequiredInputs() {
    for (var i = 0; i < labels.length; i++) {
      if (_isConverter && i > 0) continue;
      if (controllers[i].text.trim().isEmpty) return false;
    }
    if (_isConverter) return _fromUnit != null && _toUnit != null;
    return true;
  }

  bool _validNumber(String value) => double.tryParse(value.trim().replaceAll(',', '.')) != null;

  bool _validInteger(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    return parsed != null && parsed.isFinite && parsed == parsed.truncateToDouble();
  }

  bool _validGradeList(String value) {
    final parts = value.replaceAll(';', ',').split(',').map((e) => e.trim()).toList();
    return parts.isNotEmpty && parts.every((part) => part.isNotEmpty && _validNumber(part));
  }

  bool _validateNumericInputs() {
    if (widget.tool.type == ToolType.gradeAverage) return _validGradeList(controllers[0].text);
    if (widget.tool.type == ToolType.age || widget.tool.type == ToolType.dateDifference) return true;
    for (var i = 0; i < labels.length; i++) {
      if (_isConverter && i > 0) continue;
      if (!_validNumber(controllers[i].text)) return false;
    }
    switch (widget.tool.type) {
      case ToolType.tip:
      case ToolType.loan:
      case ToolType.compoundInterest:
        return _validInteger(controllers[2].text);
      case ToolType.countdown:
        return _validInteger(controllers[0].text) && _validInteger(controllers[1].text) && _validInteger(controllers[2].text);
      default:
        return true;
    }
  }

  bool _validateToolRanges(double x, double y, double z, double price) {
    switch (widget.tool.type) {
      case ToolType.percentage: return x >= 0 && y >= 0;
      case ToolType.discount: return x >= 0 && y >= 0 && y <= 100;
      case ToolType.iva: return x >= 0 && y >= 0 && y <= 100;
      case ToolType.tip: return x >= 0 && y >= 0 && z > 0;
      case ToolType.loan: return x > 0 && y >= 0 && z > 0;
      case ToolType.compoundInterest: return x > 0 && y >= 0 && z > 0;
      case ToolType.area: return x >= 0 && y >= 0;
      case ToolType.paint: return x >= 0 && y > 0;
      case ToolType.electricity: return x >= 0 && y >= 0 && z >= 0 && price >= 0;
      case ToolType.fuel: return x >= 0 && y >= 0 && z >= 0;
      case ToolType.costPerKm: return x >= 0 && y > 0;
      case ToolType.bmi: return x > 0 && y > 0;
      case ToolType.ruleOfThree: return x != 0;
      case ToolType.workHours: return x >= 0 && x <= 24 && y >= 0 && y <= 24 && z >= 0 && z < 1440;
      case ToolType.countdown: return x >= 0 && y >= 0 && y < 60 && z >= 0 && z < 60;
      case ToolType.length:
      case ToolType.weight: return x >= 0;
      case ToolType.age:
      case ToolType.dateDifference:
      case ToolType.gradeAverage:
      case ToolType.calculator:
      case ToolType.scientificCalculator: return true;
    }
  }

  String get _missingFieldsMessage => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => 'Complete all fields.',
        UtiliaLanguage.fr => 'Remplissez tous les champs.',
        UtiliaLanguage.de => 'Füllen Sie alle Felder aus.',
        UtiliaLanguage.it => 'Completa tutti i campi.',
        UtiliaLanguage.pt => 'Preencha todos os campos.',
        _ => 'Completa todos los campos.',
      };

  String get _invalidNumberMessage => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => 'Enter valid numbers.',
        UtiliaLanguage.fr => 'Saisissez des nombres valides.',
        UtiliaLanguage.de => 'Gültige Zahlen eingeben.',
        UtiliaLanguage.it => 'Inserisci numeri validi.',
        UtiliaLanguage.pt => 'Introduza números válidos.',
        _ => 'Introduce números válidos.',
      };

  String get _invalidValueMessage => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => 'Check the values entered.',
        UtiliaLanguage.fr => 'Vérifiez les valeurs saisies.',
        UtiliaLanguage.de => 'Überprüfen Sie die eingegebenen Werte.',
        UtiliaLanguage.it => 'Controlla i valori inseriti.',
        UtiliaLanguage.pt => 'Verifique os valores introduzidos.',
        _ => 'Revisa los valores introducidos.',
      };

  String get _futureDateMessage => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => 'The date cannot be in the future.',
        UtiliaLanguage.fr => 'La date ne peut pas être dans le futur.',
        UtiliaLanguage.de => 'Das Datum darf nicht in der Zukunft liegen.',
        UtiliaLanguage.it => 'La data non può essere nel futuro.',
        UtiliaLanguage.pt => 'A data não pode estar no futuro.',
        _ => 'La fecha no puede ser futura.',
      };

  String get _invalidUnitMessage => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => 'Select valid units.',
        UtiliaLanguage.fr => 'Sélectionnez des unités valides.',
        UtiliaLanguage.de => 'Gültige Einheiten auswählen.',
        UtiliaLanguage.it => 'Seleziona unità valide.',
        UtiliaLanguage.pt => 'Selecione unidades válidas.',
        _ => 'Selecciona unidades válidas.',
      };

  Future<void> calculate() async {
    if (!_hasRequiredInputs()) { _error(_missingFieldsMessage); return; }
    if (!_validateNumericInputs()) { _error(_invalidNumberMessage); return; }
    final x = parseNumber(controllers[0].text);
    final y = parseNumber(controllers[1].text);
    final z = parseNumber(controllers[2].text);
    final price = parseNumber(controllers[3].text);
    if (!_validateToolRanges(x, y, z, price)) { _error(_invalidValueMessage); return; }
    double r;
    String u = '';
    switch (widget.tool.type) {
      case ToolType.percentage: r = percentageOf(x, y); break;
      case ToolType.discount: r = discountedPrice(x, y); break;
      case ToolType.iva: r = priceWithIva(x, y); break;
      case ToolType.tip: r = tipPerPerson(x, y, z.toInt()); break;
      case ToolType.loan: r = loanPayment(x, y, z.toInt()); break;
      case ToolType.compoundInterest: r = compound(x, y, z.toInt()); break;
      case ToolType.area: r = area(x, y); u = 'm²'; break;
      case ToolType.paint: r = paintLitres(x, y); u = 'L'; break;
      case ToolType.electricity: r = electricityCost(x, y, z, price); u = '€'; break;
      case ToolType.fuel: r = fuelCost(x, y, z); u = '€'; break;
      case ToolType.costPerKm: r = costPerKm(x, y); u = '€/km'; break;
      case ToolType.bmi: r = bmi(x, y); break;
      case ToolType.gradeAverage: r = gradeAverage(controllers[0].text.replaceAll(';', ',').split(',').map(parseNumber).toList()); break;
      case ToolType.ruleOfThree: r = ruleOfThree(x, y, z); break;
      case ToolType.age:
        final d = _date(controllers[0].text);
        if (d == null) { _error(widget.s.invalidDate); return; }
        if (d.isAfter(DateTime.now())) { _error(_futureDateMessage); return; }
        r = ageInYears(d); u = _unit('años', 'years', 'ans', 'Jahre', 'anni', 'anos'); break;
      case ToolType.dateDifference:
        final a = _date(controllers[0].text);
        final b = _date(controllers[1].text);
        if (a == null || b == null) { _error(widget.s.invalidDate); return; }
        r = dateDifferenceDays(a, b).toDouble(); u = _unit('días', 'days', 'jours', 'Tage', 'giorni', 'dias'); break;
      case ToolType.workHours: r = workHours(x, y, z); u = 'h'; break;
      case ToolType.countdown: r = countdownSeconds(x.toInt(), y.toInt(), z.toInt()).toDouble(); u = 's'; break;
      case ToolType.length:
        final from = _fromUnit!;
        final to = _toUnit!;
        r = convertLength(x, from, to);
        if (r.isNaN) { _error(_invalidUnitMessage); return; }
        u = to; break;
      case ToolType.weight:
        final from = _fromUnit!;
        final to = _toUnit!;
        r = convertWeight(x, from, to);
        if (r.isNaN) { _error(_invalidUnitMessage); return; }
        u = to; break;
      case ToolType.calculator:
      case ToolType.scientificCalculator: r = 0; break;
    }
    setState(() { result = r; unit = u; });
    await widget.storage.addHistory({'tool': widget.s.toolName(widget.tool.type.name, widget.tool.name), 'result': '${_formatResult(r)}${u.isEmpty ? '' : ' $u'}', 'timestamp': DateTime.now().toIso8601String()});
    await widget.onHistory?.call();
  }

  String _formatResult(double value) {
    final type = widget.tool.type;
    if (type == ToolType.age || type == ToolType.dateDifference || type == ToolType.countdown) return value.toInt().toString();
    if (type == ToolType.gradeAverage || type == ToolType.bmi) return value.toStringAsFixed(2).replaceAll('.', ',');
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _error(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _copy() async {
    if (result == null) return;
    final value = '${_formatResult(result!)}${unit.isEmpty ? '' : ' $unit'}';
    await Clipboard.setData(ClipboardData(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: $value'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.s.copied)));
  }

  Future<void> _share() async {
    if (result == null) return;
    final value = '${_formatResult(result!)}${unit.isEmpty ? '' : ' $unit'}';
    await SharePlus.instance.share(ShareParams(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: $value', subject: 'UTILIA'));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.s.toolName(widget.tool.type.name, widget.tool.name);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(title),
        actions: [
          IconButton(onPressed: result == null ? null : _copy, icon: const Icon(Icons.copy_rounded)),
          IconButton(onPressed: result == null ? null : _share, icon: const Icon(Icons.share_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(widget.s.toolDescription(widget.tool.type.name, widget.tool.description), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 22),
          ...List.generate(labels.length, (i) {
            if (_isConverter && i > 0) {
              final isFrom = i == 1;
              final value = isFrom ? _fromUnit : _toUnit;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: value,
                  decoration: InputDecoration(labelText: labels[i]),
                  items: _unitOptions.entries.map((entry) => DropdownMenuItem<String>(value: entry.key, child: Text(entry.value))).toList(),
                  onChanged: (selected) {
                    setState(() {
                      if (isFrom) { _fromUnit = selected; } else { _toUnit = selected; }
                      result = null;
                      unit = '';
                    });
                  },
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: controllers[i],
                keyboardType: _needsTextInput(i) ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true, signed: true),
                textInputAction: i == labels.length - 1 ? TextInputAction.done : TextInputAction.next,
                decoration: InputDecoration(labelText: labels[i]),
              ),
            );
          }),
          const SizedBox(height: 4),
          FilledButton.icon(onPressed: calculate, icon: const Icon(Icons.auto_awesome_rounded), label: Text(widget.s.calculate)),
          if (result != null) ...[
            const SizedBox(height: 18),
            _resultCard(context),
          ],
        ],
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primaryContainer, scheme.secondaryContainer]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle), child: Icon(Icons.check_rounded, color: scheme.onPrimary)), const SizedBox(width: 12), Text(widget.s.result, style: Theme.of(context).textTheme.titleLarge)]),
        const SizedBox(height: 15),
        Text('${_formatResult(result!)}${unit.isEmpty ? '' : ' $unit'}', style: TextStyle(fontSize: 38, height: 1, fontWeight: FontWeight.w900, color: scheme.onSurface)),
        const SizedBox(height: 14),
        Text(widget.s.result,
      ]),
    );
  }
}