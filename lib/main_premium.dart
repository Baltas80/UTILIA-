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
  @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, title: 'UTILIA', locale: UtiliaStrings.locale(language), supportedLocales: const [Locale('es'), Locale('en'), Locale('fr'), Locale('de'), Locale('it'), Locale('pt')], localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate], themeMode: darkMode ? ThemeMode.dark : ThemeMode.light, theme: utiliaTheme(Brightness.light), darkTheme: utiliaTheme(Brightness.dark), home: UtiliaHomePage(storage: storage, darkMode: darkMode, language: language, onTheme: _theme, onLanguage: _language));
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
  String text(String es, String en, String fr, String de, String it, String pt) => switch (s.selectedLanguage) { UtiliaLanguage.en => en, UtiliaLanguage.fr => fr, UtiliaLanguage.de => de, UtiliaLanguage.it => it, UtiliaLanguage.pt => pt, _ => es };
  String get _subtitle => text('Herramientas para tu día a día', 'Tools for everyday life', 'Des outils pour votre quotidien', 'Werkzeuge für den Alltag', 'Strumenti per la vita quotidiana', 'Ferramentas para o dia a dia');
  String get _eyebrow => text('HERRAMIENTAS PARA TU DÍA A DÍA', 'TOOLS FOR EVERYDAY LIFE', 'DES OUTILS POUR VOTRE QUOTIDIEN', 'WERKZEUGE FÜR DEN ALLTAG', 'STRUMENTI PER LA VITA QUOTIDIANA', 'FERRAMENTAS PARA O DIA A DIA');
  String get _heroSub => text('Todo lo que necesitas en una sola app.', 'Everything you need in one app.', 'Tout ce dont vous avez besoin dans une seule app.', 'Alles, was Sie brauchen, in einer App.', 'Tutto ciò che serve in un’unica app.', 'Tudo o que precisa numa só app.');
  String get _seeAll => text('Ver todas', 'See all', 'Voir tout', 'Alle anzeigen', 'Vedi tutto', 'Ver tudo');
  String get _favoriteSub => text('Tus herramientas favoritas, siempre a mano.', 'Your favorite tools, always at hand.', 'Vos outils préférés, toujours à portée de main.', 'Ihre Lieblingswerkzeuge immer griffbereit.', 'I tuoi strumenti preferiti, sempre a portata di mano.', 'As suas ferramentas favoritas, sempre à mão.');

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final f = await widget.storage.loadFavorites(); final h = await widget.storage.loadHistory(); if (mounted) setState(() { favorites = f.map(_type).whereType<ToolType>().toSet(); history = h; }); }
  ToolType? _type(String value) { for (final t in ToolType.values) { if (t.name == value) return t; } return null; }
  UtiliaTool? _find(ToolType type) { for (final t in tools) { if (t.type == type) return t; } return null; }
  Future<void> _favorite(ToolType type) async { final next = {...favorites}; if (next.contains(type)) { next.remove(type); } else { next.add(type); } setState(() => favorites = next); await widget.storage.saveFavorites(next.map((e) => e.name).toSet()); }
  String name(UtiliaTool tool) => s.toolName(tool.type.name, tool.name);
  String desc(UtiliaTool tool) => s.toolDescription(tool.type.name, tool.description);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: tab, children: [_home(), _favorites(), _history(), _more()]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [
      NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: s.home),
      NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: s.favorites),
      NavigationDestination(icon: const Icon(Icons.history_rounded), selectedIcon: const Icon(Icons.history_rounded), label: s.history),
      NavigationDestination(icon: const Icon(Icons.grid_view_rounded), selectedIcon: const Icon(Icons.grid_view_rounded), label: s.more),
    ]),
  );

  Widget _brand() => Padding(padding: const EdgeInsets.fromLTRB(18, 7, 14, 8), child: Row(children: [const UtiliaLogoMark(size: 46), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('UTILIA', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)), Text(_subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 9.5, fontWeight: FontWeight.w700))])), IconButton(onPressed: () => setState(() => tab = 3), icon: const Icon(Icons.settings_outlined))]));

  Widget _home() {
    final quickTypes = [ToolType.calculator, ToolType.scientificCalculator, ToolType.percentage, ToolType.ruleOfThree];
    final quick = quickTypes.map(_find).whereType<UtiliaTool>().toList();
    return SafeArea(child: ListView(padding: const EdgeInsets.only(bottom: 18), children: [
      _brand(),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: _hero()),
      const SizedBox(height: 14), Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: _benefits()),
      const SizedBox(height: 20),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: UtiliaSectionTitle(title: text('Acceso rápido', 'Quick access', 'Accès rapide', 'Schnellzugriff', 'Accesso rapido', 'Acesso rápido'), action: TextButton(onPressed: () => setState(() => tab = 1), child: Text(_seeAll)))),
      const SizedBox(height: 7),
      SizedBox(height: 112, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 18), scrollDirection: Axis.horizontal, itemCount: quick.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _quick(quick[i]))),
      const SizedBox(height: 20),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: UtiliaSectionTitle(title: s.categories, action: TextButton(onPressed: () {}, child: Text(_seeAll)))),
      const SizedBox(height: 8),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: categories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 11, crossAxisSpacing: 11, childAspectRatio: 1.15), itemBuilder: (_, i) => _category(categories[i]))),
    ]));
  }

  Widget _hero() => Container(height: 228, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: UtiliaBrand.blue.withValues(alpha: .16), blurRadius: 25, offset: const Offset(0, 12))]), child: Stack(children: [
    const Positioned.fill(child: UtiliaMountainArtwork(borderRadius: 0)),
    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xD9000000)])))),
    Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_eyebrow, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.05)), const SizedBox(height: 7), Text(s.slogan, style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.02, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(_heroSub, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))])),
  ]));

  Widget _benefits() => Row(children: [_benefit(Icons.bolt_rounded, text('Útil', 'Useful', 'Utile', 'Nützlich', 'Utile', 'Útil')), const SizedBox(width: 8), _benefit(Icons.favorite_border_rounded, text('Simple', 'Simple', 'Simple', 'Einfach', 'Semplice', 'Simples')), const SizedBox(width: 8), _benefit(Icons.all_inclusive_rounded, text('Siempre contigo', 'Always with you', 'Toujours avec vous', 'Immer bei dir', 'Sempre con te', 'Sempre consigo'))]);
  Widget _benefit(IconData icon, String label) => Expanded(child: Container(height: 56, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(17)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 21, color: UtiliaBrand.blue), const SizedBox(height: 2), Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10))])));

  Widget _quick(UtiliaTool tool) { final color = tool.type == ToolType.scientificCalculator || tool.type == ToolType.ruleOfThree ? UtiliaBrand.violet : UtiliaBrand.blue; return SizedBox(width: 94, child: Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.fromLTRB(8, 11, 8, 9), child: Column(children: [UtiliaSoftIcon(icon: tool.icon, color: color, size: 48), const Spacer(), Text(name(tool), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9.5))])))));
  }

  Widget _category(String category) { final list = tools.where((t) => t.category == category).toList(); final color = UtiliaBrand.categoryColor(category, list.first.tint); return Card(color: color.withValues(alpha: .10), clipBehavior: Clip.antiAlias, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UtiliaCategoryPage(category: category, tools: list, favorites: favorites, onFavorite: _favorite, storage: widget.storage, onHistory: _load, s: s))), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [UtiliaSoftIcon(icon: list.first.icon, color: color, size: 50), const Spacer(), Text(s.category(category), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)), const SizedBox(height: 2), Row(children: [Expanded(child: Text(s.toolsCount(list.length), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10))), Icon(Icons.chevron_right_rounded, color: color, size: 18)])])))); }

  Widget _darkPage(String title, String subtitle, IconData icon, Widget body) => Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF082B46), Color(0xFF0B1726)])), child: SafeArea(child: Column(children: [_brandDark(title), Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: Row(children: [Expanded(child: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))), Icon(icon, color: Colors.white24, size: 46)])), Expanded(child: Container(decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))), child: body))])));
  Widget _brandDark(String title) => Padding(padding: const EdgeInsets.fromLTRB(12, 7, 14, 6), child: Row(children: [IconButton(onPressed: () => setState(() => tab = 0), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)))]));

  Widget _toolTile(UtiliaTool tool) { final color = UtiliaBrand.categoryColor(tool.category, tool.tint); final fav = favorites.contains(tool.type); return Padding(padding: const EdgeInsets.only(bottom: 8), child: Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [UtiliaSoftIcon(icon: tool.icon, color: color, size: 46), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name(tool), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 2), Text(desc(tool), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])), IconButton(onPressed: () => _favorite(tool.type), icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: fav ? const Color(0xFFE93D68) : Theme.of(context).colorScheme.outline))]))))); }
  Widget _favorites() { final body = favorites.isEmpty ? _empty(Icons.favorite_border_rounded, s.emptyFavorites) : ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 28), children: [...tools.where((t) => favorites.contains(t.type)).map(_toolTile)]); return _darkPage(s.favorites, _favoriteSub, Icons.favorite_rounded, body); }
  Widget _history() { final body = history.isEmpty ? _empty(Icons.history_rounded, s.emptyHistory) : ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 28), children: [Row(children: [UtiliaPill(label: text('Todos', 'All', 'Tous', 'Alle', 'Tutti', 'Todos'), selected: true), const SizedBox(width: 6), UtiliaPill(label: s.calculate), const Spacer(), IconButton(onPressed: () async { await widget.storage.clearHistory(); await _load(); }, icon: const Icon(Icons.delete_outline_rounded))]), const SizedBox(height: 10), ...history.map((h) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2), leading: UtiliaSoftIcon(icon: Icons.functions_rounded, color: UtiliaBrand.blue, size: 40), title: Text('${h['expression'] ?? h['tool'] ?? ''}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.5)), subtitle: Text('${h['result'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium)))))]); return _darkPage(s.history, text('Tus cálculos recientes, siempre disponibles.', 'Your recent calculations, always available.', 'Vos calculs récents, toujours disponibles.', 'Ihre letzten Berechnungen, immer verfügbar.', 'I tuoi calcoli recenti, sempre disponibili.', 'Os seus cálculos recentes, sempre disponíveis.'), Icons.history_rounded, body); }

  Widget _more() => SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 28), children: [Text(s.more, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 13), Card(child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [const UtiliaLogoMark(size: 54), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('UTILIA', style: Theme.of(context).textTheme.titleLarge), Text('v0.5.3', style: Theme.of(context).textTheme.bodyMedium)])), IconButton(onPressed: () => widget.onTheme(!widget.darkMode), icon: Icon(widget.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_outlined, color: UtiliaBrand.blue))]))), const SizedBox(height: 10), _setting(Icons.settings_outlined, text('Ajustes', 'Settings', 'Réglages', 'Einstellungen', 'Impostazioni', 'Definições'), text('Tema, idioma y preferencias', 'Theme, language and preferences', 'Thème, langue et préférences', 'Thema, Sprache und Einstellungen', 'Tema, lingua e preferenze', 'Tema, idioma e preferências'), _pickLanguage), const SizedBox(height: 8), _setting(Icons.new_releases_outlined, text('Novedades', 'What’s new', 'Nouveautés', 'Neuigkeiten', 'Novità', 'Novidades'), text('Ver qué hay de nuevo', 'See what’s new', 'Voir les nouveautés', 'Neuigkeiten ansehen', 'Scopri le novità', 'Ver novidades'), null), const SizedBox(height: 8), _setting(Icons.star_outline_rounded, text('Valora UTILIA', 'Rate UTILIA', 'Évaluer UTILIA', 'UTILIA bewerten', 'Valuta UTILIA', 'Avaliar UTILIA'), text('Tu opinión nos ayuda', 'Your opinion helps us', 'Votre avis nous aide', 'Ihre Meinung hilft uns', 'La tua opinione ci aiuta', 'A sua opinião ajuda-nos'), null), const SizedBox(height: 8), _setting(Icons.share_outlined, text('Compartir app', 'Share app', 'Partager l’app', 'App teilen', 'Condividi app', 'Partilhar app'), text('Recomienda UTILIA', 'Recommend UTILIA', 'Recommandez UTILIA', 'UTILIA empfehlen', 'Consiglia UTILIA', 'Recomende UTILIA'), null), const SizedBox(height: 8), _setting(Icons.privacy_tip_outlined, text('Política de privacidad', 'Privacy policy', 'Politique de confidentialité', 'Datenschutzerklärung', 'Privacy', 'Política de privacidade'), text('Tus datos, tu control', 'Your data, your control', 'Vos données, votre contrôle', 'Ihre Daten, Ihre Kontrolle', 'I tuoi dati, il tuo controllo', 'Os seus dados, o seu controlo'), null), const SizedBox(height: 8), _setting(Icons.info_outline_rounded, text('Acerca de', 'About', 'À propos', 'Über', 'Informazioni', 'Sobre'), 'UTILIA v0.5.3', null)]));
  Widget _setting(IconData icon, String title, String subtitle, VoidCallback? onTap) => Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), leading: UtiliaSoftIcon(icon: icon, color: UtiliaBrand.blue, size: 44), title: Text(title, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium), trailing: const Icon(Icons.chevron_right_rounded), onTap: onTap));
  Widget _empty(IconData icon, String message) => Center(child: Padding(padding: const EdgeInsets.all(42), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const UtiliaLogoMark(size: 66), const SizedBox(height: 16), Icon(icon, size: 32, color: UtiliaBrand.blue), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)])));
  Future<void> _pickLanguage() async { final value = await showDialog<UtiliaLanguage>(context: context, builder: (c) => SimpleDialog(title: Text(s.languageLabel), children: UtiliaLanguage.values.map((l) => SimpleDialogOption(onPressed: () => Navigator.pop(c, l), child: Text(UtiliaStrings(l).languageName))).toList())); if (value != null) await widget.onLanguage(value); }
}
