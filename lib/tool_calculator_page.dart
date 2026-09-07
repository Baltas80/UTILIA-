import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'calculations.dart';
import 'catalog.dart';
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
    return List.generate(count, (i) => widget.tool.type == ToolType.electricity && i == 3 ? 'Precio del kWh (€)' : widget.s.inputLabel(id, i));
  }

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

  bool _needsTextInput(int index) => switch (widget.tool.type) {
        ToolType.age || ToolType.dateDifference => true,
        ToolType.length || ToolType.weight => index > 0,
        ToolType.gradeAverage => true,
        _ => false,
      };

  bool _hasRequiredInputs() {
    final required = labels.length;
    for (var i = 0; i < required; i++) {
      if (controllers[i].text.trim().isEmpty) return false;
    }
    return true;
  }

  Future<void> calculate() async {
    if (!_hasRequiredInputs()) {
      _error(widget.s.requiredFields);
      return;
    }

    final x = parseNumber(controllers[0].text);
    final y = parseNumber(controllers[1].text);
    final z = parseNumber(controllers[2].text);
    final price = parseNumber(controllers[3].text);
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
      case ToolType.gradeAverage: r = gradeAverage(controllers[0].text.split(',').map(parseNumber).toList()); break;
      case ToolType.ruleOfThree: r = ruleOfThree(x, y, z); break;
      case ToolType.age:
        final d = _date(controllers[0].text);
        if (d == null) { _error(widget.s.invalidDate); return; }
        r = ageInYears(d); u = _unit('años', 'years', 'ans', 'Jahre', 'anni', 'anos');
        break;
      case ToolType.dateDifference:
        final a = _date(controllers[0].text);
        final b = _date(controllers[1].text);
        if (a == null || b == null) { _error(widget.s.invalidDate); return; }
        r = dateDifferenceDays(a, b).toDouble(); u = _unit('días', 'days', 'jours', 'Tage', 'giorni', 'dias');
        break;
      case ToolType.workHours: r = workHours(x, y, z); u = 'h'; break;
      case ToolType.countdown: r = countdownSeconds(x.toInt(), y.toInt(), z.toInt()).toDouble(); u = 'sec'; break;
      case ToolType.length: r = convertLength(x, controllers[1].text.trim().toLowerCase(), controllers[2].text.trim().toLowerCase()); u = controllers[2].text.trim(); break;
      case ToolType.weight: r = convertWeight(x, controllers[1].text.trim().toLowerCase(), controllers[2].text.trim().toLowerCase()); u = controllers[2].text.trim(); break;
      case ToolType.calculator:
      case ToolType.scientificCalculator: r = 0; break;
    }
    setState(() { result = r; unit = u; });
    await widget.storage.addHistory({'tool': widget.s.toolName(widget.tool.type.name, widget.tool.name), 'result': '${r.toStringAsFixed(2).replaceAll('.', ',')} $u', 'timestamp': DateTime.now().toIso8601String()});
    await widget.onHistory?.call();
  }

  void _error(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _copy() async {
    final value = result == null ? '' : '${result!.toStringAsFixed(2).replaceAll('.', ',')} $unit';
    await Clipboard.setData(ClipboardData(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: $value'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.s.copied)));
  }

  Future<void> _share() async {
    final value = result == null ? '' : '${result!.toStringAsFixed(2).replaceAll('.', ',')} $unit';
    await SharePlus.instance.share(ShareParams(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: $value', subject: 'UTILIA'));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.s.toolName(widget.tool.type.name, widget.tool.name);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(title),
        actions: [IconButton(onPressed: _copy, icon: const Icon(Icons.copy_rounded)), IconButton(onPressed: _share, icon: const Icon(Icons.share_rounded)), const SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(widget.s.toolDescription(widget.tool.type.name, widget.tool.description), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 22),
          ...List.generate(labels.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controllers[i],
              keyboardType: _needsTextInput(i) ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true, signed: true),
              textInputAction: i == labels.length - 1 ? TextInputAction.done : TextInputAction.next,
              decoration: InputDecoration(labelText: labels[i]),
            ),
          )),
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
        Text('${result!.toStringAsFixed(2).replaceAll('.', ',')} $unit', style: TextStyle(fontSize: 38, height: 1, fontWeight: FontWeight.w900, color: scheme.onSurface)),
        const SizedBox(height: 14),
        Text(widget.s.resultHint(widget.tool.type.name), style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}
