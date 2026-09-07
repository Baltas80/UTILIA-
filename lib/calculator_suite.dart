import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'localization.dart';
import 'storage.dart';

class CalculatorSuitePage extends StatefulWidget {
  const CalculatorSuitePage({super.key, this.scientific = false, required this.storage, required this.s});
  final bool scientific;
  final UtiliaStorage storage;
  final UtiliaStrings s;
  @override State<CalculatorSuitePage> createState() => _CalculatorSuitePageState();
}

class _CalculatorSuitePageState extends State<CalculatorSuitePage> {
  late bool scientific;
  String expression = '';
  String result = '0';
  bool degrees = true;
  final List<String> recent = [];
  Timer? _backspaceTimer;

  String t(String es, String en, String fr, String de, String it, String pt) => switch (widget.s.selectedLanguage) {
    UtiliaLanguage.en => en, UtiliaLanguage.fr => fr, UtiliaLanguage.de => de,
    UtiliaLanguage.it => it, UtiliaLanguage.pt => pt, _ => es,
  };

  @override void initState() { super.initState(); scientific = widget.scientific; _loadRecent(); }
  @override void dispose() { _backspaceTimer?.cancel(); super.dispose(); }

  Future<void> _loadRecent() async {
    final h = await widget.storage.loadHistory();
    if (!mounted) return;
    setState(() {
      recent..clear()..addAll(h.where((e) => e['type'] == 'calculator').map((e) => '${e['expression'] ?? ''} = ${e['result'] ?? ''}').take(8));
    });
  }

  Future<void> _saveResult() async {
    final entry = {
      'type': 'calculator',
      'tool': scientific ? t('Calculadora científica', 'Scientific calculator', 'Calculatrice scientifique', 'Wissenschaftlicher Rechner', 'Calcolatrice scientifica', 'Calculadora científica') : t('Calculadora', 'Calculator', 'Calculatrice', 'Rechner', 'Calcolatrice', 'Calculadora'),
      'expression': expression, 'result': result, 'timestamp': DateTime.now().toIso8601String(),
    };
    await widget.storage.addHistory(entry);
    await _loadRecent();
  }

  void key(String v) {
    setState(() {
      if (v == 'C') { expression = ''; result = '0'; }
      else if (v == '⌫') { if (expression.isNotEmpty) expression = expression.substring(0, expression.length - 1); }
      else if (v == '=') {
        try { result = _format(CalculatorParser(expression, degrees: degrees).parse()); _saveResult(); }
        catch (_) { result = t('Error', 'Error', 'Erreur', 'Fehler', 'Errore', 'Erro'); }
      } else if (v == '±') { expression = expression.startsWith('-') ? expression.substring(1) : '-$expression'; }
      else if (v == 'x²') { expression += '^2'; }
      else if (v == '1/x') { expression = '1/($expression)'; }
      else { expression += v; }
    });
  }

  void _startBackspaceRepeat() {
    _backspaceTimer?.cancel();
    _backspaceTimer = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      key('⌫');
      _backspaceTimer = Timer.periodic(const Duration(milliseconds: 75), (_) { if (mounted) key('⌫'); });
    });
  }
  void _stopBackspaceRepeat() { _backspaceTimer?.cancel(); _backspaceTimer = null; }

  String _format(double x) {
    if (!x.isFinite) return 'Error';
    if ((x - x.roundToDouble()).abs() < 1e-10) return x.round().toString();
    return x.toStringAsPrecision(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: '$expression = $result'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Resultado copiado', 'Result copied', 'Résultat copié', 'Ergebnis kopiert', 'Risultato copiato', 'Resultado copiado'))));
  }
  Future<void> _share() async => SharePlus.instance.share(ShareParams(text: '$expression = $result', subject: 'UTILIA'));
  void _reuse(String item) { final parts = item.split(' = '); setState(() { expression = parts.first; result = parts.length > 1 ? parts.sublist(1).join(' = ') : '0'; }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: Text(scientific ? t('Calculadora científica', 'Scientific calculator', 'Calculatrice scientifique', 'Wissenschaftlicher Rechner', 'Calcolatrice scientifica', 'Calculadora científica') : t('Calculadora', 'Calculator', 'Calculatrice', 'Rechner', 'Calcolatrice', 'Calculadora'), style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(tooltip: t('Copiar', 'Copy', 'Copier', 'Kopieren', 'Copia', 'Copiar'), onPressed: _copy, icon: const Icon(Icons.copy_outlined)),
          IconButton(tooltip: t('Compartir', 'Share', 'Partager', 'Teilen', 'Condividi', 'Partilhar'), onPressed: _share, icon: const Icon(Icons.share_outlined)),
          IconButton(tooltip: t('Cambiar calculadora', 'Switch calculator', 'Changer de calculatrice', 'Rechner wechseln', 'Cambia calcolatrice', 'Mudar calculadora'), onPressed: () => setState(() => scientific = !scientific), icon: Icon(scientific ? Icons.calculate : Icons.functions)),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxHeight < 700;
          final displayHeight = compact ? 92.0 : 122.0;
          final actionHeight = compact ? 42.0 : 48.0;
          final scientificHeight = compact ? 42.0 : 48.0;
          final recentHeight = compact ? 46.0 : 52.0;
          return Column(children: [
            SizedBox(height: displayHeight, child: Padding(padding: EdgeInsets.fromLTRB(compact ? 14 : 20, compact ? 8 : 14, compact ? 14 : 20, 4), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Align(alignment: Alignment.centerRight, child: SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: Text(expression.isEmpty ? '0' : expression, style: TextStyle(fontSize: compact ? 18 : 21))))),
              SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: Text(result, style: TextStyle(fontSize: compact ? 30 : 36, fontWeight: FontWeight.w900))),
            ]))),
            SizedBox(height: actionHeight, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _copy, icon: const Icon(Icons.copy, size: 18), label: Text(t('Copiar', 'Copy', 'Copier', 'Kopieren', 'Copia', 'Copiar')))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: _share, icon: const Icon(Icons.share, size: 18), label: Text(t('Compartir', 'Share', 'Partager', 'Teilen', 'Condividi', 'Partilhar')))),
            ]))),
            if (scientific) ...[
              const SizedBox(height: 4),
              SizedBox(height: scientificHeight, child: _scientificRow([_small('sin(', 'sin('), _small('cos(', 'cos('), _small('tan(', 'tan('), _small('ln(', 'ln('), _small('log(', 'log(')])),
              SizedBox(height: scientificHeight, child: _scientificRow([_small('√', '√('), _small('x²', 'x²'), _small('^', '^'), _small('1/x', '1/x'), _small('!', '!'), _small(degrees ? 'DEG' : 'RAD', 'mode')])),
            ],
            Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(10, 6, 10, 4), child: scientific ? _scientificKeypad(compact) : _standardKeypad(compact))),
            SizedBox(height: recentHeight, child: recent.isEmpty ? ListTile(dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16), leading: const Icon(Icons.history, size: 21), title: Text(t('Cálculos recientes', 'Recent calculations', 'Calculs récents', 'Letzte Berechnungen', 'Calcoli recenti', 'Cálculos recentes'))) : ExpansionTile(tilePadding: const EdgeInsets.symmetric(horizontal: 16), childrenPadding: EdgeInsets.zero, initiallyExpanded: false, leading: const Icon(Icons.history, size: 21), title: Text(t('Cálculos recientes', 'Recent calculations', 'Calculs récents', 'Letzte Berechnungen', 'Calcoli recenti', 'Cálculos recentes')), children: recent.map((item) => ListTile(dense: true, title: Text(item), trailing: IconButton(icon: const Icon(Icons.replay), tooltip: t('Repetir', 'Repeat', 'Répéter', 'Wiederholen', 'Ripeti', 'Repetir'), onPressed: () => _reuse(item)))).toList())),
          ]);
        }),
      ),
    );
  }

  Widget _scientificRow(List<Widget> children) => Row(children: children);
  Widget _small(String label, String value) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), child: OutlinedButton(onPressed: () => value == 'mode' ? setState(() => degrees = !degrees) : key(value), style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))))));

  Widget _standardKeypad(bool compact) {
    const rows = [['C', '⌫', '(', ')'], ['7', '8', '9', '÷'], ['4', '5', '6', '×'], ['1', '2', '3', '−'], ['±', '0', ',', '+']];
    return Column(children: [for (final row in rows) Expanded(child: Row(children: [for (final value in row) Expanded(child: _key(value, compact))])), Expanded(child: Row(children: [Expanded(child: _key('=', compact, primary: true))]))]);
  }

  Widget _scientificKeypad(bool compact) {
    const rows = [['C', '⌫', '(', ')'], ['7', '8', '9', '÷'], ['4', '5', '6', '×'], ['1', '2', '3', '−'], ['±', '0', ',', '+'], ['=']];
    return Column(children: [for (final row in rows) Expanded(child: Row(children: [for (final value in row) Expanded(child: _key(value, compact, primary: value == '='))]))]);
  }

  Widget _key(String value, bool compact, {bool primary = false}) {
    final scheme = Theme.of(context).colorScheme;
    final background = primary ? scheme.primary : scheme.surfaceContainerHighest;
    final foreground = primary ? scheme.onPrimary : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Listener(
        onPointerDown: value == '⌫' ? (_) => _startBackspaceRepeat() : null,
        onPointerUp: value == '⌫' ? (_) => _stopBackspaceRepeat() : null,
        onPointerCancel: value == '⌫' ? (_) => _stopBackspaceRepeat() : null,
        child: FilledButton(
          onPressed: () => key(value),
          style: FilledButton.styleFrom(backgroundColor: background, foregroundColor: foreground, padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(compact ? 12 : 15))),
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: compact ? 20 : 23, fontWeight: FontWeight.w700))),
        ),
      ),
    );
  }
}

class CalculatorParser {
  CalculatorParser(this.s, {this.degrees = true});
  final String s;
  final bool degrees;
  int p = 0;
  double parse() { p = 0; final v = _expr(); _skip(); if (p < s.length) throw const FormatException('syntax'); return v; }
  void _skip() { while (p < s.length && s[p] == ' ') p++; }
  bool _eat(String x) { _skip(); if (s.startsWith(x, p)) { p += x.length; return true; } return false; }
  double _expr() { var v = _term(); while (true) { if (_eat('+')) v += _term(); else if (_eat('−') || _eat('-')) v -= _term(); else return v; } }
  double _term() { var v = _power(); while (true) { if (_eat('×') || _eat('*')) v *= _power(); else if (_eat('÷') || _eat('/')) v /= _power(); else return v; } }
  double _power() { var v = _unary(); if (_eat('^')) v = math.pow(v, _power()).toDouble(); return v; }
  double _unary() { _skip(); if (_eat('±')) return -_unary(); if (_eat('-')) return -_unary(); return _primary(); }
  double _primary() { _skip(); if (_eat('(')) { final v = _expr(); if (!_eat(')')) throw const FormatException(')'); return v; } for (final f in ['sin(', 'cos(', 'tan(', 'ln(', 'log(', '√(']) { if (_eat(f)) { final x = _expr(); if (!_eat(')')) throw const FormatException(')'); return _fn(f.substring(0, f.length - 1), x); } } if (_eat('π')) return math.pi; if (_eat('e')) return math.e; final start = p; while (p < s.length && RegExp(r'[0-9.,]').hasMatch(s[p])) p++; if (start == p) throw const FormatException('number'); var v = double.parse(s.substring(start, p).replaceAll(',', '.')); while (_eat('!')) v = _fact(v); return v; }
  double _fn(String f, double x) => switch (f) { 'sin' => math.sin(degrees ? x * math.pi / 180 : x), 'cos' => math.cos(degrees ? x * math.pi / 180 : x), 'tan' => math.tan(degrees ? x * math.pi / 180 : x), 'ln' => math.log(x), 'log' => math.log(x) / math.ln10, _ => math.sqrt(x), };
  double _fact(double x) { if (x < 0 || x > 170 || x != x.roundToDouble()) throw const FormatException('factorial'); var r = 1.0; for (var i = 2; i <= x; i++) r *= i; return r; }
}
