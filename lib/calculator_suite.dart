import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'localization.dart';
import 'storage.dart';
import 'utilia_design.dart';

class CalculatorSuitePage extends StatefulWidget {
  const CalculatorSuitePage({
    super.key,
    this.scientific = false,
    required this.storage,
    required this.s,
    this.onHistory,
  });

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

  String t(String es, String en, String fr, String de, String it, String pt) {
    return switch (widget.s.selectedLanguage) {
      UtiliaLanguage.en => en,
      UtiliaLanguage.fr => fr,
      UtiliaLanguage.de => de,
      UtiliaLanguage.it => it,
      UtiliaLanguage.pt => pt,
      _ => es,
    };
  }

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
        ..addAll(
          history
              .where((item) => item['type'] == 'calculator')
              .map((item) => '${item['expression'] ?? ''} = ${item['result'] ?? ''}')
              .take(8),
        );
    });
  }

  Future<void> _saveResult() async {
    await widget.storage.addHistory({
      'type': 'calculator',
      'tool': scientific
          ? t('Calculadora científica', 'Scientific calculator', 'Calculatrice scientifique', 'Wissenschaftlicher Rechner', 'Calcolatrice scientifica', 'Calculadora científica')
          : t('Calculadora', 'Calculator', 'Calculatrice', 'Rechner', 'Calcolatrice', 'Calculadora'),
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

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: '$expression = $result'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.s.copied)));
    }
  }

  Future<void> _share() {
    return SharePlus.instance.share(ShareParams(text: '$expression = $result', subject: 'UTILIA'));
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
    final dark = scientific || Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: scientific ? const Color(0xFF07111F) : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(
          scientific
              ? t('Científica', 'Scientific', 'Scientifique', 'Wissenschaftlich', 'Scientifica', 'Científica')
              : t('Calculadora', 'Calculator', 'Calculatrice', 'Rechner', 'Calcolatrice', 'Calculadora'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(onPressed: _showRecent, icon: const Icon(Icons.history_rounded)),
          IconButton(onPressed: _copy, icon: const Icon(Icons.copy_outlined)),
          IconButton(onPressed: () => setState(() => scientific = !scientific), icon: Icon(scientific ? Icons.calculate_rounded : Icons.functions_rounded)),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            return Column(
              children: [
                if (scientific) _degreeToggle(),
                _display(compact, dark),
                if (!scientific)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      _action('Copiar', Icons.copy_rounded, _copy),
                      const SizedBox(width: 8),
                      _action('Compartir', Icons.share_rounded, _share),
                    ]),
                  ),
                if (scientific) ...[
                  _functionRow([
                    _small('sin', 'sin('),
                    _small('cos', 'cos('),
                    _small('tan', 'tan('),
                    _small('ln', 'ln('),
                    _small('log', 'log('),
                  ]),
                  _functionRow([
                    _small('π', 'π'),
                    _small('e', 'e'),
                    _small('x²', 'x²'),
                    _small('xʸ', '^'),
                    _small('√', '√('),
                    _small('!', '!'),
                  ]),
                ],
                Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(11, 7, 11, 5), child: _keypad(compact, dark))),
                SizedBox(
                  height: compact ? 34 : 40,
                  child: TextButton.icon(
                    onPressed: _showRecent,
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: Text(t('Cálculos recientes', 'Recent calculations', 'Calculs récents', 'Letzte Berechnungen', 'Calcoli recenti', 'Cálculos recentes')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _degreeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 7),
      child: Container(
        height: 38,
        decoration: BoxDecoration(color: const Color(0xFF142235), borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          _mode('DEG', degrees, () => setState(() => degrees = true)),
          _mode('RAD', !degrees, () => setState(() => degrees = false)),
        ]),
      ),
    );
  }

  Widget _mode(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: selected ? UtiliaBrand.blue : Colors.transparent, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _display(bool compact, bool dark) {
    return Container(
      height: compact ? 112 : 145,
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      padding: const EdgeInsets.fromLTRB(17, 14, 17, 12),
      decoration: BoxDecoration(color: dark ? const Color(0xFF0F1B2A) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(expression.isEmpty ? '0' : expression, style: TextStyle(fontSize: compact ? 18 : 21, color: dark ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(result, style: TextStyle(fontSize: compact ? 34 : 42, fontWeight: FontWeight.w900, color: dark ? Colors.white : Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _action(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
      ),
    );
  }

  Widget _functionRow(List<Widget> children) => SizedBox(height: 39, child: Row(children: children));

  Widget _small(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: OutlinedButton(
          onPressed: () => key(value),
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
          child: FittedBox(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        ),
      ),
    );
  }

  Widget _keypad(bool compact, bool dark) {
    final rows = scientific
        ? const [['C', '⌫', '(', ')'], ['7', '8', '9', '÷'], ['4', '5', '6', '×'], ['1', '2', '3', '−'], ['±', '0', ',', '+']]
        : const [['C', '(', ')', '⌫'], ['7', '8', '9', '÷'], ['4', '5', '6', '×'], ['1', '2', '3', '−'], ['±', '0', ',', '+']];
    return Column(
      children: [
        for (final row in rows)
          Expanded(child: Row(children: [for (final value in row) Expanded(child: _key(value, compact, dark))])),
        Expanded(child: Row(children: [Expanded(child: _key('%', compact, dark)), Expanded(child: _key('=', compact, dark, primary: true))])),
      ],
    );
  }

  Widget _key(String value, bool compact, bool dark, {bool primary = false}) {
    final destructive = value == 'C';
    final background = primary ? UtiliaBrand.blue : dark ? const Color(0xFF172637) : Theme.of(context).colorScheme.surfaceContainerHighest;
    final foreground = primary ? Colors.white : destructive ? Theme.of(context).colorScheme.error : dark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 12 : 15),
        onTap: () => key(value),
        child: Container(
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(compact ? 12 : 15)),
          alignment: Alignment.center,
          child: Text(value, style: TextStyle(fontSize: compact ? 19 : 22, fontWeight: FontWeight.w700, color: foreground)),
        ),
      ),
    );
  }

  Future<void> _showRecent() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        if (recent.isEmpty) {
          return SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Center(child: Text(t('No hay cálculos recientes.', 'No recent calculations.', 'Aucun calcul récent.', 'Keine aktuellen Berechnungen.', 'Nessun calcolo recente.', 'Sem cálculos recentes.')))));
        }
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: recent.map((item) => ListTile(
              leading: const Icon(Icons.functions_rounded),
              title: Text(item),
              trailing: IconButton(icon: const Icon(Icons.replay_rounded), onPressed: () { Navigator.pop(sheetContext); _reuse(item); }),
            )).toList(),
          ),
        );
      },
    );
  }
}

class CalculatorParser {
  CalculatorParser(this.s, {this.degrees = true});
  final String s;
  final bool degrees;
  int p = 0;

  double parse() {
    p = 0;
    final value = _expr();
    _skip();
    if (p < s.length) throw const FormatException('syntax');
    return value;
  }

  void _skip() { while (p < s.length && s[p] == ' ') p++; }

  bool _eat(String value) {
    _skip();
    if (s.startsWith(value, p)) { p += value.length; return true; }
    return false;
  }

  double _expr() {
    var value = _term();
    while (true) {
      if (_eat('+')) value += _term();
      else if (_eat('−') || _eat('-')) value -= _term();
      else return value;
    }
  }

  double _term() {
    var value = _power();
    while (true) {
      if (_eat('×') || _eat('*')) value *= _power();
      else if (_eat('÷') || _eat('/')) value /= _power();
      else return value;
    }
  }

  double _power() {
    var value = _unary();
    if (_eat('^')) value = math.pow(value, _power()).toDouble();
    return value;
  }

  double _unary() {
    _skip();
    if (_eat('±')) return -_unary();
    if (_eat('-')) return -_unary();
    return _primary();
  }

  double _primary() {
    _skip();
    if (_eat('(')) {
      final value = _expr();
      if (!_eat(')')) throw const FormatException(')');
      return value;
    }
    for (final function in ['sin(', 'cos(', 'tan(', 'ln(', 'log(', '√(']) {
      if (_eat(function)) {
        final value = _expr();
        if (!_eat(')')) throw const FormatException(')');
        return _function(function.substring(0, function.length - 1), value);
      }
    }
    if (_eat('π')) return math.pi;
    if (_eat('e')) return math.e;
    final start = p;
    while (p < s.length && RegExp(r'[0-9.,]').hasMatch(s[p])) p++;
    if (start == p) throw const FormatException('number');
    var value = double.parse(s.substring(start, p).replaceAll(',', '.'));
    while (_eat('!')) value = _factorial(value);
    return value;
  }

  double _function(String name, double value) => switch (name) {
        'sin' => math.sin(degrees ? value * math.pi / 180 : value),
        'cos' => math.cos(degrees ? value * math.pi / 180 : value),
        'tan' => math.tan(degrees ? value * math.pi / 180 : value),
        'ln' => math.log(value),
        'log' => math.log(value) / math.ln10,
        _ => math.sqrt(value),
      };

  double _factorial(double value) {
    if (value < 0 || value > 170 || value != value.roundToDouble()) throw const FormatException('factorial');
    var result = 1.0;
    for (var i = 2; i <= value; i++) result *= i;
    return result;
  }
}
