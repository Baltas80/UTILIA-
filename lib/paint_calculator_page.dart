import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'calculations.dart';
import 'localization.dart';
import 'models/tool.dart';
import 'storage.dart';

class PaintCalculatorPage extends StatefulWidget {
  const PaintCalculatorPage({super.key, required this.tool, required this.storage, this.onHistory, required this.s});
  final UtiliaTool tool;
  final UtiliaStorage storage;
  final Future<void> Function()? onHistory;
  final UtiliaStrings s;

  @override
  State<PaintCalculatorPage> createState() => _PaintCalculatorPageState();
}

class _PaintCalculatorPageState extends State<PaintCalculatorPage> {
  final _surface = TextEditingController();
  final _coverage = TextEditingController();
  final _coats = TextEditingController(text: '1');
  double? result;

  String _t(String es, String en, String fr, String de, String it, String pt) => switch (widget.s.selectedLanguage) {
    UtiliaLanguage.en => en,
    UtiliaLanguage.fr => fr,
    UtiliaLanguage.de => de,
    UtiliaLanguage.it => it,
    UtiliaLanguage.pt => pt,
    _ => es,
  };

  String get _coatsLabel => _t('Número de capas', 'Number of coats', 'Nombre de couches', 'Anzahl der Schichten', 'Numero di mani', 'Número de demãos');
  String get _invalid => _t('Introduce valores válidos.', 'Enter valid values.', 'Saisissez des valeurs valides.', 'Gültige Werte eingeben.', 'Inserisci valori validi.', 'Introduza valores válidos.');
  String get _copied => _t('Resultado copiado', 'Result copied', 'Résultat copié', 'Ergebnis kopiert', 'Risultato copiato', 'Resultado copiado');

  @override
  void dispose() {
    _surface.dispose();
    _coverage.dispose();
    _coats.dispose();
    super.dispose();
  }

  double? _number(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  String _format(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2).replaceAll('.', ',');

  Future<void> _calculate() async {
    final surface = _number(_surface.text);
    final coverage = _number(_coverage.text);
    final coats = _number(_coats.text);
    if (surface == null || coverage == null || coats == null ||
        surface < 0 || coverage <= 0 || coats <= 0 || coats != coats.truncateToDouble()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_invalid)));
      return;
    }
    final litres = paintLitres(surface, coverage, coats: coats.toInt());
    setState(() => result = litres);
    await widget.storage.addHistory({
      'tool': widget.s.toolName(widget.tool.type.name, widget.tool.name),
      'result': '${_format(litres)} L',
      'timestamp': DateTime.now().toIso8601String(),
    });
    await widget.onHistory?.call();
  }

  Future<void> _copy() async {
    if (result == null) return;
    await Clipboard.setData(ClipboardData(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: ${_format(result!)} L'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_copied)));
  }

  Future<void> _share() async {
    if (result == null) return;
    await SharePlus.instance.share(ShareParams(
      text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: ${_format(result!)} L',
      subject: 'UTILIA',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.s.toolName(widget.tool.type.name, widget.tool.name);
    final theme = Theme.of(context);
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
          Text(widget.s.toolDescription(widget.tool.type.name, widget.tool.description), style: theme.textTheme.bodyLarge),
          const SizedBox(height: 22),
          TextField(controller: _surface, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: widget.s.inputLabel('paint', 0))),
          const SizedBox(height: 12),
          TextField(controller: _coverage, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: widget.s.inputLabel('paint', 1))),
          const SizedBox(height: 12),
          TextField(controller: _coats, keyboardType: const TextInputType.numberWithOptions(decimal: false), decoration: InputDecoration(labelText: _coatsLabel)),
          const SizedBox(height: 4),
          FilledButton.icon(onPressed: _calculate, icon: const Icon(Icons.auto_awesome_rounded), label: Text(widget.s.calculate)),
          if (result != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const CircleAvatar(radius: 24, child: Icon(Icons.check_rounded)),
                    const SizedBox(width: 14),
                    Text(widget.s.result, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 16),
                  Text('${_format(result!)} L', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(widget.s.result, style: theme.textTheme.bodyLarge),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
