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
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'UTILIA', locale: UtiliaStrings.locale(language),
    supportedLocales: const [Locale('es'), Locale('en'), Locale('fr'), Locale('de'), Locale('it'), Locale('pt')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    themeMode: darkMode ? ThemeMode.dark : ThemeMode.light, theme: utiliaTheme(Brightness.light), darkTheme: utiliaTheme(Brightness.dark),
    home: UtiliaHomePage(storage: storage, darkMode: darkMode, language: language, onTheme: _theme, onLanguage: _language),
  );
}

class UtiliaHomePage extends StatefulWidget {
  const UtiliaHomePage({super.key, required this.storage, required this.darkMode, required this.language, required this.onTheme, required this.onLanguage});
  final UtiliaStorage storage; final bool darkMode; final UtiliaLanguage language;
  final Future<void> Function(bool) onTheme; final Future<void> Function(UtiliaLanguage) onLanguage;
  @override State<UtiliaHomePage> createState() => _UtiliaHomePageState();
}

class _UtiliaHomePageState extends State<UtiliaHomePage> {
  int tab = 0; Set<ToolType> favorites = {}; List<Map<String, dynamic>> history = [];
  UtiliaStrings get s => UtiliaStrings(widget.language == UtiliaLanguage.system ? UtiliaStrings.effective(UtiliaLanguage.system, Localizations.localeOf(context)) : widget.language);
  String get _quickAccess => switch (s.selectedLanguage) { UtiliaLanguage.en => 'Quick access', UtiliaLanguage.fr => 'Accès rapide', UtiliaLanguage.de => 'Schnellzugriff', UtiliaLanguage.it => 'Accesso rapido', UtiliaLanguage.pt => 'Acesso rápido', _ => 'Acceso rápido' };
  String get _heroEyebrow => switch (s.selectedLanguage) { UtiliaLanguage.en => 'TOOLS FOR EVERYDAY LIFE', UtiliaLanguage.fr => 'DES OUTILS POUR VOTRE QUOTIDIEN', UtiliaLanguage.de => 'WERKZEUGE FÜR DEN ALLTAG', UtiliaLanguage.it => 'STRUMENTI PER LA VITA QUOTIDIANA', UtiliaLanguage.pt => 'FERRAMENTAS PARA O DIA A DIA', _ => 'HERRAMIENTAS PARA TU DÍA A DÍA' };
  String get _heroSubtitle => switch (s.selectedLanguage) { UtiliaLanguage.en => 'Everything you need in one app.', UtiliaLanguage.fr => 'Tout ce dont vous avez besoin dans une seule app.', UtiliaLanguage.de => 'Alles, was Sie brauchen, in einer App.', UtiliaLanguage.it => 'Tutto ciò che serve in un’unica app.', UtiliaLanguage.pt => 'Tudo o que precisa numa só app.', _ => 'Todo lo que necesitas en una sola app.' };
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final f = await widget.storage.loadFavorites(); final h = await widget.storage.loadHistory(); if (mounted) setState(() { favorites = f.map(_type).whereType<ToolType>().toSet(); history = h; }); }
  ToolType? _type(String value) => ToolType.values.where((t) => t.name == value).cast<ToolType?>().firstWhere((_) => true, orElse: () => null);
  UtiliaTool? _findTool(ToolType type) { for (final tool in tools) { if (tool.type == type) return tool; } return null; }
  Future<void> _favorite(ToolType type) async { final next = {...favorites}; next.contains(type) ? next.remove(type) : next.add(type); setState(() => favorites = next); await widget.storage.saveFavorites(next.map((e) => e.name).toSet()); }
  String name(UtiliaTool tool) => s.toolName(tool.type.name, tool.name);
  String desc(UtiliaTool tool) => s.toolDescription(tool.type.name, tool.description);

  @override Widget build(BuildContext context) => Scaffold(
    appBar: _topBar(), body: IndexedStack(index: tab, children: [_dashboard(), _favoritesView(), _historyView(), _moreView()]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [
      NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: s.home),
      NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: s.favorites),
      NavigationDestination(icon: const Icon(Icons.history_rounded), selectedIcon: const Icon(Icons.history_rounded), label: s.history),
      NavigationDestination(icon: const Icon(Icons.grid_view_rounded), selectedIcon: const Icon(Icons.grid_view_rounded), label: s.more),
    ]),
  );

  PreferredSizeWidget _topBar() => AppBar(
    automaticallyImplyLeading: false, titleSpacing: 18,
    title: Row(children: [const UtiliaLogoMark(size: 40), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('UTILIA', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text('Herramientas para tu día a día', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600))])]),
    actions: [IconButton(onPressed: () => setState(() => tab = 3), icon: const Icon(Icons.settings_outlined)), const SizedBox(width: 8)],
  );

  Widget _dashboard() {
    final quickTypes = [ToolType.calculator, ToolType.scientificCalculator, ToolType.percentage, ToolType.ruleOfThree];
    final quick = quickTypes.map(_findTool).whereType<UtiliaTool>().toList();
    return ListView(padding: const EdgeInsets.fromLTRB(14, 4, 14, 24), children: [
      _hero(), const SizedBox(height: 14), _benefits(), const SizedBox(height: 21),
      UtiliaSectionTitle(title: _quickAccess, action: TextButton(onPressed: () => setState(() => tab = 1), child: Text(s.favorites))),
      const SizedBox(height: 8), SizedBox(height: 91, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: quick.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => _quickCard(quick[i]))),
      const SizedBox(height: 21), UtiliaSectionTitle(title: s.categories, action: TextButton(onPressed: () {}, child: Text(s.results))), const SizedBox(height: 8),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: categories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.12), itemBuilder: (_, i) => _categoryCard(categories[i])),
    ]);
  }

  Widget _hero() => Container(height: 205, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF86C8FF), Color(0xFFFFC98E), Color(0xFF173D65)]), boxShadow: [BoxShadow(color: UtiliaBrand.blue.withValues(alpha: .14), blurRadius: 24, offset: const Offset(0, 10))]), child: Stack(children: [Positioned.fill(child: CustomPaint(painter: _HomeMountainPainter())), Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .58)])))), Padding(padding: const EdgeInsets.fromLTRB(18, 22, 18, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Text(_heroEyebrow, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1)), const SizedBox(height: 7), Text(s.slogan, style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.02, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(_heroSubtitle, style: TextStyle(color: Colors.white.withValues(alpha: .94), fontSize: 12.5, fontWeight: FontWeight.w600))]))]));

  Widget _benefits() => Row(children: [_benefit(Icons.bolt_rounded, 'Útil'), const SizedBox(width: 7), _benefit(Icons.favorite_border_rounded, 'Simple'), const SizedBox(width: 7), _benefit(Icons.all_inclusive_rounded, 'Siempre contigo')]);
  Widget _benefit(IconData icon, String label) => Expanded(child: Container(height: 48, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(15)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: UtiliaBrand.blue), const SizedBox(height: 1), Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9))])));

  Widget _quickCard(UtiliaTool tool) { final accent = tool.type == ToolType.scientificCalculator ? UtiliaBrand.violet : UtiliaBrand.blue; return SizedBox(width: 88, child: Card(child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(9), child: Column(children: [UtiliaSoftIcon(icon: tool.icon, color: accent, size: 40), const Spacer(), Text(name(tool), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9.5))])))));
  }

  Widget _categoryCard(String category) { final list = tools.where((t) => t.category == category).toList(); final accent = UtiliaBrand.categoryColor(category, list.first.tint); return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UtiliaCategoryPage(category: category, tools: list, favorites: favorites, onFavorite: _favorite, storage: widget.storage, onHistory: _load, s: s))), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [UtiliaSoftIcon(icon: list.first.icon, color: accent, size: 45), const Spacer(), Text(s.category(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)), const SizedBox(height: 2), Row(children: [Expanded(child: Text(s.toolsCount(list.length), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10))), Icon(Icons.chevron_right_rounded, size: 17, color: accent)])])))); }

  Widget _toolTile(UtiliaTool tool) { final accent = UtiliaBrand.categoryColor(tool.category, tool.tint); final favorite = favorites.contains(tool.type); return Padding(padding: const EdgeInsets.only(bottom: 8), child: Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(11), child: Row(children: [UtiliaSoftIcon(icon: tool.icon, color: accent, size: 45), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name(tool), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 2), Text(desc(tool), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])), IconButton(onPressed: () => _favorite(tool.type), icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? accent : Theme.of(context).colorScheme.outline))]))))); }

  Widget _favoritesView() => favorites.isEmpty ? _empty(Icons.favorite_border_rounded, s.emptyFavorites) : ListView(padding: const EdgeInsets.fromLTRB(14, 18, 14, 24), children: [Text(s.favorites, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 4), Text('Tus herramientas favoritas, siempre a mano.', style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 14), ...tools.where((t) => favorites.contains(t.type)).map(_toolTile)]);

  Widget _historyView() => history.isEmpty ? _empty(Icons.history_rounded, s.emptyHistory) : ListView(padding: const EdgeInsets.fromLTRB(14, 18, 14, 24), children: [Row(children: [Expanded(child: Text(s.history, style: Theme.of(context).textTheme.headlineSmall)), IconButton(onPressed: () async { await widget.storage.clearHistory(); await _load(); }, icon: const Icon(Icons.delete_outline_rounded))]), const SizedBox(height: 7), Row(children: [UtiliaPill(label: s.results, selected: true), const SizedBox(width: 6), UtiliaPill(label: s.calculate)]), const SizedBox(height: 11), ...history.map((h) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), leading: UtiliaSoftIcon(icon: Icons.functions_rounded, color: UtiliaBrand.blue, size: 40), title: Text('${h['tool'] ?? ''}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13)), subtitle: Text(h['expression'] == null ? '${h['result'] ?? ''}' : '${h['expression']} = ${h['result']}')))))]);

  Widget _moreView() => ListView(padding: const EdgeInsets.fromLTRB(14, 18, 14, 24), children: [Text(s.more, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 15), Card(child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [const UtiliaLogoMark(size: 50), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('UTILIA', style: Theme.of(context).textTheme.titleLarge), Text('v0.5.1', style: Theme.of(context).textTheme.bodyMedium)])), Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary)]))), const SizedBox(height: 10), _settingTile(Icons.dark_mode_outlined, s.darkMode, s.savedDevice, trailing: Switch(value: widget.darkMode, onChanged: widget.onTheme)), const SizedBox(height: 8), _settingTile(Icons.language_rounded, s.languageLabel, UtiliaStrings(widget.language).languageName, onTap: _pickLanguage), const SizedBox(height: 8), _settingTile(Icons.privacy_tip_outlined, 'Privacidad', 'Tus datos, tu control'), const SizedBox(height: 8), _settingTile(Icons.info_outline_rounded, 'Acerca de', 'UTILIA v0.5.1')]);
  Widget _settingTile(IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) => Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3), leading: UtiliaSoftIcon(icon: icon, color: UtiliaBrand.blue, size: 43), title: Text(title, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium), trailing: trailing ?? const Icon(Icons.chevron_right_rounded), onTap: onTap));
  Widget _empty(IconData icon, String text) => Center(child: Padding(padding: const EdgeInsets.all(42), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const UtiliaLogoMark(size: 72), const SizedBox(height: 18), Icon(icon, size: 32, color: UtiliaBrand.blue), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)])));
  Future<void> _pickLanguage() async { final value = await showDialog<UtiliaLanguage>(context: context, builder: (c) => SimpleDialog(title: Text(s.languageLabel), children: UtiliaLanguage.values.map((l) => SimpleDialogOption(onPressed: () => Navigator.pop(c, l), child: Text(UtiliaStrings(l).languageName))).toList())); if (value != null) await widget.onLanguage(value); }
}

class _HomeMountainPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF86C8FF), Color(0xFFFFC98E), Color(0xFF21496E)]).createShader(rect));
    canvas.drawCircle(Offset(size.width * .78, size.height * .20), size.shortestSide * .11, Paint()..color = Colors.white.withValues(alpha: .62));
    Path m(double peak, double base, double offset) => Path()..moveTo(0, size.height * base)..lineTo(size.width * .25, size.height * (base - .20))..lineTo(size.width * .44 + offset, size.height * peak)..lineTo(size.width * .63, size.height * (base - .12))..lineTo(size.width, size.height * (base - .03))..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(m(.20, .82, 0), Paint()..color = const Color(0xFF315E7E).withValues(alpha: .85));
    canvas.drawPath(m(.34, .91, -.04), Paint()..color = const Color(0xFF173A59).withValues(alpha: .95));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
