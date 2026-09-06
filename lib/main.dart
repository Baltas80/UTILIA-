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

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UTILIA',
        locale: UtiliaStrings.locale(language),
        supportedLocales: const [Locale('es'), Locale('en'), Locale('fr'), Locale('de'), Locale('it'), Locale('pt')],
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF167FF2)), scaffoldBackgroundColor: const Color(0xFFF7FAFD)),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF167FF2), brightness: Brightness.dark)),
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
  String query = ''; int tab = 0; Set<ToolType> favorites = {}; List<Map<String, dynamic>> history = [];
  UtiliaStrings get s => UtiliaStrings(widget.language == UtiliaLanguage.system ? UtiliaStrings.effective(UtiliaLanguage.system, Localizations.localeOf(context)) : widget.language);
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final f = await widget.storage.loadFavorites(); final h = await widget.storage.loadHistory(); if (mounted) setState(() { favorites = f.map(_type).whereType<ToolType>().toSet(); history = h; }); }
  ToolType? _type(String v) => ToolType.values.where((t) => t.name == v).cast<ToolType?>().firstWhere((_) => true, orElse: () => null);
  Future<void> _favorite(ToolType t) async { final n = {...favorites}; n.contains(t) ? n.remove(t) : n.add(t); setState(() => favorites = n); await widget.storage.saveFavorites(n.map((e) => e.name).toSet()); }
  String name(UtiliaTool t) => s.toolName(t.type.name, t.name); String desc(UtiliaTool t) => s.toolDescription(t.type.name, t.description); String cat(String v) => s.category(v);

  @override
  Widget build(BuildContext context) {
    final filtered = tools.where((t) => '${name(t)} ${desc(t)} ${cat(t.category)}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('UTILIA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), actions: [IconButton(onPressed: () => showAboutDialog(context: context, applicationName: 'UTILIA', applicationVersion: '0.4.0', applicationLegalese: s.slogan), icon: const Icon(Icons.info_outline))]),
      body: tab == 0 ? ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        TextField(onChanged: (v) => setState(() => query = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: s.search, filled: true, fillColor: Theme.of(context).colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
        const SizedBox(height: 14), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF167FF2), borderRadius: BorderRadius.circular(20)), child: Text(s.slogan, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
        const SizedBox(height: 20), Text(query.isEmpty ? s.categories : '${s.results} (${filtered.length})', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 12),
        if (query.isEmpty) ...categories.map((c) => _categoryTile(context, c)) else ...filtered.map((t) => _toolTile(context, t)),
      ]) : tab == 1 ? _favoritesView() : tab == 2 ? _historyView() : _moreView(),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [
        NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: s.home),
        NavigationDestination(icon: const Icon(Icons.favorite_border), selectedIcon: const Icon(Icons.favorite), label: s.favorites),
        NavigationDestination(icon: const Icon(Icons.history), label: s.history), NavigationDestination(icon: const Icon(Icons.apps), label: s.more),
      ]),
    );
  }

  Widget _categoryTile(BuildContext c, String category) { final list = tools.where((t) => t.category == category).toList(); final tint = categoryTints[category]!; return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(backgroundColor: tint.withValues(alpha: .13), child: Icon(list.first.icon, color: tint)), title: Text(cat(category), style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(s.toolsCount(list.length)), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => CategoryPage(category: category, tools: list, favorites: favorites, onFavorite: _favorite, storage: widget.storage, onHistory: _load, s: s))))); }
  Widget _toolTile(BuildContext c, UtiliaTool t) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: Icon(t.icon, color: t.tint), title: Text(name(t), style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(desc(t)), trailing: Icon(favorites.contains(t.type) ? Icons.favorite : Icons.chevron_right_rounded), onTap: () => openTool(c, t, widget.storage, _load, s), onLongPress: () => _favorite(t.type)));
  Widget _favoritesView() => favorites.isEmpty ? Center(child: Text(s.emptyFavorites, textAlign: TextAlign.center)) : ListView(padding: const EdgeInsets.all(16), children: tools.where((t) => favorites.contains(t.type)).map((t) => _toolTile(context, t)).toList());
  Widget _historyView() => history.isEmpty ? Center(child: Text(s.emptyHistory, textAlign: TextAlign.center)) : ListView(padding: const EdgeInsets.all(16), children: [Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () async { await widget.storage.clearHistory(); await _load(); }, child: Text(s.clearHistory))), ...history.map((h) => Card(elevation: 0, child: ListTile(leading: const Icon(Icons.calculate_outlined), title: Text('${h['tool'] ?? ''}'), subtitle: Text(h['expression'] == null ? '${h['result'] ?? ''}' : '${h['expression']} = ${h['result']}'))))]);
  Widget _moreView() => ListView(padding: const EdgeInsets.all(16), children: [Text(s.preferences, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Card(elevation: 0, child: SwitchListTile(title: Text(s.darkMode), subtitle: Text(s.savedDevice), value: widget.darkMode, onChanged: widget.onTheme)), Card(elevation: 0, child: ListTile(title: Text(s.languageLabel), subtitle: Text(UtiliaStrings(widget.language).languageName), trailing: const Icon(Icons.language), onTap: _pickLanguage))]);
  Future<void> _pickLanguage() async { final v = await showDialog<UtiliaLanguage>(context: context, builder: (c) => SimpleDialog(title: Text(s.languageLabel), children: UtiliaLanguage.values.map((l) => SimpleDialogOption(onPressed: () => Navigator.pop(c, l), child: Text(UtiliaStrings(l).languageName))).toList())); if (v != null) await widget.onLanguage(v); }
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.category, required this.tools, required this.favorites, required this.onFavorite, required this.storage, required this.onHistory, required this.s});
  final String category; final List<UtiliaTool> tools; final Set<ToolType> favorites; final Future<void> Function(ToolType) onFavorite; final UtiliaStorage storage; final Future<void> Function() onHistory; final UtiliaStrings s;
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(s.category(category), style: const TextStyle(fontWeight: FontWeight.w900))), body: ListView(padding: const EdgeInsets.all(16), children: tools.map((t) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: Icon(t.icon, color: t.tint), title: Text(s.toolName(t.type.name, t.name), style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(s.toolDescription(t.type.name, t.description)), trailing: Icon(favorites.contains(t.type) ? Icons.favorite : Icons.chevron_right_rounded), onTap: () => openTool(c, t, storage, onHistory, s), onLongPress: () => onFavorite(t.type)))).toList()));
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
  final controllers = List.generate(4, (_) => TextEditingController()); double result = 0; String unit = '';
  @override void initState() { super.initState(); controllers[0].text = widget.tool.type == ToolType.age || widget.tool.type == ToolType.dateDifference ? '01/01/2000' : '100'; controllers[1].text = widget.tool.type == ToolType.iva ? '21' : '10'; controllers[2].text = '1'; if (widget.tool.type == ToolType.electricity) controllers[3].text = '0,15'; }
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
  Future<void> _copy() async { await Clipboard.setData(ClipboardData(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: ${result.toStringAsFixed(2).replaceAll('.', ',')} $unit')); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.s.copied))); }
  Future<void> _share() async => SharePlus.instance.share(ShareParams(text: '${widget.s.toolName(widget.tool.type.name, widget.tool.name)}: ${result.toStringAsFixed(2).replaceAll('.', ',')} $unit', subject: 'UTILIA'));

  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(widget.s.toolName(widget.tool.type.name, widget.tool.name), style: const TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: _copy, icon: const Icon(Icons.copy_outlined)), IconButton(onPressed: _share, icon: const Icon(Icons.share_outlined))]), body: ListView(padding: const EdgeInsets.all(18), children: [Text(widget.s.toolDescription(widget.tool.type.name, widget.tool.name), style: const TextStyle(color: Color(0xFF52606D))), const SizedBox(height: 22), for (var i = 0; i < labels.length; i++) Padding(padding: const EdgeInsets.only(bottom: 14), child: TextField(controller: controllers[i], keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true), decoration: InputDecoration(labelText: labels[i], filled: true, border: const OutlineInputBorder(borderSide: BorderSide.none))),), FilledButton(onPressed: calculate, child: Text(widget.s.calculate)), const SizedBox(height: 18), Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFE7F8F2), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.s.result, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${result.toStringAsFixed(2).replaceAll('.', ',')} $unit', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), if (result != 0) Padding(padding: const EdgeInsets.only(top: 8), child: Text(widget.s.resultHint(widget.tool.type.name), style: const TextStyle(fontSize: 13))) ]))]));
}
