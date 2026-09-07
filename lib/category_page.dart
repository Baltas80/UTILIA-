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
  final String category;
  final List<UtiliaTool> tools;
  final Set<ToolType> favorites;
  final Future<void> Function(ToolType) onFavorite;
  final UtiliaStorage storage;
  final Future<void> Function() onHistory;
  final UtiliaStrings s;
  @override State<UtiliaCategoryPage> createState() => _UtiliaCategoryPageState();
}

class _UtiliaCategoryPageState extends State<UtiliaCategoryPage> {
  late Set<ToolType> favorites;
  @override void initState() { super.initState(); favorites = {...widget.favorites}; }
  Future<void> _toggleFavorite(ToolType type) async { final next = {...favorites}; next.contains(type) ? next.remove(type) : next.add(type); setState(() => favorites = next); await widget.onFavorite(type); }
  String text(String es, String en, String fr, String de, String it, String pt) => switch (widget.s.selectedLanguage) { UtiliaLanguage.en => en, UtiliaLanguage.fr => fr, UtiliaLanguage.de => de, UtiliaLanguage.it => it, UtiliaLanguage.pt => pt, _ => es };

  @override
  Widget build(BuildContext context) {
    final tint = UtiliaBrand.categoryColor(widget.category, widget.tools.first.tint);
    final category = widget.s.category(widget.category);
    final subtitle = text('Herramientas para tu día a día.', 'Tools for everyday life.', 'Des outils pour votre quotidien.', 'Werkzeuge für den Alltag.', 'Strumenti per la vita quotidiana.', 'Ferramentas para o dia a dia.');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
                Expanded(child: Text(category, style: Theme.of(context).textTheme.titleLarge)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Align(alignment: Alignment.centerLeft, child: Text(text('Todo en su lugar, para tu día a día.', 'Everything in its place, for everyday life.', 'Tout à sa place, pour votre quotidien.', 'Alles an seinem Platz für deinen Alltag.', 'Tutto al suo posto, per la vita di ogni giorno.', 'Tudo no seu lugar, para o seu dia a dia.'), style: Theme.of(context).textTheme.headlineSmall)),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: UtiliaGradientHeader(title: category, subtitle: subtitle, color: tint, icon: widget.tools.first.icon)),
            const SizedBox(height: 12),
            Expanded(child: ListView.builder(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), itemCount: widget.tools.length, itemBuilder: (_, i) => _toolCard(context, widget.tools[i]))),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(BuildContext context, UtiliaTool tool) {
    final accent = UtiliaBrand.categoryColor(widget.category, tool.tint);
    final favorite = favorites.contains(tool.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => openUtiliaTool(context, tool, widget.storage, widget.onHistory, widget.s),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            child: Row(children: [
              UtiliaSoftIcon(icon: tool.icon, color: accent, size: 48),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.s.toolName(tool.type.name, tool.name), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(widget.s.toolDescription(tool.type.name, tool.description), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              ])),
              IconButton(onPressed: () => _toggleFavorite(tool.type), icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? const Color(0xFFE83D69) : Theme.of(context).colorScheme.outline)),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ]),
          ),
        ),
      ),
    );
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
