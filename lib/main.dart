import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:share_plus/share_plus.dart';

import 'calculator_suite.dart';
import 'calculations.dart';
import 'catalog.dart';
import 'localization.dart';
import 'models/tool.dart';
import 'storage.dart';

void main() => runApp(const UtiliaApp());

class UtiliaApp extends StatefulWidget {
  const UtiliaApp({super.key});
  @override State<UtiliaApp> createState() => _UtiliaAppState();
}

class _UtiliaAppState extends State<UtiliaApp> {
  final storage = UtiliaStorage();
  bool darkMode = false;
  UtiliaLanguage language = UtiliaLanguage.system;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final d = await storage.loadDarkMode();
    final l = UtiliaStrings.fromCode(await storage.loadLanguage());
    if (mounted) setState(() { darkMode = d; language = l; });
  }
  Future<void> _theme(bool v) async { setState(() => darkMode = v); await storage.saveDarkMode(v); }
  Future<void> _language(UtiliaLanguage v) async { setState(() => language = v); await storage.saveLanguage(UtiliaStrings.code(v)); }

  ThemeData _themeData(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF246BFE), brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF6F7FB) : const Color(0xFF101116),
      appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
      cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero, color: brightness == Brightness.light ? Colors.white : const Color(0xFF191A20), surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .42)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: brightness == Brightness.light ? Colors.white : const Color(0xFF191A20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17)),
      navigationBarTheme: NavigationBarThemeData(height: 76, elevation: 0, backgroundColor: brightness == Brightness.light ? Colors.white : const Color(0xFF17181D), indicatorColor: scheme.primaryContainer, labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: scheme.onSurfaceVariant)), iconTheme: WidgetStatePropertyAll(IconThemeData(color: scheme.onSurfaceVariant)),),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'UTILIA',
    locale: UtiliaStrings.locale(language),
    supportedLocales: const [Locale('es'), Locale('en'), Locale('fr'), Locale('de'), Locale('it'), Locale('pt')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
    theme: _themeData(Brightness.light),
    darkTheme: _themeData(Brightness.dark),
    home: HomePage(storage: storage, darkMode: darkMode, language: language, onTheme: _theme, onLanguage: _language),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.storage, required this.darkMode, required this.language, required this.onTheme, required this.onLanguage});
  final UtiliaStorage storage; final bool darkMode; final UtiliaLanguage language;
  final Future<void> Function(bool) onTheme; final Future<void> Function(UtiliaLanguage) onLanguage;
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0; Set<ToolType> favorites = {}; List<Map<String, dynamic>> history = [];
  UtiliaStrings get s => UtiliaStrings(widget.language == UtiliaLanguage.system ? UtiliaStrings.effective(UtiliaLanguage.system, Localizations.localeOf(context)) : widget.language);
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final f = await widget.storage.loadFavorites(); final h = await widget.storage.loadHistory(); if (mounted) setState(() { favorites = f.map(_type).whereType<ToolType>().toSet(); history = h; }); }
  ToolType? _type(String v) => ToolType.values.where((t) => t.name == v).cast<ToolType?>().firstWhere((_) => true, orElse: () => null);
  Future<void> _favorite(ToolType t) async { final n = {...favorites}; n.contains(t) ? n.remove(t) : n.add(t); setState(() => favorites = n); await widget.storage.saveFavorites(n.map((e) => e.name).toSet()); }
  String name(UtiliaTool t) => s.toolName(t.type.name, t.name); String desc(UtiliaTool t) => s.toolDescription(t.type.name, t.description); String cat(String v) => s.category(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: IndexedStack(index: tab, children: [_homeView(), _favoritesView(), _historyView(), _moreView()]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [
        NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: s.home),
        NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: s.favorites),
        NavigationDestination(icon: const Icon(Icons.history_rounded), selectedIcon: const Icon(Icons.history_rounded), label: s.history),
        NavigationDestination(icon: const Icon(Icons.tune_rounded), selectedIcon: const Icon(Icons.tune_rounded), label: s.more),
      ]),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 76,
    titleSpacing: 20,
    title: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF246BFE), Color(0xFF7048E8)]), borderRadius: BorderRadius.circular(13)), alignment: Alignment.center, child: const Text('U', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900))),
      const SizedBox(width: 12),
      const Text('UTILIA'),
    ]),
    actions: [IconButton(padding: const EdgeInsets.only(right: 18), tooltip: 'Información', onPressed: () => showAboutDialog(context: context, applicationName: 'UTILIA', applicationVersion: '0.4.0', applicationLegalese: s.slogan), icon: const Icon(Icons.info_outline_rounded, size: 27))],
  );

  Widget _homeView() {
    final featured = tools.where((t) => t.type == ToolType.calculator || t.type == ToolType.scientificCalculator).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(20, 2, 20, 28), children: [
      _hero(),
      const SizedBox(height: 26),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(s.categories, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
        Text('${tools.length} ${s.toolsCount(1).replaceFirst(RegExp(r'\\d+ '), '')}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
      const SizedBox(height: 14),
      ...categories.map((c) => _categoryCard(context, c)),
      const SizedBox(height: 12),
      if (featured.isNotEmpty) ...[
        Text('Acceso rápido', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
        const SizedBox(height: 12),
        Row(children: featured.map((t) => Expanded(child: Padding(padding: EdgeInsets.only(right: t == featured.last ? 0 : 8), child: _quickCard(context, t)))).toList()),
      ],
    ]);
  }

  Widget _hero() => Container(
    height: 178,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF246BFE), Color(0xFF6338D8)]), borderRadius: BorderRadius.circular(28)),
    child: Stack(children: [
      Positioned(right: -35, top: -55, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .10)))),
      Positioned(right: 45, bottom: -70, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .07)))),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('UTILIA', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
        const SizedBox(height: 8),
        Text(s.slogan, style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text('Todo lo útil, en un solo lugar.', style: TextStyle(color: Colors.white.withValues(alpha: .88), fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    ]),
  );

  Widget _categoryCard(BuildContext c, String category) {
    final list = tools.where((t) => t.category == category).toList();
    final tint = categoryTints[category]!;
    final icon = list.first.icon;
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => CategoryPage(category: category, tools: list, favorites: favorites, onFavorite: _favorite, storage: widget.storage, onHistory: _load, s: s))),
      child: Padding(padding: const EdgeInsets.fromLTRB(14, 14, 12, 14), child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: tint.withValues(alpha: .13), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: tint, size: 29)),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cat(category), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2)), const SizedBox(height: 4), Text(s.toolsCount(list.length), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(c).colorScheme.onSurfaceVariant))])),
        Container(width: 38, height: 38, decoration: BoxDecoration(color: tint.withValues(alpha: .09), shape: BoxShape.circle), child: Icon(Icons.arrow_forward_rounded, color: tint, size: 20)),
      ])),
    )));
  }

  Widget _quickCard(BuildContext c, UtiliaTool t) {
    final color = t.type == ToolType.scientificCalculator ? const Color(0xFF7048E8) : const Color(0xFF246BFE);
    return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => openTool(c, t, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(t.icon, color: color)), const SizedBox(height: 12), Text(name(t), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('Abrir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))]))));
  }

  Widget _toolTile(BuildContext c, UtiliaTool t) => Card(margin: const EdgeInsets.only(bottom: 10), child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () => openTool(c, t, widget.storage, _load, s), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: t.tint.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(t.icon, color: t.tint, size: 25)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name(t), style: const TextStyle(fontWeight: FontWeight.w850)), const SizedBox(height: 3), Text(desc(t), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant))])), IconButton(onPressed: () => _favorite(t.type), tooltip: 'Favorito', icon: Icon(favorites.contains(t.type) ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorites.contains(t.type) ? t.tint : Theme.of(c).colorScheme.onSurfaceVariant))]))));

  Widget _favoritesView() => favorites.isEmpty ? _emptyState(Icons.favorite_border_rounded, s.emptyFavorites) : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [Text(s.favorites, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.7)), const SizedBox(height: 16), ...tools.where((t) => favorites.contains(t.type)).map((t) => _toolTile(context, t))]);

  Widget _historyView() => history.isEmpty ? _emptyState(Icons.history_rounded, s.emptyHistory) : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(s.history, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.7)), TextButton.icon(onPressed: () async { await widget.storage.clearHistory(); await _load(); }, icon: const Icon(Icons.delete_outline_rounded, size: 18), label: Text(s.clearHistory))]), const SizedBox(height: 10), ...history.map((h) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(Icons.calculate_rounded, color: Theme.of(context).colorScheme.primary)), title: Text('${h['tool'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(h['expression'] == null ? '${h['result'] ?? ''}' : '${h['expression']} = ${h['result']}'))))]);

  Widget _moreView() => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [Text(s.more, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.7)), const SizedBox(height: 16), Card(child: SwitchListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4), secondary: Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.dark_mode_outlined)), title: Text(s.darkMode, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(s.savedDevice), value: widget.darkMode, onChanged: widget.onTheme)), const SizedBox(height: 10), Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.language_rounded)), title: Text(s.languageLabel, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(UtiliaStrings(widget.language).languageName), trailing: const Icon(Icons.chevron_right_rounded), onTap: _pickLanguage)), const SizedBox(height: 24), Center(child: Text('UTILIA  •  0.4.0', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700))) ]);

  Widget _emptyState(IconData icon, String text) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 72, height: 72, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle), child: Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 16), Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600))])));

  Future<void> _pickLanguage() async { final v = await showDialog<UtiliaLanguage>(context: context, builder: (c) => SimpleDialog(title: Text(s.languageLabel), children: UtiliaLanguage.values.map((l) => SimpleDialogOption(onPressed: () => Navigator.pop(c, l), child: Text(UtiliaStrings(l).languageName))).toList())); if (v != null) await widget.onLanguage(v); }
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.category, required this.tools, required this.favorites, required this.onFavorite, required this.storage, required this.onHistory, required this.s});
  final String category; final List<UtiliaTool> tools; final Set<ToolType> favorites; final Future<void> Function(ToolType) onFavorite; final UtiliaStorage storage; final Future<void> Function() onHistory; final UtiliaStrings s;
  @override Widget build(BuildContext c) {
    final tint = categoryTints[category]!;
    return Scaffold(appBar: AppBar(title: Text(s.category(category))), body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: tint.withValues(alpha: .10), borderRadius: BorderRadius.circular(24)), child: Row(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: tint.withValues(alpha: .15), borderRadius: BorderRadius.circular(18)), child: Icon(tools.first.icon, color: tint, size: 30)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.category(category), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(s.toolsCount(tools.length), style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600))]))])),
      const SizedBox(height: 18),
      ...tools.map((t) => Card(margin: const EdgeInsets.only(bottom: 11), child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () => openTool(c, t, storage, onHistory, s), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: t.tint.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)), child: Icon(t.icon, color: t.tint, size: 25)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.toolName(t.type.name, t.name), style: const TextStyle(fontWeight: FontWeight.w850)), const SizedBox(height: 4), Text(s.toolDescription(t.type.name, t.description), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant))])), IconButton(onPressed: () => onFavorite(t.type), icon: Icon(favorites.contains(t.type) ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorites.contains(t.type) ? t.tint : Theme.of(c).colorScheme.onSurfaceVariant))]))))),
    ]));
  }
}

void openTool(BuildContext c, UtiliaTool t, UtiliaStorage storage, Future<void> Function()? refresh, UtiliaStrings s) {
  if (t.type == ToolType.calculator || t.type == ToolType.scientificCalculator) {
    Navigator.push(c, MaterialPageRoute(builder: (_) => CalculatorSuitePage(scientific: t.type == ToolType.scientificCalculator, storage: storage, s: s)));
  } else {
    Navigator.push(c, MaterialPageRoute(builder: (_) => CalculatorPage(tool: t, storage: storage, onHistory: refresh, s: s)));
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.tool, required this.storage, this.onHistory, required this.s});
  final UtiliaTool tool; final UtiliaStorage storage; final Future<void> Function()? onHistory; final UtiliaStrings s;
  @override State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final controllers = List.generate(4, (_) => TextEditingController()); double? result; String unit = '';
  @override void dispose() { for (final c in controllers) c.dispose(); super.dispose(); }
  List<String> get labels { final id = widget.tool.type.name; final count = switch (widget.tool.type) { ToolType.age => 1, ToolType.dateDifference => 2, ToolType.workHours => 3, ToolType.countdown => 3, ToolType.length => 3, ToolType.weight => 3, ToolType.bmi => 2, ToolType.fuel => 3, ToolType.tip => 3, ToolType.loan => 3, ToolType.compoundInterest => 3, ToolType.area => 2, ToolType.paint => 2, ToolType.electricity => 4, ToolType.costPerKm => 2, ToolType.gradeAverage => 1, ToolType.ruleOfThree => 3, _ => 2 }; return List.generate(count, (i) { if (widget.tool.type == ToolType.electricity && i == 3) return switch (widget.s.selectedLanguage) { UtiliaLanguage.en => 'Price per kWh (€)', UtiliaLanguage.fr => 'Prix du kWh (€)', UtiliaLanguage.de => 'Preis pro kWh (€)', UtiliaLanguage.it => 'Prezzo per kWh (€)', UtiliaLanguage.pt => 'Preço por kWh (€)', _ => 'Precio del kWh (€)' }; return widget.s.inputLabel(id, i); }); }
  DateTime? _date(String v) { final p = v.trim().split('/'); if (p.length != 3) return null; final d = int.tryParse(p[0]), m = int.tryParse(p[1]), y = int.tryParse(p[2]); if (d == null || m == null || y == null) return null; final x = DateTime(y, m, d); return x.day == d && x.month == m && x.year == y ? x : null; }
  String _unit(String es, String en, String fr, String de, String it, String pt) => switch (widget.s.selectedLanguage) { UtiliaLanguage.en => en, UtiliaLanguage.fr => fr, UtiliaLanguage.de => de, UtiliaLanguage.it => it, UtiliaLanguage.pt => pt, _ => es };
  Future<void> calculate() async {
    final x = parseNumber(controllers[0].text), y = parseNumber(controllers[1].text), z = parseNumber(controllers[2].text), price = parseNumber(controllers[3].text); double r; String u = '';
    switch (widget.tool.type) {
      case ToolType.percentage: r = percentageOf(x, y); break; case ToolType.discount: r = discountedPrice(x, y); break; case ToolType.iva: r = priceWithIva(x, y); break; case ToolType.tip: r = tipPerPerson(x, y, z.toInt()); break; case ToolType.loan: r = loanPayment(x, y, z.toInt()); break; case ToolType.compoundInterest: r = compound(x, y, z.toInt()); break;
      case ToolType.area: r = area(x, y); u = 'm²'; break; case ToolType.paint: r = paintLitres(x, y); u = 'L'; break; case ToolType.electricity: r = electricityCost(x, y, z, price); u = '€'; break; case ToolType.fuel: r = fuelCost(x, y, z); u = '€'; break; case ToolType.costPerKm: r = costPerKm(x, y); u = '€/km'; break; case ToolType.bmi: r = bmi(x, y); break;
      case ToolType.gradeAverage: r = gradeAverage(controllers[0].text.split(',').map(parseNumber).toList()); break; case ToolType.ruleOfThree: r = ruleOfThree(x, y, z); break;
      case ToolType.age: final d = _date(controllers[0].text); if (d == null) { _error(widget.s.invalidDate); return; } r = ageInYears(d); u = _unit('años', 'years', 'ans', 'Jahre', 'anni', 'anos'); break;
      case ToolType.dateDifference: final a = _date(controllers[0].text), b = _date(controllers[1].text); if (a == null || b == null) { _error(widget.s.invalidDate); return; } r = dateDifferenceDays(a, b).toDouble(); u = _unit('días', 'days', 'jours', 'Tage', 'giorni', 'dias'); break;
      case ToolType.workHours: r = workHours(x, y, z); u = 'h'; break; case ToolType.countdown: r = countdownSeconds(x.toInt(), y.toInt(), z.toInt()).toDouble(); u = 'sec'; break;
      case ToolType.length: r = convertLength(x, controllers[1].text.trim().toLowerCase(), controllers[2].text.trim().toLowerCase()); u = controllers[2].text.trim(); break; case ToolType.weight: r = convertWeight(x, controllers[1].text.trim().toLowerCase(), controllers[2].text.trim().toLowerCase()); u = controllers[2].text.trim(); break;
      case ToolType.calculator: case ToolType.scientificCalculator: r = 0; break;
    }
    setState(() { result = r; unit = u; });
    await widget.storage.addHistory({'tool': widget.s.toolName(widget.tool.type.name, widget.tool.name), 'result': '${r.toStringAsFixed(2).replaceAll('.', ',')} $u', 'timestamp': DateTime.now().toIso8601String()});
    await widget.onHistory?.call();
  }
  void _error(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  Future<void> _copy() async { final value = result == null ? '' : '${result!.toStringAsFixed(2).replaceAll('.', ',')} $unit'; await Clipboard.setData(ClipboardData(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: $value')); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.s.copied))); }
  Future<void> _share() async { final value = result == null ? '' : '${result!.toStringAsFixed(2).replaceAll('.', ',')} $unit'; await SharePlus.instance.share(ShareParams(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: $value', subject: 'UTILIA')); }

  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(widget.s.toolName(widget.tool.type.name, widget.tool.name), style: const TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: _copy, icon: const Icon(Icons.copy_outlined)), IconButton(onPressed: _share, icon: const Icon(Icons.share_outlined))]), body: ListView(padding: const EdgeInsets.all(18), children: [Text(widget.s.toolDescription(widget.tool.type.name, widget.tool.name), style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant)), const SizedBox(height: 22), for (var i = 0; i < labels.length; i++) Padding(padding: const EdgeInsets.only(bottom: 14), child: TextField(controller: controllers[i], keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true), decoration: InputDecoration(labelText: labels[i], filled: true, border: const OutlineInputBorder(borderSide: BorderSide.none))),), FilledButton(onPressed: calculate, child: Text(widget.s.calculate)), const SizedBox(height: 18), if (result != null) Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(c).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.s.result, style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(c).colorScheme.onSurface)), Text('${result!.toStringAsFixed(2).replaceAll('.', ',')} $unit', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Theme.of(c).colorScheme.onSurface)), Padding(padding: const EdgeInsets.only(top: 8), child: Text(widget.s.resultHint(widget.tool.type.name), style: TextStyle(fontSize: 13, color: Theme.of(c).colorScheme.onSurfaceVariant))) ]))]));
}