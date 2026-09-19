import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:share_plus/share_plus.dart';

import 'catalog.dart';
import 'category_page.dart';
import 'localization.dart';
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
  bool darkMode = false;
  UtiliaLanguage language = UtiliaLanguage.system;
  @override
  void initState() {
    super.initState();
    _load();
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
        Locale('pt')
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: utiliaTheme(Brightness.light),
      darkTheme: utiliaTheme(Brightness.dark),
      home: UtiliaHomePage(
          storage: storage,
          darkMode: darkMode,
          language: language,
          onTheme: _theme,
          onLanguage: _language));
}

class UtiliaHomePage extends StatefulWidget {
  const UtiliaHomePage(
      {super.key,
      required this.storage,
      required this.darkMode,
      required this.language,
      required this.onTheme,
      required this.onLanguage});
  final UtiliaStorage storage;
  final bool darkMode;
  final UtiliaLanguage language;
  final Future<void> Function(bool) onTheme;
  final Future<void> Function(UtiliaLanguage) onLanguage;
  @override
  State<UtiliaHomePage> createState() => _UtiliaHomePageState();
}

class _UtiliaHomePageState extends State<UtiliaHomePage> {
  int tab = 0;
  Set<ToolType> favorites = {};
  List<Map<String, dynamic>> history = [];

  UtiliaStrings get s => UtiliaStrings(widget.language == UtiliaLanguage.system
      ? UtiliaStrings.effective(
          UtiliaLanguage.system, Localizations.localeOf(context))
      : widget.language);
  String text(
          String es, String en, String fr, String de, String it, String pt) =>
      switch (s.selectedLanguage) {
        UtiliaLanguage.en => en,
        UtiliaLanguage.fr => fr,
        UtiliaLanguage.de => de,
        UtiliaLanguage.it => it,
        UtiliaLanguage.pt => pt,
        _ => es
      };
  String get _subtitle => text(
      'Herramientas para tu día a día',
      'Tools for everyday life',
      'Des outils pour votre quotidien',
      'Werkzeuge für den Alltag',
      'Strumenti per la vita quotidiana',
      'Ferramentas para o dia a dia');
  String get _eyebrow => text(
      'HERRAMIENTAS PARA TU DÍA A DÍA',
      'TOOLS FOR EVERYDAY LIFE',
      'DES OUTILS POUR VOTRE QUOTIDIEN',
      'WERKZEUGE FÜR DEN ALLTAG',
      'STRUMENTI PER LA TUA GIORNATA',
      'FERRAMENTAS PARA O DIA A DIA');
  String get _heroSub => text(
      'Todo lo que necesitas en una sola app.',
      'Everything you need in one app.',
      'Tout ce dont vous avez besoin dans une seule app.',
      'Alles, was Sie brauchen, in einer App.',
      'Tutto ciò che serve in un’unica app.',
      'Tudo o que precisa numa só app.');
  String get _seeAll => text('Ver todas', 'See all', 'Voir tout',
      'Alle anzeigen', 'Vedi tutto', 'Ver tudo');
  String get _favoriteSub => text(
      'Tus herramientas favoritas, siempre a mano.',
      'Your favorite tools, always at hand.',
      'Vos outils préférés, toujours à portée de main.',
      'Ihre Lieblingswerkzeuge immer griffbereit.',
      'I tuoi strumenti preferiti, sempre a portata di mano.',
      'As suas ferramentas favoritas, sempre à mão.');

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
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
            index: tab, children: [_home(), _favorites(), _history(), _more()]),
        bottomNavigationBar: NavigationBar(
          height: 64,
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: s.home),
            NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: s.favorites),
            NavigationDestination(
                icon: const Icon(Icons.history_rounded),
                selectedIcon: const Icon(Icons.history_rounded),
                label: s.history),
            NavigationDestination(
                icon: const Icon(Icons.grid_view_rounded),
                selectedIcon: const Icon(Icons.grid_view_rounded),
                label: s.more),
          ],
        ),
      );

  Widget _brand() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 9, 12, 9),
        child: Row(children: [
          const UtiliaLogoMark(size: 44),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('UTILIA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 21, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(height: 3),
                Text(_subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 9.5, fontWeight: FontWeight.w700)),
              ])),
          IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => tab = 3),
              icon: const Icon(Icons.settings_outlined)),
        ]),
      );

  Widget _home() {
    final quickTypes = [
      ToolType.calculator,
      ToolType.scientificCalculator,
      ToolType.percentage,
      ToolType.ruleOfThree
    ];
    final quick = quickTypes.map(_find).whereType<UtiliaTool>().toList();
    return SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 20), children: [
      _brand(),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18), child: _hero()),
      const SizedBox(height: 12),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _benefits()),
      const SizedBox(height: 19),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: UtiliaSectionTitle(
              title: text('Acceso rápido', 'Quick access', 'Accès rapide',
                  'Schnellzugriff', 'Accesso rapido', 'Acesso rápido'),
              action: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4)),
                  onPressed: () => setState(() => tab = 1),
                  child: Text(_seeAll)))),
      const SizedBox(height: 5),
      SizedBox(
          height: 108,
          child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: quick.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _quick(quick[i]))),
      const SizedBox(height: 18),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: UtiliaSectionTitle(
              title: s.categories,
              action: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4)),
                  onPressed: () => setState(() => tab = 0),
                  child: Text(_seeAll)))),
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
                  childAspectRatio: 1.12),
              itemBuilder: (_, i) => _category(categories[i]))),
    ]));
  }

  Widget _hero() => Container(
      height: 222,
      clipBehavior: Clip.antiAlias,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: [
        BoxShadow(
            color: UtiliaBrand.blue.withValues(alpha: .15),
            blurRadius: 22,
            offset: const Offset(0, 10))
      ]),
      child: Stack(children: [
        const Positioned.fill(child: UtiliaMountainArtwork(borderRadius: 0)),
        Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xE0000000)])))),
        Positioned(
            left: 18,
            right: 18,
            bottom: 17,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_eyebrow,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .95)),
              const SizedBox(height: 6),
              Text(s.slogan,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.03,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text(_heroSub,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ])),
      ]));

  Widget _benefits() => Row(children: [
        _benefit(Icons.bolt_rounded,
            text('Útil', 'Useful', 'Utile', 'Nützlich', 'Utile', 'Útil')),
        const SizedBox(width: 8),
        _benefit(
            Icons.favorite_border_rounded,
            text('Simple', 'Simple', 'Simple', 'Einfach', 'Semplice',
                'Simples')),
        const SizedBox(width: 8),
        _benefit(
            Icons.all_inclusive_rounded,
            text('Siempre contigo', 'Always with you', 'Toujours avec vous',
                'Immer bei dir', 'Sempre con te', 'Sempre consigo')),
      ]);
  Widget _benefit(IconData icon, String label) => Expanded(
      child: Container(
          height: 55,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(15)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 19, color: UtiliaBrand.blue),
            const SizedBox(width: 5),
            Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 9.5, fontWeight: FontWeight.w700)))
          ])));

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
                onTap: () =>
                    openUtiliaTool(context, tool, widget.storage, _load, s),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 10, 7, 8),
                    child: Column(children: [
                      UtiliaSoftIcon(icon: tool.icon, color: color, size: 46),
                      const Spacer(),
                      Text(name(tool),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 9.5, height: 1.1))
                    ])))));
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
                        s: s))),
            child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UtiliaSoftIcon(
                          icon: list.first.icon, color: color, size: 48),
                      const Spacer(),
                      Text(s.category(category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Expanded(
                            child: Text(s.toolsCount(list.length),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 9.5))),
                        Icon(Icons.chevron_right_rounded,
                            color: color, size: 18)
                      ])
                    ]))));
  }

  Widget _darkPage(String title, String subtitle, IconData icon, Widget body) =>
      Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF082B46), Color(0xFF0B1726)])),
          child: SafeArea(
              child: Column(children: [
            _brandDark(title),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(children: [
                  Expanded(
                      child: Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12))),
                  Icon(icon, color: Colors.white24, size: 46)
                ])),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28))),
                    child: body))
          ]));
  Widget _brandDark(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 14, 6),
      child: Row(children: [
        IconButton(
            onPressed: () => setState(() => tab = 0),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)))
      ]));

  Widget _toolTile(UtiliaTool tool) {
    final color = UtiliaBrand.categoryColor(tool.category, tool.tint);
    final fav = favorites.contains(tool.type);
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
            child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () =>
                    openUtiliaTool(context, tool, widget.storage, _load, s),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      UtiliaSoftIcon(icon: tool.icon, color: color, size: 44),
                      const SizedBox(width: 11),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(name(tool),
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(desc(tool),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium)
                          ])),
                      IconButton(
                          onPressed: () => _favorite(tool.type),
                          icon: Icon(
                              fav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: fav
                                  ? const Color(0xFFE93D68)
                                  : Theme.of(context).colorScheme.outline))
                    ])))));
  }

  Widget _favorites() {
    final body = favorites.isEmpty
        ? _empty(Icons.favorite_border_rounded, s.emptyFavorites)
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
                ...tools.where((t) => favorites.contains(t.type)).map(_toolTile)
              ]);
    return _darkPage(s.favorites, _favoriteSub, Icons.favorite_rounded, body);
  }

  Widget _history() {
    final body = history.isEmpty
        ? _empty(Icons.history_rounded, s.emptyHistory)
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
                Row(children: [
                  UtiliaPill(
                      label: text(
                          'Todos', 'All', 'Tous', 'Alle', 'Tutti', 'Todos'),
                      selected: true),
                  const SizedBox(width: 6),
                  UtiliaPill(label: s.calculate),
                  const Spacer(),
                  IconButton(
                      onPressed: () async {
                        await widget.storage.clearHistory();
                        await _load();
                      },
                      icon: const Icon(Icons.delete_outline_rounded))
                ]),
                const SizedBox(height: 10),
                ...history.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Card(
                        child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 2),
                            leading: UtiliaSoftIcon(
                                icon: Icons.functions_rounded,
                                color: UtiliaBrand.blue,
                                size: 40),
                            title: Text('${h['expression'] ?? h['tool'] ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontSize: 12.5)),
                            subtitle: Text('${h['result'] ?? ''}',
                                style:
                                    Theme.of(context).textTheme.bodyMedium)))))
              ]);
    return _darkPage(
        s.history,
        text(
            'Tus cálculos recientes, siempre disponibles.',
            'Your recent calculations, always available.',
            'Vos calculs récents, toujours disponibles.',
            'Ihre letzten Berechnungen, immer verfügbar.',
            'I tuoi calcoli recenti, sempre disponibili.',
            'Os seus cálculos recentes, sempre disponíveis.'),
        Icons.history_rounded,
        body);
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
                    child: Row(children: [
                      const UtiliaLogoMark(size: 54),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('UTILIA',
                                style: Theme.of(context).textTheme.titleLarge),
                            Text('v0.5.3',
                                style: Theme.of(context).textTheme.bodyMedium)
                          ])),
                      IconButton(
                          onPressed: () => widget.onTheme(!widget.darkMode),
                          tooltip: text(
                              'Cambiar tema',
                              'Change theme',
                              'Changer de thème',
                              'Thema ändern',
                              'Cambia tema',
                              'Alterar tema'),
                          icon: Icon(
                              widget.darkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_outlined,
                              color: UtiliaBrand.blue))
                    ]))),
            const SizedBox(height: 10),
            _setting(
                Icons.settings_outlined,
                text('Ajustes', 'Settings', 'Réglages', 'Einstellungen',
                    'Impostazioni', 'Definições'),
                text(
                    'Tema, idioma y preferencias',
                    'Theme, language and preferences',
                    'Thème, langue et préférences',
                    'Thema, Sprache und Einstellungen',
                    'Tema, lingua e preferenze',
                    'Tema, idioma e preferências'),
                _openSettings),
            const SizedBox(height: 8),
            _setting(
                Icons.new_releases_outlined,
                text('Novedades', 'What’s new', 'Nouveautés', 'Neuigkeiten',
                    'Novità', 'Novidades'),
                text(
                    'Ver qué hay de nuevo',
                    'See what’s new',
                    'Voir les nouveautés',
                    'Neuigkeiten ansehen',
                    'Scopri le novità',
                    'Ver novidades'),
                _showWhatsNew),
            const SizedBox(height: 8),
            _setting(
                Icons.star_outline_rounded,
                text('Valora UTILIA', 'Rate UTILIA', 'Évaluer UTILIA',
                    'UTILIA bewerten', 'Valuta UTILIA', 'Avaliar UTILIA'),
                text(
                    'Tu opinión nos ayuda',
                    'Your opinion helps us',
                    'Votre avis nous aide',
                    'Ihre Meinung hilft uns',
                    'La tua opinione ci aiuta',
                    'A sua opinião ajuda-nos'),
                _rateUtilia),
            const SizedBox(height: 8),
            _setting(
                Icons.share_outlined,
                text('Compartir app', 'Share app', 'Partager l’app',
                    'App teilen', 'Condividi app', 'Partilhar app'),
                text(
                    'Recomienda UTILIA',
                    'Recommend UTILIA',
                    'Recommandez UTILIA',
                    'UTILIA empfehlen',
                    'Consiglia UTILIA',
                    'Recomende UTILIA'),
                _shareUtilia),
            const SizedBox(height: 8),
            _setting(
                Icons.privacy_tip_outlined,
                text(
                    'Política de privacidad',
                    'Privacy policy',
                    'Politique de confidentialité',
                    'Datenschutzerklärung',
                    'Privacy',
                    'Política de privacidade'),
                text(
                    'Tus datos, tu control',
                    'Your data, your control',
                    'Vos données, votre contrôle',
                    'Ihre Daten, Ihre Kontrolle',
                    'I tuoi dati, il tuo controllo',
                    'Os seus dados, o seu controlo'),
                _showPrivacy),
            const SizedBox(height: 8),
            _setting(
                Icons.info_outline_rounded,
                text('Acerca de', 'About', 'À propos', 'Über', 'Informazioni',
                    'Sobre'),
                'UTILIA v0.5.3',
                _showAbout)
          ]));

  Widget _setting(
          IconData icon, String title, String subtitle, VoidCallback? onTap) =>
      Card(
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              leading:
                  UtiliaSoftIcon(icon: icon, color: UtiliaBrand.blue, size: 44),
              title:
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
              subtitle:
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onTap));

  Widget _dialogBody(String title, String message, {IconData? icon}) =>
      AlertDialog(
          title: Row(children: [
            if (icon != null) ...[
              Icon(icon, color: UtiliaBrand.blue),
              const SizedBox(width: 10)
            ],
            Expanded(child: Text(title))
          ]),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(text('Cerrar', 'Close', 'Fermer', 'Schließen',
                    'Chiudi', 'Fechar')))
          ]);

  Future<void> _openSettings() async {
    await showDialog<void>(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (c, setDialogState) => AlertDialog(
                  title: Text(s.languageLabel),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButtonFormField<UtiliaLanguage>(
                        initialValue: widget.language,
                        decoration: InputDecoration(
                            labelText: text('Idioma', 'Language', 'Langue',
                                'Sprache', 'Lingua', 'Idioma')),
                        items: UtiliaLanguage.values
                            .map((l) => DropdownMenuItem(
                                value: l,
                                child: Text(UtiliaStrings(l).languageName)))
                            .toList(),
                        onChanged: (value) async {
                          if (value == null) return;
                          await widget.onLanguage(value);
                          if (c.mounted) setDialogState(() {});
                        }),
                    SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(text(
                            'Modo oscuro',
                            'Dark mode',
                            'Mode sombre',
                            'Dunkelmodus',
                            'Modalità scura',
                            'Modo escuro')),
                        value: widget.darkMode,
                        onChanged: (value) async {
                          await widget.onTheme(value);
                          if (c.mounted) setDialogState(() {});
                        })
                  ]),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: Text(text('Cerrar', 'Close', 'Fermer',
                            'Schließen', 'Chiudi', 'Fechar')))
                  ],
                )));
  }

  Future<void> _showWhatsNew() async {
    await showDialog<void>(
        context: context,
        builder: (_) => _dialogBody(
            text('Novedades', 'What’s new', 'Nouveautés', 'Neuigkeiten',
                'Novità', 'Novidades'),
            text(
                'UTILIA v0.5.3 incluye herramientas, favoritos, historial, selector de idioma y modo oscuro. Seguimos preparando la aplicación para producción.',
                'UTILIA v0.5.3 includes tools, favorites, history, language selection and dark mode. We are continuing to prepare the app for production.',
                'UTILIA v0.5.3 inclut des outils, des favoris, un historique, le choix de la langue et le mode sombre. La préparation pour la production continue.',
                'UTILIA v0.5.3 enthält Werkzeuge, Favoriten, Verlauf, Sprachauswahl und Dunkelmodus. Die Vorbereitung für die Produktion wird fortgesetzt.',
                'UTILIA v0.5.3 include strumenti, preferiti, cronologia, selezione della lingua e modalità scura. La preparazione per la produzione continua.',
                'UTILIA v0.5.3 inclui ferramentas, favoritos, histórico, seleção de idioma e modo escuro. A preparação para produção continua.'),
            icon: Icons.new_releases_outlined));
  }

  Future<void> _rateUtilia() async {
    await showDialog<void>(
        context: context,
        builder: (_) => _dialogBody(
            text('Valora UTILIA', 'Rate UTILIA', 'Évaluer UTILIA',
                'UTILIA bewerten', 'Valuta UTILIA', 'Avaliar UTILIA'),
            text(
                'La valoración en Google Play estará disponible cuando UTILIA esté publicada. Gracias por probar la aplicación.',
                'The Google Play rating will be available once UTILIA is published. Thank you for trying the app.',
                'La note Google Play sera disponible lorsque UTILIA sera publiée. Merci d’essayer l’application.',
                'Die Google-Play-Bewertung wird verfügbar sein, sobald UTILIA veröffentlicht ist. Danke für das Testen der App.',
                'La valutazione su Google Play sarà disponibile quando UTILIA sarà pubblicata. Grazie per aver provato l’app.',
                'A avaliação no Google Play estará disponível quando a UTILIA for publicada. Obrigado por experimentar a aplicação.'),
            icon: Icons.star_outline_rounded));
  }

  Future<void> _shareUtilia() async {
    await SharePlus.instance.share(ShareParams(
        text: text(
            'Descubre UTILIA: herramientas útiles para tu día a día.',
            'Discover UTILIA: useful tools for everyday life.',
            'Découvrez UTILIA : des outils utiles au quotidien.',
            'Entdecke UTILIA: nützliche Werkzeuge für den Alltag.',
            'Scopri UTILIA: strumenti utili per ogni giorno.',
            'Descubra a UTILIA: ferramentas úteis para o dia a dia.')));
  }

  Future<void> _showPrivacy() async {
    await showDialog<void>(
        context: context,
        builder: (_) => _dialogBody(
            text(
                'Política de privacidad',
                'Privacy policy',
                'Politique de confidentialité',
                'Datenschutzerklärung',
                'Privacy',
                'Política de privacidade'),
            text(
                'UTILIA está diseñada para funcionar de forma local siempre que sea posible. Los favoritos, el historial y las preferencias se almacenan en el dispositivo. No introduzcas información personal innecesaria en las herramientas.',
                'UTILIA is designed to work locally whenever possible. Favorites, history and preferences are stored on the device. Do not enter unnecessary personal information into the tools.',
                'UTILIA est conçue pour fonctionner localement autant que possible. Les favoris, l’historique et les préférences sont stockés sur le dispositif. N’entrez pas d’informations personnelles inutiles dans les outils.',
                'UTILIA ist so konzipiert, dass sie möglichst lokal arbeitet. Favoriten, Verlauf und Einstellungen werden auf dem Gerät gespeichert. Geben Sie keine unnötigen personenbezogenen Daten in die Werkzeuge ein.',
                'UTILIA è progettata per funzionare localmente quando possibile. Preferiti, cronologia e preferenze sono memorizzati sul dispositivo. Non inserire informazioni personali non necessarie negli strumenti.',
                'A UTILIA foi concebida para funcionar localmente sempre que possível. Favoritos, histórico e preferências são armazenados no dispositivo. Não introduza informações pessoais desnecessárias nas ferramentas.'),
            icon: Icons.privacy_tip_outlined));
  }

  void _showAbout() {
    showAboutDialog(
        context: context,
        applicationName: 'UTILIA',
        applicationVersion: '0.5.3',
        applicationIcon: const UtiliaLogoMark(size: 56),
        applicationLegalese: '© 2026 UTILIA',
        children: [
          const SizedBox(height: 12),
          Text(text(
              'Pequeñas herramientas. Grandes soluciones.',
              'Small tools. Big solutions.',
              'De petits outils. De grandes solutions.',
              'Kleine Werkzeuge. Große Lösungen.',
              'Piccoli strumenti. Grandi soluzioni.',
              'Pequenas ferramentas. Grandes soluções.'))
        ]);
  }

  Widget _empty(IconData icon, String message) => Center(
      child: Padding(
          padding: const EdgeInsets.all(42),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const UtiliaLogoMark(size: 66),
            const SizedBox(height: 16),
            Icon(icon, size: 32, color: UtiliaBrand.blue),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge)
          ])));
}
