import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'localization.dart';
import 'storage.dart';
import 'utilia_design.dart';

class CalculatorSuitePage extends StatefulWidget {
  const CalculatorSuitePage({super.key, this.scientific = false, required this.storage, required this.s, this.onHistory});
  final bool scientific;
  final UtiliaStorage storage;
  final UtiliaStrings s;
  final Future<void> Function()? onHistory;
  @override
  State<CalculatorSuitePage> createState() => _CalculatorSuitePageState();
}

class _CalculatorSuitePageState extends State<CalculatorSuitePage> {
  late bool scientific;
  String expression = '';
  String result = '0';
  bool degrees = true;
  final recent = <String>[];

  String t(String es, String en, String fr, String de, String it, String pt) => switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => en,
        UtiliaLanguage.fr => fr,
        UtiliaLanguage.de => de,
        UtiliaLanguage.it => it,
        UtiliaLanguage.pt => pt,
        _ => es,
      };

  @override
  void initState() {
    super.initState();
    scientific = widget.scientific;
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final history = await widget.storage.loadHistory();
    if (!mounted) return;
    setState(() {
      recent
        ..clear()
        ..addAll(history.where((item) => item['type'] == 'calculator').map((item) => '${item['expression'] ?? ''} = ${item['result'] ?? ''}').take(8));
    });
  }

  Future<void> _saveResult() async {
    await widget.storage.addHistory({
      'type': 'calculator',
      'tool': scientific ? t('Calculadora científica', 'Scientific calculator', 'Calculatrice scientifique', 'Wissenschaftlicher Rechner', 'Calcolatrice scientifica', 'Calculadora científica') : t('Calculadora', 'Calculator', 'Calculatrice', 'Rechner', 'Calcolatrice', 'Calculadora'),
      'expression': expression,
      'result': result,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _loadRecent();
    await widget.onHistory?.call();
  }

  void key(String value) {
    if (value == '=') {
      try {
        final parsed = CalculatorParser(expression, degrees: degrees).parse();
        setState(() => result = _format(parsed));
        _saveResult();
      } catch (_) {
        setState(() => result = 'Error');
      }
      return;
    }
    setState(() {
      switch (value) {
        case 'C':
          expression = '';
          result = '0';
        case '⌫':
          if (expression.isNotEmpty) expression = expression.substring(0, expression.length - 1);
        case '±':
          expression = expression.startsWith('-') ? expression.substring(1) : '-$expression';
        case 'x²':
          expression += '^2';
        case '1/x':
          expression = '1/($expression)';
        default:
          expression += value;
      }
    });
  }

  String _format(double value) {
    if (!value.isFinite) return 'Error';
    if ((value - value.roundToDouble()).abs() < 1e-10) return value.round().toString();
    return value.toStringAsPrecision(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  void _reuse(String item) {
    final parts = item.split(' = ');
    setState(() {
      expression = parts.first;
      result = parts.length > 1 ? parts.sublist(1).join(' = ') : '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = scientific;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF071522) : const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: dark ? const Color(0xFF071522) : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, size: 29)),
        title: Text(scientific ? t('Científica', 'Scientific', 'Scientifique', 'Wissenschaftlich', 'Scientifica', 'Científica') : t('Calculadora', 'Calculator', 'Calculatrice', 'Rechner', 'Calcolatrice', 'Calculadora'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _showRecent, icon: const Icon(Icons.history_rounded, size: 28)),
          IconButton(onPressed: () => setState(() => scientific = !scientific), icon: Icon(scientific ? Icons.calculate_outlined : Icons.settings_outlined, size: 28)),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 680;
            return Column(
              children: [
                if (scientific) _degreeToggle(),
                _display(compact, dark),
                if (scientific) ...[
                  _functionRow(['sin', 'cos', 'tan', 'ln', 'log']),
                  _functionRow(['π', 'e', 'x²', 'xʸ', '√']),
                ],
                Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(17, 5, 17, 7), child: _keypad(compact, dark))),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _degreeToggle() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        child: Container(
          height: 34,
          decoration: BoxDecoration(color: const Color(0xFF18283A), borderRadius: BorderRadius.circular(18)),
          child: Row(children: [_mode('DEG', degrees, () => setState(() => degrees = true)), _mode('RAD', !degrees, () => setState(() => degrees = false))]),
        ),
      );

  Widget _mode(String label, bool selected, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: selected ? UtiliaBrand.blue : Colors.transparent, borderRadius: BorderRadius.circular(16)),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ),
      );

  Widget _display(bool compact, bool dark) => Container(
        height: compact ? 110 : 148,
        margin: const EdgeInsets.fromLTRB(17, 2, 17, 9),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 12),
        decoration: BoxDecoration(color: dark ? const Color(0xFF101D2B) : Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Align(alignment: Alignment.centerRight, child: SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: Text(expression.isEmpty ? '0' : expression, style: TextStyle(fontSize: compact ? 20 : 22, color: dark ? Colors.white70 : const Color(0xFF62738A), fontWeight: FontWeight.w500)))),
            SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: Text(result, style: TextStyle(fontSize: compact ? 39 : 46, height: .98, fontWeight: FontWeight.w900, color: dark ? Colors.white : UtiliaBrand.ink))),
          ],
        ),
      );

  Widget _functionRow(List<String> values) => SizedBox(
        height: 41,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(children: [for (final value in values) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _functionKey(value)))]),
        ),
      );

  Widget _functionKey(String label) => Material(
        color: const Color(0xFF18283A),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(onTap: () => key(switch (label) { 'sin' => 'sin(', 'cos' => 'cos(', 'tan' => 'tan(', 'ln' => 'ln(', 'log' => 'log(', '√' => '√(', _ => label }), borderRadius: BorderRadius.circular(10), child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)))),
      );

  Widget _keypad(bool compact, bool dark) {
    if (scientific) {
      const rows = [['C', '(', ')', '⌫'], ['7', '8', '9', '÷'], ['4', '5', '6', '×'], ['1', '2', '3', '−'], ['0', ',', '!', '+']];
      return Column(children: [for (final row in rows) Expanded(child: Row(children: [for (final value in row) Expanded(child: _key(value, compact, true))])), Expanded(child: Row(children: [Expanded(child: _key('±', compact, true)), Expanded(flex: 2, child: _key('=', compact, true, primary: true))]))]);
    }
    const rows = [['C', '(', ')'], ['7', '8', '9'], ['4', '5', '6'], ['1', '2', '3'], ['0', ',', '%']];
    return Row(
      children: [
        Expanded(child: Column(children: [for (final row in rows) Expanded(child: Row(children: [for (final value in row) Expanded(child: _key(value, compact, false))]))])),
        const SizedBox(width: 8),
        SizedBox(
          width: 86,
          child: Column(children: [
            Expanded(child: _key('⌫', compact, false)),
            Expanded(child: _key('÷', compact, false)),
            Expanded(child: _key('×', compact, false)),
            Expanded(child: _key('−', compact, false)),
            Expanded(flex: 2, child: _key('+', compact, false)),
            Expanded(flex: 2, child: _key('=', compact, false, primary: true)),
          ]),
        ),
      ],
    );
  }

  Widget _key(String value, bool compact, bool dark, {bool primary = false}) {
    final destructive = value == 'C';
    final numeric = RegExp(r'^\d$').hasMatch(value) || value == ',' || value == '%' || value == '±';
    final operator = !numeric && value != 'C' && value != '⌫' && value != '(' && value != ')';
    final bg = primary ? UtiliaBrand.blue : dark ? const Color(0xFF18283A) : Colors.white;
    final fg = primary ? Colors.white : destructive ? const Color(0xFFE43E4E) : dark ? Colors.white : UtiliaBrand.ink;
    final fontSize = compact ? (numeric ? 28.0 : operator ? 22.0 : 24.0) : (numeric ? 31.0 : operator ? 21.0 : 25.0);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        elevation: dark || primary ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: .055),
        child: InkWell(borderRadius: BorderRadius.circular(15), onTap: () => key(value), child: Center(child: Text(value, style: TextStyle(fontSize: fontSize, height: 1, fontWeight: numeric ? FontWeight.w800 : FontWeight.w600, color: fg))),),
      ),
    );
  }

  Future<void> _showRecent() async {
    await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (sheetContext) {
      if (recent.isEmpty) return SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Center(child: Text(t('No hay cálculos recientes.', 'No recent calculations.', 'Aucun calcul récent.', 'Keine aktuellen Berechnungen.', 'Nessun calcolo recente.', 'Sem cálculos recentes.')))));
      return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: recent.map((item) => ListTile(leading: const Icon(Icons.functions_rounded), title: Text(item), trailing: IconButton(icon: const Icon(Icons.replay_rounded), onPressed: () { Navigator.pop(sheetContext); _reuse(item); }))).toList()));
    });
  }
}

class CalculatorParser {
  CalculatorParser(this.s, {this.degrees = true});
  final String s;
  final bool degrees;
  int p = 0;
  double parse() { p = 0; final value = _expr(); _skip(); if (p < s.length) throw const FormatException('syntax'); return value; }
  void _skip() { while (p < s.length && s[p] == ' ') p++; }
  bool _eat(String value) { _skip(); if (s.startsWith(value, p)) { p += value.length; return true; } return false; }
  double _expr() { var value = _term(); while (true) { if (_eat('+')) value += _term(); else if (_eat('−') || _eat('-')) value -= _term(); else return value; } }
  double _term() { var value = _power(); while (true) { if (_eat('×') || _eat('*')) value *= _power(); else if (_eat('÷') || _eat('/')) value /= _power(); else return value; } }
  double _power() { var value = _unary(); if (_eat('^')) value = math.pow(value, _power()).toDouble(); return value; }
  double _unary() { _skip(); if (_eat('±')) return -_unary(); if (_eat('-')) return -_unary(); return _primary(); }
  double _primary() {
    _skip();
    if (_eat('(')) { final value = _expr(); if (!_eat(')')) throw const FormatException(')'); return value; }
    for (final function in ['sin(', 'cos(', 'tan(', 'ln(', 'log(', '√(']) { if (_eat(function)) { final value = _expr(); if (!_eat(')')) throw const FormatException(')'); return _function(function.substring(0, function.length - 1), value); } }
    if (_eat('π')) return math.pi;
    if (_eat('e')) return math.e;
    final start = p; while (p < s.length && RegExp(r'[0-9.,]').hasMatch(s[p])) p++; if (start == p) throw const FormatException('number');
    var value = double.parse(s.substring(start, p).replaceAll(',', '.')); while (_eat('!')) value = _factorial(value); return value;
  }
  double _function(String name, double value) => switch (name) { 'sin' => math.sin(degrees ? value * math.pi / 180 : value), 'cos' => math.cos(degrees ? value * math.pi / 180 : value), 'tan' => math.tan(degrees ? value * math.pi / 180 : value), 'ln' => math.log(value), 'log' => math.log(value) / math.ln10, _ => math.sqrt(value) };
  double _factorial(double value) { if (value < 0 || value > 170 || value != value.roundToDouble()) throw const FormatException('factorial'); var result = 1.0; for (var i = 2; i <= value; i++) result *= i; return result; }
}
