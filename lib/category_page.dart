import 'package:flutter/material.dart';

import 'calculator_suite.dart';
import 'localization.dart';
import 'models/tool.dart';
import 'paint_calculator_page.dart';
import 'storage.dart';
import 'tool_calculator_page.dart';
import 'utilia_design.dart';

class UtiliaCategoryPage extends StatefulWidget {
  const UtiliaCategoryPage({super.key, required this.category, required this.tools, required this.favorites, required this.onFavorite, required this.storage, required this.onHistory, required this.s});
  final String category; final List<UtiliaTool> tools; final Set<ToolType> favorites;
  final Future<void> Function(ToolType) onFavorite; final UtiliaStorage storage; final Future<void> Function() onHistory; final UtiliaStrings s;
  @override State<UtiliaCategoryPage> createState() => _UtiliaCategoryPageState();
}

class _UtiliaCategoryPageState extends State<UtiliaCategoryPage> {
  late Set<ToolType> favorites;
  @override void initState() { super.initState(); favorites = {...widget.favorites}; }
  Future<void> _toggleFavorite(ToolType type) async { final next = {...favorites}; next.contains(type) ? next.remove(type) : next.add(type); setState(() => favorites = next); await widget.onFavorite(type); }

  @override Widget build(BuildContext context) {
    final tint = UtiliaBrand.categoryColor(widget.category, widget.tools.first.tint);
    final category = widget.s.category(widget.category);
    final subtitle = switch (widget.s.selectedLanguage) {
      UtiliaLanguage.en => 'Tools for learning, work and everyday tasks.',
      UtiliaLanguage.fr => 'Des outils pour apprendre, travailler et gérer le quotidien.',
      UtiliaLanguage.de => 'Werkzeuge für Lernen, Arbeit und Alltag.',
      UtiliaLanguage.it => 'Strumenti per studio, lavoro e attività quotidiane.',
      UtiliaLanguage.pt => 'Ferramentas para estudo, trabalho e tarefas diárias.',
      _ => 'Herramientas para tu día a día.',
    };
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)), title: Text(category)),
      body: ListView(padding: const EdgeInsets.fromLTRB(14, 4, 14, 26), children: [
        UtiliaGradientHeader(title: category, subtitle: subtitle, color: tint, icon: widget.tools.first.icon),
        const SizedBox(height: 16),
        ...widget.tools.map((tool) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _toolCard(context, tool))),
      ]),
    );
  }

  Widget _toolCard(BuildContext context, UtiliaTool tool) {
    final accent = UtiliaBrand.categoryColor(widget.category, tool.tint); final favorite = favorites.contains(tool.type);
    return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => openUtiliaTool(context, tool, widget.storage, widget.onHistory, widget.s), child: Padding(padding: const EdgeInsets.all(11), child: Row(children: [
      UtiliaSoftIcon(icon: tool.icon, color: accent, size: 48), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.s.toolName(tool.type.name, tool.name), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 2), Text(widget.s.toolDescription(tool.type.name, tool.description), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])),
      IconButton(onPressed: () => _toggleFavorite(tool.type), tooltip: widget.s.favorites, icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? accent : Theme.of(context).colorScheme.outline)),
    ]))));
  }
}

void openUtiliaTool(BuildContext context, UtiliaTool tool, UtiliaStorage storage, Future<void> Function()? refresh, UtiliaStrings s) {
  if (tool.type == ToolType.calculator || tool.type == ToolType.scientificCalculator) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CalculatorSuitePage(scientific: tool.type == ToolType.scientificCalculator, storage: storage, s: s, onHistory: refresh)));
  } else if (tool.type == ToolType.paint) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaintCalculatorPage(tool: tool, storage: storage, onHistory: refresh, s: s)));
  } else {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CalculatorPage(tool: tool, storage: storage, onHistory: refresh, s: s)));
  }
}
