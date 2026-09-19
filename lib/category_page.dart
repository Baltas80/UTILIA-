import 'package:flutter/material.dart';

import 'calculator_suite.dart';
import 'localization.dart';
import 'models/tool.dart';
import 'paint_calculator_page.dart';
import 'storage.dart';
import 'tool_calculator_page.dart';
import 'utilia_design.dart';

class UtiliaCategoryPage extends StatefulWidget {
  const UtiliaCategoryPage(
      {super.key,
      required this.category,
      required this.tools,
      required this.favorites,
      required this.onFavorite,
      required this.storage,
      required this.onHistory,
      required this.s});
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
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  @override
  void initState() {
    super.initState();
    favorites = {...widget.favorites};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UtiliaTool> get _visibleTools {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.tools;
    return widget.tools.where((tool) {
      final name = widget.s.toolName(tool.type.name, tool.name).toLowerCase();
      final description =
          widget.s.toolDescription(tool.type.name, tool.description).toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  Future<void> _toggleFavorite(ToolType type) async {
    final next = {...favorites};
    next.contains(type) ? next.remove(type) : next.add(type);
    setState(() => favorites = next);
    await widget.onFavorite(type);
  }

  String text(
          String es, String en, String fr, String de, String it, String pt) =>
      switch (widget.s.selectedLanguage) {
        UtiliaLanguage.en => en,
        UtiliaLanguage.fr => fr,
        UtiliaLanguage.de => de,
        UtiliaLanguage.it => it,
        UtiliaLanguage.pt => pt,
        _ => es
      };

  String _categorySubtitle() {
    return switch (widget.category) {
      'Dinero' => text(
          'Herramientas para gestionar tu dinero.',
          'Tools to manage your money.',
          'Des outils pour gérer votre argent.',
          'Werkzeuge zur Verwaltung Ihres Geldes.',
          'Strumenti per gestire il tuo denaro.',
          'Ferramentas para gerir o seu dinheiro.'),
      'Tiempo' => text(
          'Herramientas para organizar mejor tu tiempo.',
          'Tools to organize your time better.',
          'Des outils pour mieux organiser votre temps.',
          'Werkzeuge für eine bessere Zeitplanung.',
          'Strumenti per organizzare meglio il tuo tempo.',
          'Ferramentas para organizar melhor o seu tempo.'),
      'Casa' => text(
          'Cálculos prácticos para tu hogar.',
          'Practical calculations for your home.',
          'Des calculs pratiques pour votre maison.',
          'Praktische Berechnungen für Ihr Zuhause.',
          'Calcoli pratici per la tua casa.',
          'Cálculos práticos para a sua casa.'),
      'Coche' => text(
          'Herramientas para tus viajes y tu coche.',
          'Tools for your car and journeys.',
          'Des outils pour votre voiture et vos trajets.',
          'Werkzeuge für Ihr Auto und Ihre Fahrten.',
          'Strumenti per la tua auto e i tuoi viaggi.',
          'Ferramentas para o seu carro e as suas viagens.'),
      'Conversores' => text(
          'Convierte fácilmente entre unidades.',
          'Convert easily between units.',
          'Convertissez facilement entre les unités.',
          'Einheiten einfach umrechnen.',
          'Converti facilmente tra unità.',
          'Converta facilmente entre unidades.'),
      'Salud' => text(
          'Cálculos útiles relacionados con tu bienestar.',
          'Useful calculations related to your wellbeing.',
          'Des calculs utiles liés à votre bien-être.',
          'Nützliche Berechnungen rund um Ihr Wohlbefinden.',
          'Calcoli utili per il tuo benessere.',
          'Cálculos úteis relacionados com o seu bem-estar.'),
      'Estudio' => text(
          'Herramientas para estudiar y aprender.',
          'Tools for studying and learning.',
          'Des outils pour étudier et apprendre.',
          'Werkzeuge zum Lernen und Studieren.',
          'Strumenti per studiare e imparare.',
          'Ferramentas para estudar e aprender.'),
      _ => text(
          'Herramientas prácticas para tu día a día.',
          'Practical tools for everyday life.',
          'Des outils pratiques pour votre quotidien.',
          'Praktische Werkzeuge für den Alltag.',
          'Strumenti pratici per la vita quotidiana.',
          'Ferramentas práticas para o dia a dia.'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tint =
        UtiliaBrand.categoryColor(widget.category, widget.tools.first.tint);
    final category = widget.s.category(widget.category);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              child: _searching
                  ? Row(children: [
                      IconButton(
                        tooltip: text('Cerrar búsqueda', 'Close search',
                            'Fermer la recherche', 'Suche schließen',
                            'Chiudi ricerca', 'Fechar pesquisa'),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _searching = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: widget.s.search,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        IconButton(
                          tooltip: text('Borrar búsqueda', 'Clear search',
                              'Effacer la recherche', 'Suche löschen',
                              'Cancella ricerca', 'Limpar pesquisa'),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear_rounded),
                        ),
                    ])
                  : Row(children: [
                      IconButton(
                          tooltip: text('Volver', 'Back', 'Retour', 'Zurück',
                              'Indietro', 'Voltar'),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded)),
                      Expanded(
                          child: Text(category,
                              style: Theme.of(context).textTheme.titleLarge)),
                      IconButton(
                          tooltip: widget.s.search,
                          onPressed: () => setState(() => _searching = true),
                          icon: const Icon(Icons.search_rounded)),
                    ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: UtiliaGradientHeader(
                  title: category,
                  subtitle: _categorySubtitle(),
                  color: tint,
                  icon: widget.tools.first.icon),
            ),
            Expanded(
              child: _visibleTools.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 42,
                                color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 12),
                            Text(widget.s.noResults,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _visibleTools.length,
                      itemBuilder: (_, i) =>
                          _toolCard(context, _visibleTools[i])),
            ),
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
          onTap: () => openUtiliaTool(
              context, tool, widget.storage, widget.onHistory, widget.s),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            child: Row(children: [
              UtiliaSoftIcon(icon: tool.icon, color: accent, size: 48),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.s.toolName(tool.type.name, tool.name),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                        widget.s
                            .toolDescription(tool.type.name, tool.description),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ])),
              IconButton(
                  tooltip: favorite
                      ? text('Quitar de favoritos', 'Remove from favorites',
                          'Retirer des favoris', 'Aus Favoriten entfernen',
                          'Rimuovi dai preferiti', 'Remover dos favoritos')
                      : text('Añadir a favoritos', 'Add to favorites',
                          'Ajouter aux favoris', 'Zu Favoriten hinzufügen',
                          'Aggiungi ai preferiti', 'Adicionar aos favoritos'),
                  onPressed: () => _toggleFavorite(tool.type),
                  icon: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorite
                          ? const Color(0xFFE83D69)
                          : Theme.of(context).colorScheme.outline)),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

void openUtiliaTool(BuildContext context, UtiliaTool tool,
    UtiliaStorage storage, Future<void> Function()? refresh, UtiliaStrings s) {
  if (tool.type == ToolType.calculator ||
      tool.type == ToolType.scientificCalculator) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CalculatorSuitePage(
                scientific: tool.type == ToolType.scientificCalculator,
                storage: storage,
                s: s,
                onHistory: refresh)));
  } else if (tool.type == ToolType.paint) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PaintCalculatorPage(
                tool: tool, storage: storage, onHistory: refresh, s: s)));
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CalculatorPage(
                tool: tool, storage: storage, onHistory: refresh, s: s)));
  }
}
