import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'catalog.dart';
import 'category_page.dart';
import 'localization.dart';
import 'monetization.dart';
import 'models/tool.dart';
import 'storage.dart';
import 'utilia_design.dart';

class UtiliaPremiumApp extends StatefulWidget {
  const UtiliaPremiumApp({super.key});
  @override
  State<UtiliaPremiumApp> createState() => _UtiliaPremiumAppState();
}

class _UtiliaPremiumAppState extends State<UtiliaPremiumApp> {
  final storage = UtiliaStorage();
  late final UtiliaMonetization monetization;
  bool darkMode = false;
  UtiliaLanguage language = UtiliaLanguage.system;
  @override
  void initState() {
    super.initState();
    monetization = UtiliaMonetization();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      monetization.initialize();
    });
  }

  @override
  void dispose() {
    monetization.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final d = await storage.loadDarkMode();
    final l = UtiliaStrings.fromCode(await storage.loadLanguage());
    if (mounted)
      setState(() {
        darkMode = d;
        language = l;
      });
  }

  Future<void> _theme(bool value) async {
    setState(() => darkMode = value);
    await storage.saveDarkMode(value);
  }

  Future<void> _language(UtiliaLanguage value) async {
    setState(() => language = value);
    await storage.saveLanguage(UtiliaStrings.code(value));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UTILIA',
        locale: UtiliaStrings.locale(language),
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
          Locale('fr'),
          Locale('de'),
          Locale('it'),
          Locale('pt'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        theme: utiliaTheme(Brightness.light),
        darkTheme: utiliaTheme(Brightness.dark),
        builder: (context, child) => UtiliaGoldEdgeFrame(
          child: child ?? const SizedBox.shrink(),
        ),
        home: UtiliaHomePage(
          storage: storage,
          darkMode: darkMode,
          language: language,
          monetization: monetization,
          onTheme: _theme,
          onLanguage: _language,
        ),
      );
}

class UtiliaHomePage extends StatefulWidget {
  const UtiliaHomePage({
    super.key,
    required this.storage,
    required this.darkMode,
    required this.language,
    required this.monetization,
    required this.onTheme,
    required this.onLanguage,
  });
  final UtiliaStorage storage;
  final bool darkMode;
  final UtiliaLanguage language;
  final UtiliaMonetization monetization;
  final Future<void> Function(bool) onTheme;
  final Future<void> Function(UtiliaLanguage) onLanguage;
  @override
  State<UtiliaHomePage> createState() => _UtiliaHomePageState();
}

class _UtiliaHomePageState extends State<UtiliaHomePage> {
  int tab = 0;
  Set<ToolType> favorites = {};
  List<Map<String, dynamic>> history = [];

  UtiliaStrings get s => UtiliaStrings(
        widget.language == UtiliaLanguage.system
            ? UtiliaStrings.effective(
                UtiliaLanguage.system,
                Localizations.localeOf(context),
              )
            : widget.language,
      );
  String text(
    String es,
    String en,
    String fr,
    String de,
    String it,
    String pt,
  ) =>
      switch (s.selectedLanguage) {
        UtiliaLanguage.en => en,
        UtiliaLanguage.fr => fr,
        UtiliaLanguage.de => de,
        UtiliaLanguage.it => it,
        UtiliaLanguage.pt => pt,
        _ => es,
      };
  String get _subtitle => text(
        'Herramientas para tu día a día',
        'Tools for everyday life',
        'Des outils pour votre quotidien',
        'Werkzeuge für den Alltag',
        'Strumenti per la vita quotidiana',
        'Ferramentas para o dia a dia',
      );
  String get _eyebrow => text(
        'HERRAMIENTAS PARA TU DÍA A DÍA',
        'TOOLS FOR EVERYDAY LIFE',
        'DES OUTILS POUR VOTRE QUOTIDIEN',
        'WERKZEUGE FÜR DEN ALLTAG',
        'STRUMENTI PER LA TUA GIORNATA',
        'FERRAMENTAS PARA O DIA A DIA',
      );
  String get _heroSub => text(
        'Todo lo que necesitas en una sola app.',
        'Everything you need in one app.',
        'Tout ce dont vous avez besoin dans une seule app.',
        'Alles, was Sie brauchen, in einer App.',
        'Tutto ciò che serve in un’unica app.',
        'Tudo o que precisa numa só app.',
      );
  String get _seeAll => text(
        'Ver todas',
        'See all',
        'Voir tout',
        'Alle anzeigen',
        'Vedi tutto',
        'Ver tudo',
      );
  String get _favoriteSub => text(
        'Tus herramientas favoritas, siempre a mano.',
        'Your favorite tools, always at hand.',
        'Vos outils préférés, toujours à portée de main.',
        'Ihre Lieblingswerkzeuge immer griffbereit.',
        'I tuoi strumenti preferiti, sempre a portata di mano.',
        'As suas ferramentas favoritas, sempre à mão.',
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final f = await widget.storage.loadFavorites();
    final h = await widget.storage.loadHistory();
    if (mounted)
      setState(() {
        favorites = f.map(_type).whereType<ToolType>().toSet();
        history = h;
      });
  }

  ToolType? _type(String value) {
    for (final t in ToolType.values) {
      if (t.name == value) return t;
    }
    return null;
  }

  UtiliaTool? _find(ToolType type) {
    for (final t in tools) {
      if (t.type == type) return t;
    }
    return null;
  }

  Future<void> _favorite(ToolType type) async {
    final next = {...favorites};
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }
    setState(() => favorites = next);
    await widget.storage.saveFavorites(next.map((e) => e.name).toSet());
  }

  String name(UtiliaTool tool) => s.toolName(tool.type.name, tool.name);
  String desc(UtiliaTool tool) =>
      s.toolDescription(tool.type.name, tool.description);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.monetization,
        builder: (context, _) => Scaffold(
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: tab,
                  children: [_home(), _favorites(), _history(), _more()],
                ),
              ),
              UtiliaBannerAd(monetization: widget.monetization),
            ],
          ),
          bottomNavigationBar: NavigationBar(
          height: 64,
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: s.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: s.favorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_rounded),
              selectedIcon: const Icon(Icons.history_rounded),
              label: s.history,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: s.more,
            ),
          ],
        ),
      ),
  );

  Widget _brand() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 9, 12, 9),
        child: Row(
          children: [
            const UtiliaLogoMark(size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UTILIA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: text(
                'Ajustes',
                'Settings',
                'Réglages',
                'Einstellungen',
                'Impostazioni',
                'Definições',
              ),
              onPressed: () => setState(() => tab = 3),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      );

  Future<void> _showToolList(List<UtiliaTool> items, String title) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .78,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final tool = items[index];
                    return ListTile(
                      minTileHeight: 64,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      leading: UtiliaSoftIcon(
                        icon: tool.icon,
                        color: UtiliaBrand.categoryColor(
                          tool.category,
                          tool.tint,
                        ),
                        size: 44,
                      ),
                      title: Text(name(tool)),
                      subtitle: Text(
                        desc(tool),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            openUtiliaTool(
                              context,
                              tool,
                              widget.storage,
                              _load,
                              s,
                            );
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryList() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          shrinkWrap: true,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final category = categories[index];
            final categoryTools =
                tools.where((tool) => tool.category == category).toList();
            return ListTile(
              minTileHeight: 64,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              leading: UtiliaSoftIcon(
                icon: Icons.grid_view_rounded,
                color: UtiliaBrand.categoryColor(
                  category,
                  categoryTints[category] ?? UtiliaBrand.blue,
                ),
                size: 44,
              ),
              title: Text(s.category(category)),
              subtitle: Text(
                text(
                  categoryTools.length.toString() + ' herramientas',
                  categoryTools.length.toString() + ' tools',
                  categoryTools.length.toString() + ' outils',
                  categoryTools.length.toString() + ' Werkzeuge',
                  categoryTools.length.toString() + ' strumenti',
                  categoryTools.length.toString() + ' ferramentas',
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(sheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UtiliaCategoryPage(
                          category: category,
                          tools: categoryTools,
                          favorites: favorites,
                          onFavorite: _favorite,
                          storage: widget.storage,
                          onHistory: _load,
                          s: s,
                        ),
                      ),
                    );
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _home() {
    final quickTypes = [
      ToolType.calculator,
      ToolType.scientificCalculator,
      ToolType.percentage,
      ToolType.ruleOfThree,
    ];
    final quick = quickTypes.map(_find).whereType<UtiliaTool>().toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _brand(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _hero(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _benefits(),
          ),
          const SizedBox(height: 19),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: UtiliaSectionTitle(
              title: text(
                'Acceso rápido',
                'Quick access',
                'Accès rapide',
                'Schnellzugriff',
                'Accesso rapido',
                'Acesso rápido',
              ),
              action: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onPressed: () => _showToolList(tools, _seeAll),
                child: Text(_seeAll),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 108,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: quick.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _quick(quick[i]),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: UtiliaSectionTitle(
              title: s.categories,
              action: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onPressed: _showCategoryList,
                child: Text(_seeAll),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (_, i) => _category(categories[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() => Container(
        height: 222,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: UtiliaBrand.blue.withValues(alpha: .15),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(
                child: UtiliaMountainArtwork(borderRadius: 0)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE0000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 17,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _eyebrow,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .95,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.slogan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.03,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _heroSub,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _benefits() => Row(
        children: [
          _benefit(
            Icons.bolt_rounded,
            text('Útil', 'Useful', 'Utile', 'Nützlich', 'Utile', 'Útil'),
          ),
          const SizedBox(width: 8),
          _benefit(
            Icons.favorite_border_rounded,
            text(
                'Simple', 'Simple', 'Simple', 'Einfach', 'Semplice', 'Simples'),
          ),
          const SizedBox(width: 8),
          _benefit(
            Icons.all_inclusive_rounded,
            text(
              'Siempre contigo',
              'Always with you',
              'Toujours avec vous',
              'Immer bei dir',
              'Sempre con te',
              'Sempre consigo',
            ),
          ),
        ],
      );
  Widget _benefit(IconData icon, String label) => Expanded(
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: UtiliaBrand.blue),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _quick(UtiliaTool tool) {
    final color = tool.type == ToolType.scientificCalculator ||
            tool.type == ToolType.ruleOfThree
        ? UtiliaBrand.violet
        : UtiliaBrand.blue;
    return SizedBox(
      width: 96,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 10, 7, 8),
            child: Column(
              children: [
                UtiliaSoftIcon(icon: tool.icon, color: color, size: 46),
                const Spacer(),
                Text(
                  name(tool),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontSize: 9.5, height: 1.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _category(String category) {
    final list = tools.where((t) => t.category == category).toList();
    final color = UtiliaBrand.categoryColor(category, list.first.tint);
    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: .10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UtiliaCategoryPage(
              category: category,
              tools: list,
              favorites: favorites,
              onFavorite: _favorite,
              storage: widget.storage,
              onHistory: _load,
              s: s,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UtiliaSoftIcon(icon: list.first.icon, color: color, size: 48),
              const Spacer(),
              Text(
                s.category(category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.toolsCount(list.length),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 9.5),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: color, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkPage(String title, String subtitle, IconData icon, Widget body) =>
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF082B46), Color(0xFF0B1726)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _brandDark(title),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(icon, color: Colors.white24, size: 46),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      );
  Widget _brandDark(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 7, 14, 6),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setState(() => tab = 0),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _toolTile(UtiliaTool tool) {
    final color = UtiliaBrand.categoryColor(tool.category, tool.tint);
    final fav = favorites.contains(tool.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => openUtiliaTool(context, tool, widget.storage, _load, s),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                UtiliaSoftIcon(icon: tool.icon, color: color, size: 44),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name(tool),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc(tool),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _favorite(tool.type),
                  icon: Icon(
                    fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: fav
                        ? const Color(0xFFE93D68)
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _favorites() {
    final body = favorites.isEmpty
        ? _empty(Icons.favorite_border_rounded, s.emptyFavorites)
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              ...tools.where((t) => favorites.contains(t.type)).map(_toolTile),
            ],
          );
    return _darkPage(s.favorites, _favoriteSub, Icons.favorite_rounded, body);
  }

  Widget _history() {
    final body = history.isEmpty
        ? _empty(Icons.history_rounded, s.emptyHistory)
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              Row(
                children: [
                  UtiliaPill(
                    label: text(
                      'Todos',
                      'All',
                      'Tous',
                      'Alle',
                      'Tutti',
                      'Todos',
                    ),
                    selected: true,
                  ),
                  const SizedBox(width: 6),
                  UtiliaPill(label: s.calculate),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await widget.storage.clearHistory();
                      await _load();
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...history.map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 2,
                      ),
                      leading: UtiliaSoftIcon(
                        icon: Icons.functions_rounded,
                        color: UtiliaBrand.blue,
                        size: 40,
                      ),
                      title: Text(
                        '${h['expression'] ?? h['tool'] ?? ''}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 12.5),
                      ),
                      subtitle: Text(
                        '${h['result'] ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
    return _darkPage(
      s.history,
      text(
        'Tus cálculos recientes, siempre disponibles.',
        'Your recent calculations, always available.',
        'Vos calculs récents, toujours disponibles.',
        'Ihre letzten Berechnungen, immer verfügbar.',
        'I tuoi calcoli recenti, sempre disponibili.',
        'Os seus cálculos recentes, sempre disponíveis.',
      ),
      Icons.history_rounded,
      body,
    );
  }

  Widget _more() => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            Text(s.more, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 13),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const UtiliaLogoMark(size: 54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UTILIA',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'v0.5.5',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.onTheme(!widget.darkMode),
                      tooltip: text(
                        'Cambiar tema',
                        'Change theme',
                        'Changer de thème',
                        'Thema ändern',
                        'Cambia tema',
                        'Alterar tema',
                      ),
                      icon: Icon(
                        widget.darkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_outlined,
                        color: UtiliaBrand.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 8),
            _setting(
              Icons.workspace_premium_outlined,
              'UTILIA Premium',
              widget.monetization.isPremium
                  ? text(
                      'Premium activo · sin anuncios',
                      'Premium active · no ads',
                      'Premium actif · sans publicités',
                      'Premium aktiv · ohne Werbung',
                      'Premium attivo · senza pubblicità',
                      'Premium ativo · sem anúncios',
                    )
                  : text(
                      'Elimina los anuncios para siempre · 2,99 €',
                      'Remove ads forever · €2.99',
                      'Supprimez les publicités pour toujours · 2,99 €',
                      'Werbung dauerhaft entfernen · 2,99 €',
                      'Rimuovi le pubblicità per sempre · 2,99 €',
                      'Remova os anúncios para sempre · 2,99 €',
                    ),
              _showPremium,
            ),
            _setting(
              Icons.settings_outlined,
              text(
                'Ajustes',
                'Settings',
                'Réglages',
                'Einstellungen',
                'Impostazioni',
                'Definições',
              ),
              text(
                'Tema, idioma y preferencias',
                'Theme, language and preferences',
                'Thème, langue et préférences',
                'Thema, Sprache und Einstellungen',
                'Tema, lingua e preferenze',
                'Tema, idioma e preferências',
              ),
              _openSettings,
            ),
            const SizedBox(height: 8),
            _setting(
              Icons.new_releases_outlined,
              text(
                'Novedades',
                'What’s new',
                'Nouveautés',
                'Neuigkeiten',
                'Novità',
                'Novidades',
              ),
              text(
                'Ver qué hay de nuevo',
                'See what’s new',
                'Voir les nouveautés',
                'Neuigkeiten ansehen',
                'Scopri le novità',
                'Ver novidades',
              ),
              _showWhatsNew,
            ),
            const SizedBox(height: 8),
            _setting(
              Icons.star_outline_rounded,
              text(
                'Valora UTILIA',
                'Rate UTILIA',
                'Évaluer UTILIA',
                'UTILIA bewerten',
                'Valuta UTILIA',
                'Avaliar UTILIA',
              ),
              text(
                'Tu opinión nos ayuda',
                'Your opinion helps us',
                'Votre avis nous aide',
                'Ihre Meinung hilft uns',
                'La tua opinione ci aiuta',
                'A sua opinião ajuda-nos',
              ),
              _rateUtilia,
            ),
            const SizedBox(height: 8),
            _setting(
              Icons.share_outlined,
              text(
                'Compartir app',
                'Share app',
                'Partager l’app',
                'App teilen',
                'Condividi app',
                'Partilhar app',
              ),
              text(
                'Recomienda UTILIA',
                'Recommend UTILIA',
                'Recommandez UTILIA',
                'UTILIA empfehlen',
                'Consiglia UTILIA',
                'Recomende UTILIA',
              ),
              _shareUtilia,
            ),
            const SizedBox(height: 8),
            _setting(
              Icons.privacy_tip_outlined,
              text(
                'Política de privacidad',
                'Privacy policy',
                'Politique de confidentialité',
                'Datenschutzerklärung',
                'Privacy',
                'Política de privacidade',
              ),
              text(
                'Tus datos, tu control',
                'Your data, your control',
                'Vos données, votre contrôle',
                'Ihre Daten, Ihre Kontrolle',
                'I tuoi dati, il tuo controllo',
                'Os seus dados, o seu controlo',
              ),
              _showPrivacy,
            ),
            const SizedBox(height: 8),
            _setting(
              Icons.info_outline_rounded,
              text(
                'Acerca de',
                'About',
                'À propos',
                'Über',
                'Informazioni',
                'Sobre',
              ),
              'UTILIA v0.5.5',
              _showAbout,
            ),
          ],
        ),
      );

  Future<void> _showPremium() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: AnimatedBuilder(
          animation: widget.monetization,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE7A3), Color(0xFFD7AE4B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF513B00),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UTILIA Premium',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.monetization.isPremium
                                ? text(
                                    'Premium activo',
                                    'Premium active',
                                    'Premium actif',
                                    'Premium aktiv',
                                    'Premium attivo',
                                    'Premium ativo',
                                  )
                                : text(
                                    'Una compra. Sin anuncios.',
                                    'One purchase. No ads.',
                                    'Un achat. Sans publicités.',
                                    'Ein Kauf. Keine Werbung.',
                                    'Un acquisto. Niente pubblicità.',
                                    'Uma compra. Sem anúncios.',
                                  ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _premiumBenefit(
                  Icons.block_rounded,
                  text(
                    'Sin anuncios',
                    'No ads',
                    'Sans publicités',
                    'Keine Werbung',
                    'Senza pubblicità',
                    'Sem anúncios',
                  ),
                ),
                _premiumBenefit(
                  Icons.all_inclusive_rounded,
                  text(
                    'Desbloqueo permanente',
                    'Permanent unlock',
                    'Déblocage permanent',
                    'Dauerhafte Freischaltung',
                    'Sblocco permanente',
                    'Desbloqueio permanente',
                  ),
                ),
                _premiumBenefit(
                  Icons.sync_rounded,
                  text(
                    'Restauración de compra desde Google Play',
                    'Restore purchases through Google Play',
                    'Restauration des achats via Google Play',
                    'Käufe über Google Play wiederherstellen',
                    'Ripristino degli acquisti tramite Google Play',
                    'Restaurar compras através do Google Play',
                  ),
                ),
                const SizedBox(height: 16),
                if (!widget.monetization.isPremium) ...[
                  Text(
                    widget.monetization.premiumPrice,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 30,
                          color: const Color(0xFFB4871B),
                        ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: widget.monetization.premiumProduct != null ||
                            widget.monetization.storeAvailable
                        ? () async {
                            await widget.monetization.buyPremium();
                          }
                        : () async {
                            await widget.monetization.restorePremium();
                          },
                    icon: const Icon(Icons.workspace_premium_rounded),
                    label: Text(
                      text(
                        'Comprar Premium',
                        'Buy Premium',
                        'Acheter Premium',
                        'Premium kaufen',
                        'Acquista Premium',
                        'Comprar Premium',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => widget.monetization.restorePremium(),
                    child: Text(
                      text(
                        'Restaurar compra',
                        'Restore purchase',
                        'Restaurer l’achat',
                        'Kauf wiederherstellen',
                        'Ripristina acquisto',
                        'Restaurar compra',
                      ),
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7AE4B).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFFB4871B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text(
                              'Premium está activo. Los anuncios permanecerán desactivados.',
                              'Premium is active. Ads will remain disabled.',
                              'Premium est actif. Les publicités resteront désactivées.',
                              'Premium ist aktiv. Werbung bleibt deaktiviert.',
                              'Premium è attivo. Le pubblicità resteranno disattivate.',
                              'Premium está ativo. Os anúncios permanecerão desativados.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.monetization.privacyOptionsRequired) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => widget.monetization.showPrivacyOptions(),
                    child: Text(
                      text(
                        'Opciones de privacidad',
                        'Privacy options',
                        'Options de confidentialité',
                        'Datenschutzoptionen',
                        'Opzioni privacy',
                        'Opções de privacidade',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  text(
                    'El pago se gestiona mediante Google Play. UTILIA no recibe los datos de tu tarjeta.',
                    'Payment is handled by Google Play. UTILIA does not receive your card details.',
                    'Le paiement est géré par Google Play. UTILIA ne reçoit pas les données de votre carte.',
                    'Die Zahlung wird über Google Play abgewickelt. UTILIA erhält keine Kartendaten.',
                    'Il pagamento è gestito da Google Play. UTILIA non riceve i dati della tua carta.',
                    'O pagamento é processado pelo Google Play. A UTILIA não recebe os dados do seu cartão.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _premiumBenefit(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB4871B), size: 21),
            const SizedBox(width: 9),
            Expanded(child: Text(label)),
          ],
        ),
      );

  Widget _setting(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) =>
      Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          leading:
              UtiliaSoftIcon(icon: icon, color: UtiliaBrand.blue, size: 44),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle:
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );

  Widget _dialogBody(String title, String message, {IconData? icon}) =>
      AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: UtiliaBrand.blue),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              text(
                'Cerrar',
                'Close',
                'Fermer',
                'Schließen',
                'Chiudi',
                'Fechar',
              ),
            ),
          ),
        ],
      );

  Future<void> _openSettings() async {
    var selectedLanguage = widget.language;
    var selectedDarkMode = widget.darkMode;
    await showDialog<void>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialogState) => AlertDialog(
          title: Text(s.languageLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<UtiliaLanguage>(
                initialValue: selectedLanguage,
                decoration: InputDecoration(
                  labelText: text(
                    'Idioma',
                    'Language',
                    'Langue',
                    'Sprache',
                    'Lingua',
                    'Idioma',
                  ),
                ),
                items: UtiliaLanguage.values
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(UtiliaStrings(l).languageName),
                      ),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  setDialogState(() => selectedLanguage = value);
                  await widget.onLanguage(value);
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  text(
                    'Modo oscuro',
                    'Dark mode',
                    'Mode sombre',
                    'Dunkelmodus',
                    'Modalità scura',
                    'Modo escuro',
                  ),
                ),
                value: selectedDarkMode,
                onChanged: (value) async {
                  setDialogState(() => selectedDarkMode = value);
                  await widget.onTheme(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(
                text(
                  'Cerrar',
                  'Close',
                  'Fermer',
                  'Schließen',
                  'Chiudi',
                  'Fechar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWhatsNew() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _dialogBody(
        text(
          'Novedades',
          'What’s new',
          'Nouveautés',
          'Neuigkeiten',
          'Novità',
          'Novidades',
        ),
        text(
          'UTILIA v0.5.5 incluye herramientas, favoritos, historial, selector de idioma y modo oscuro. Seguimos preparando la aplicación para producción.',
          'UTILIA v0.5.5 includes tools, favorites, history, language selection and dark mode. We are continuing to prepare the app for production.',
          'UTILIA v0.5.5 inclut des outils, des favoris, un historique, le choix de la langue et le mode sombre. La préparation pour la production continue.',
          'UTILIA v0.5.5 enthält Werkzeuge, Favoriten, Verlauf, Sprachauswahl und Dunkelmodus. Die Vorbereitung für die Produktion wird fortgesetzt.',
          'UTILIA v0.5.5 include strumenti, preferiti, cronologia, selezione della lingua e modalità scura. La preparazione per la produzione continua.',
          'UTILIA v0.5.5 inclui ferramentas, favoritos, histórico, seleção de idioma e modo escuro. A preparação para produção continua.',
        ),
        icon: Icons.new_releases_outlined,
      ),
    );
  }

  Future<void> _rateUtilia() async {
    final marketUri = Uri.parse('market://details?id=com.utilia.app.utilia');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.utilia.app.utilia',
    );
    final opened = await launchUrl(
      marketUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      final webOpened = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (!webOpened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              text(
                'No se pudo abrir Google Play.',
                'Google Play could not be opened.',
                'Impossible d’ouvrir Google Play.',
                'Google Play konnte nicht geöffnet werden.',
                'Impossibile aprire Google Play.',
                'Não foi possível abrir o Google Play.',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareUtilia() async {
    final message = text(
      'Descubre UTILIA: herramientas útiles para tu día a día.',
      'Discover UTILIA: useful tools for everyday life.',
      'Découvrez UTILIA : des outils utiles au quotidien.',
      'Entdecke UTILIA: nützliche Werkzeuge für den Alltag.',
      'Scopri UTILIA: strumenti utili per ogni giorno.',
      'Descubra a UTILIA: ferramentas úteis para o dia a dia.',
    );
    await SharePlus.instance.share(
      ShareParams(
        text:
            '$message\\n\\nhttps://play.google.com/store/apps/details?id=com.utilia.app.utilia',
      ),
    );
  }

  Future<void> _showPrivacy() async {
    final uri = Uri.parse(
      'https://baltas80.github.io/UTILIA-/privacy-policy.html',
    );
    final title = text(
      'Política de privacidad',
      'Privacy policy',
      'Politique de confidentialité',
      'Datenschutzerklärung',
      'Privacy',
      'Política de privacidade',
    );
    final message = text(
      'UTILIA funciona principalmente de forma local. Los favoritos, el historial, el idioma y el modo oscuro se almacenan en el dispositivo. Compartir un resultado solo ocurre cuando tú lo solicitas.',
      'UTILIA works mainly locally. Favorites, history, language and dark mode are stored on the device. Sharing a result only occurs when you request it.',
      'UTILIA fonctionne principalement en local. Les favoris, l’historique, la langue et le mode sombre sont stockés sur l’appareil. Le partage d’un résultat ne se produit que lorsque vous le demandez.',
      'UTILIA arbeitet hauptsächlich lokal. Favoriten, Verlauf, Sprache und Dunkelmodus werden auf dem Gerät gespeichert. Ein Ergebnis wird nur geteilt, wenn Sie dies anfordern.',
      'UTILIA funziona principalmente in locale. Preferiti, cronologia, lingua e modalità scura sono memorizzati sul dispositivo. Un risultato viene condiviso solo quando lo richiedi.',
      'A UTILIA funciona principalmente de forma local. Favoritos, histórico, idioma e modo escuro são armazenados no dispositivo. A partilha de um resultado só ocorre quando a solicita.',
    );
    final openLabel = text(
      'Abrir política de privacidad',
      'Open privacy policy',
      'Ouvrir la politique de confidentialité',
      'Datenschutzerklärung öffnen',
      'Apri la privacy policy',
      'Abrir política de privacidade',
    );
    final errorMessage = text(
      'No se pudo abrir la política.',
      'The privacy policy could not be opened.',
      'Impossible d’ouvrir la politique de confidentialité.',
      'Die Datenschutzerklärung konnte nicht geöffnet werden.',
      'Impossibile aprire la privacy policy.',
      'Não foi possível abrir a política de privacidade.',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: UtiliaBrand.blue),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () async {
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorMessage)));
              }
            },
            child: Text(openLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              text(
                'Cerrar',
                'Close',
                'Fermer',
                'Schließen',
                'Chiudi',
                'Fechar',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'UTILIA',
      applicationVersion: '0.5.5',
      applicationIcon: const UtiliaLogoMark(size: 56),
      applicationLegalese: '© 2026 UTILIA',
      children: [
        const SizedBox(height: 12),
        Text(
          text(
            'Pequeñas herramientas. Grandes soluciones.',
            'Small tools. Big solutions.',
            'De petits outils. De grandes solutions.',
            'Kleine Werkzeuge. Große Lösungen.',
            'Piccoli strumenti. Grandi soluzioni.',
            'Pequenas ferramentas. Grandes soluções.',
          ),
        ),
      ],
    );
  }

  Widget _empty(IconData icon, String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(42),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const UtiliaLogoMark(size: 66),
              const SizedBox(height: 16),
              Icon(icon, size: 32, color: UtiliaBrand.blue),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
}
