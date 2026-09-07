import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'catalog.dart';
import 'category_page.dart';
import 'localization.dart';
import 'models/tool.dart';
import 'storage.dart';
import 'utilia_design.dart';

class UtiliaPremiumApp extends StatefulWidget {
  const UtiliaPremiumApp({super.key});
  @override State<UtiliaPremiumApp> createState() => _UtiliaPremiumAppState();
}

class _UtiliaPremiumAppState extends State<UtiliaPremiumApp> {
  final storage = UtiliaStorage();
  bool darkMode = false;
  UtiliaLanguage language = UtiliaLanguage.system;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final d = await storage.loadDarkMode(); final l = UtiliaStrings.fromCode(await storage.loadLanguage()); if (mounted) setState(() { darkMode = d; language = l; }); }
  Future<void> _theme(bool value) async { setState(() => darkMode = value); await storage.saveDarkMode(value); }
  Future<void> _language(UtiliaLanguage value) async { setState(() => language = value); await storage.saveLanguage(UtiliaStrings.code(value)); }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UTILIA',
        locale: UtiliaStrings.locale(language),
        supportedLocales: const [Locale('es'), Locale('en'), Locale('fr'), Locale('de'), Locale('it'), Locale('pt')],
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        theme: utiliaTheme(Brightness.light),
        darkTheme: utiliaTheme(Brightness.dark),
        home: UtiliaHomePage(storage: storage, darkMode: darkMode, language: language, onTheme: _theme, onLanguage: _language),
      );
}

class UtiliaHomePage extends StatefulWidget {
  const UtiliaHomePage({super.key, required this.storage, required this.darkMode, required this.language, required this.onTheme, required this.onLanguage});
  final UtiliaStorage storage;
  final bool darkMode;
  final UtiliaLanguage language;
  final Future<void> Function(bool) onTheme;
  final Future<void> Function(UtiliaLanguage) onLanguage;
  @override State<UtiliaHomePage> createState() => _UtiliaHomePageState();
}

class _UtiliaHomePageState extends State<UtiliaHomePage> {
  int tab = 0;
  Set<ToolType> favorites = {};
  List<Map<String, dynamic>> history = [];

  UtiliaStrings get s => UtiliaStrings(widget.language == UtiliaLanguage.system ? UtiliaStrings.effective(UtiliaLanguage.system, Localizations.localeOf(context)) : widget.language);
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final f = await widget.storage.loadFavorites(); final h = await widget.storage.loadHistory(); if (mounted) setState(() { favorites = f.map(_type).whereType<ToolType>().toSet(); history = h; }); }
  ToolType? _type(String value) => ToolType.values.where((t) => t.name == value).cast<ToolType?>().firstWhere((_) => true, orElse: () => null);
  UtiliaTool? _findTool(ToolType type) { for (final tool in tools) { if (tool.type == type) return tool; } return null; }
  Future<void> _favorite(ToolType type) async { final next = {...favorites}; next.contains(type) ? next.remove(type) : next.add(type); setState(() => favorites = next); await widget.storage.saveFavorites(next.map((e) => e.name).toSet()); }
  String name(UtiliaTool tool) => s.toolName(tool.type.name, tool.name);
  String desc(UtiliaTool tool) => s.toolDescription(tool.type.name, tool.description);
  String cat(String value) => s.category(value);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _topBar(),
        body: IndexedStack(index: tab, children: [_dashboard(), _favoritesView(), _historyView(), _moreView()]),
        bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (value) => setState(() => tab = value), destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: s.home),
          NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: s.favorites),
          NavigationDestination(icon: const Icon(Icons.history_rounded), selectedIcon: const Icon(Icons.history_rounded), label: s.history),
          NavigationDestination(icon: const Icon(Icons.tune_rounded), selectedIcon: const Icon(Icons.tune_rounded), label: s.more),
        ]),
      );

  PreferredSizeWidget _topBar() => AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Row(children: [UtiliaLogoMark(size: 42), SizedBox(width: 12), Text('UTILIA')]),
        actions: [IconButton(onPressed: () => showAboutDialog(context: context, applicationName: 'UTILIA', applicationVersion: '0.5.0', applicationLegalese: s.slogan), icon: const Icon(Icons.info_outline_rounded)), const SizedBox(width: 10)],
      );

  Widget _dashboard() {
    final quickTypes = [ToolType.calculator, ToolType.scientificCalculator, ToolType.percentage, ToolType.discount];
    final quick = quickTypes.map(_findTool).whereType<UtiliaTool>().toList();
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
      _hero(),
      const SizedBox(height: 24),
      UtiliaSectionTitle(title: 'Acceso rápido', action: TextButton(onPressed: () => setState(() => tab = 1), child: Text(s.favorites))),
      const SizedBox(height: 12),
      SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: quick.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _quickCard(quick[i]))),
      const SizedBox(height: 28),
      UtiliaSectionTitle(title: s.categories, action: Text('${tools.length}')),
      const SizedBox(height: 14),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: categories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.18), itemBuilder: (_, i) => _categoryCard(categories[i])),
    ]);
  }

  Widget _hero() => Container(
        height: 190,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [UtiliaBrand.blue, UtiliaBrand.violet]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: UtiliaBrand.blue.withValues(alpha: .18), blurRadius: 28, offset: const Offset(0, 14))]),
        child: Stack(children: [
          Positioned(right: -32, top: -42, child: _orb(150, .11)),
          Positioned(right: 62, bottom: -82, child: _orb(145, .07)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('HERRAMIENTAS PARA TU DÍA A DÍA', style: TextStyle(color: Colors.white.withValues(alpha: .76), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)), const SizedBox(height: 10), Text(s.slogan, style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.7)), const SizedBox(height: 11), Text('Todo lo útil, en un solo lugar.', style: TextStyle(color: Colors.white.withValues(alpha: .90), fontSize: 14, fontWeight: FontWeight.w600))]),
        ]),
      );

  Widget _orb(double size, double opacity) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: opacity)));

  Widget _quickCard(UtiliaTool tool) {
    final accent = tool.type == ToolType.scientificCalculator ? UtiliaBrand.violet : UtiliaBrand.blue;
    return SizedBox(width: 126, child: Card(child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(gradient: LinearGradient(colors: [accent.withValues(alpha: .18), accent.withValues(alpha: .07)]), borderRadius: BorderRadius.circular(13)), child: Icon(tool.icon, color: accent, size: 22)), const Spacer(), Text(name(tool), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge)]))));
  }

  Widget _categoryCard(String category) {
    final list = tools.where((t) => t.category == category).toList();
    final accent = UtiliaBrand.categoryColor(category, list.first.tint);
    return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UtiliaCategoryPage(category: category, tools: list, favorites: favorites, onFavorite: _favorite, storage: widget.storage, onHistory: _load, s: s))), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withValues(alpha: .20), accent.withValues(alpha: .06)]), borderRadius: BorderRadius.circular(16)), child: Icon(list.first.icon, color: accent, size: 26)), const Spacer(), Text(cat(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 3), Row(children: [Expanded(child: Text(s.toolsCount(list.length), style: Theme.of(context).textTheme.bodyMedium)), Icon(Icons.arrow_forward_rounded, size: 18, color: accent)])]))));
  }

  Widget _toolTile(UtiliaTool tool) {
    final accent = UtiliaBrand.categoryColor(tool.category, tool.tint);
    final favorite = favorites.contains(tool.type);
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: accent.withValues(alpha: .11), borderRadius: BorderRadius.circular(16)), child: Icon(tool.icon, color: accent, size: 25)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name(tool), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 3), Text(desc(tool), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])), IconButton(onPressed: () => _favorite(tool.type), icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? accent : Theme.of(context).colorScheme.outline))]))));
  }

  Widget _favoritesView() => favorites.isEmpty ? _empty(Icons.favorite_border_rounded, s.emptyFavorites) : ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), children: [Text(s.favorites, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 16), ...tools.where((t) => favorites.contains(t.type)).map(_toolTile)]);

  Widget _historyView() => history.isEmpty ? _empty(Icons.history_rounded, s.emptyHistory) : ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(s.history, style: Theme.of(context).textTheme.headlineSmall), TextButton.icon(onPressed: () async { await widget.storage.clearHistory(); await _load(); }, icon: const Icon(Icons.delete_outline_rounded), label: Text(s.clearHistory))]), const SizedBox(height: 12), ...history.map((h) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.calculate_rounded, color: Theme.of(context).colorScheme.primary)), title: Text('${h['tool'] ?? ''}', style: Theme.of(context).textTheme.titleMedium), subtitle: Text(h['expression'] == null ? '${h['result'] ?? ''}' : '${h['expression']} = ${h['result']}'))))]);

  Widget _moreView() => ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), children: [Text(s.more, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const UtiliaLogoMark(size: 52), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('UTILIA', style: Theme.of(context).textTheme.titleLarge), Text('0.5.0', style: Theme.of(context).textTheme.bodyMedium)])), Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary)]))), const SizedBox(height: 12), Card(child: SwitchListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5), secondary: Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.dark_mode_outlined)), title: Text(s.darkMode, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(s.savedDevice), value: widget.darkMode, onChanged: widget.onTheme)), const SizedBox(height: 10), Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.language_rounded)), title: Text(s.languageLabel, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(UtiliaStrings(widget.language).languageName), trailing: const Icon(Icons.chevron_right_rounded), onTap: _pickLanguage))]);

  Widget _empty(IconData icon, String text) => Center(child: Padding(padding: const EdgeInsets.all(42), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 76, height: 76, decoration: BoxDecoration(gradient: const LinearGradient(colors: [UtiliaBrand.blue, UtiliaBrand.violet]), shape: BoxShape.circle), child: Icon(icon, size: 35, color: Colors.white)), const SizedBox(height: 18), Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)])));

  Future<void> _pickLanguage() async { final value = await showDialog<UtiliaLanguage>(context: context, builder: (c) => SimpleDialog(title: Text(s.languageLabel), children: UtiliaLanguage.values.map((l) => SimpleDialogOption(onPressed: () => Navigator.pop(c, l), child: Text(UtiliaStrings(l).languageName))).toList())); if (value != null) await widget.onLanguage(value); }
}
