import 'package:flutter/material.dart';

import 'calculator_suite.dart';
import 'catalog.dart';
import 'localization.dart';
import 'models/tool.dart';
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

  @override
  State<UtiliaCategoryPage> createState() => _UtiliaCategoryPageState();
}

class _UtiliaCategoryPageState extends State<UtiliaCategoryPage> {
  late Set<ToolType> favorites;

  @override
  void initState() {
    super.initState();
    favorites = {...widget.favorites};
  }

  Future<void> _toggleFavorite(ToolType type) async {
    final next = {...favorites};
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }
    setState(() => favorites = next);
    await widget.onFavorite(type);
  }

  @override
  Widget build(BuildContext context) {
    final tint = UtiliaBrand.categoryColor(widget.category, widget.tools.first.tint);
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)), title: Text(widget.s.category(widget.category))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tint, tint.withValues(alpha: .70)]), borderRadius: BorderRadius.circular(28)), child: Row(children: [
          Container(width: 62, height: 62, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(19)), child: Icon(widget.tools.first.icon, color: Colors.white, size: 32)),
          const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.s.category(widget.category), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(widget.s.toolsCount(widget.tools.length), style: TextStyle(color: Colors.white.withValues(alpha: .88), fontWeight: FontWeight.w600))])),
        ])),
        const SizedBox(height: 20),
        ...widget.tools.map((tool) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _toolCard(context, tool))),
      ]),
    );
  }

  Widget _toolCard(BuildContext context, UtiliaTool tool) {
    final accent = UtiliaBrand.categoryColor(widget.category, tool.tint);
    final favorite = favorites.contains(tool.type);
    return Card(child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () => openUtiliaTool(context, tool, widget.storage, widget.onHistory, widget.s), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(17)), child: Icon(tool.icon, color: accent, size: 27)),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.s.toolName(tool.type.name, tool.name), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text(widget.s.toolDescription(tool.type.name, tool.description), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])),
      IconButton(onPressed: () => _toggleFavorite(tool.type), tooltip: widget.s.favorites, icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? accent : Theme.of(context).colorScheme.outline)),
    ])));
  }
}

void openUtiliaTool(BuildContext context, UtiliaTool tool, UtiliaStorage storage, Future<void> Function()? refresh, UtiliaStrings s) {
  if (tool.type == ToolType.calculator || tool.type == ToolType.scientificCalculator) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CalculatorSuitePage(scientific: tool.type == ToolType.scientificCalculator, storage: storage, s: s)));
  } else {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CalculatorPage(tool: tool, storage: storage, onHistory: refresh, s: s)));
  }
}
