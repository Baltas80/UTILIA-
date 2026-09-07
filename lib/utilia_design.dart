import 'package:flutter/material.dart';

class UtiliaBrand {
  static const blue = Color(0xFF246BFE);
  static const violet = Color(0xFF7048E8);
  static const cyan = Color(0xFF12B8D6);
  static const ink = Color(0xFF121522);
  static const lightBackground = Color(0xFFF5F7FC);
  static const darkBackground = Color(0xFF0D1018);

  static const categoryColors = <String, Color>{
    'Dinero': Color(0xFF19A974),
    'Tiempo': Color(0xFF7654E8),
    'Casa': Color(0xFFFF8A00),
    'Coche': Color(0xFF0FA9C7),
    'Conversores': Color(0xFF1488C9),
    'Salud': Color(0xFFE83E68),
    'Estudio': Color(0xFFE6A400),
    'Varios': Color(0xFF65758B),
  };

  static Color categoryColor(String category, Color fallback) => categoryColors[category] ?? fallback;
}

ThemeData utiliaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: UtiliaBrand.blue,
    brightness: brightness,
  );

  final text = TextTheme(
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.3, color: scheme.onSurface),
    headlineSmall: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.8, color: scheme.onSurface),
    titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.25, color: scheme.onSurface),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w750, color: scheme.onSurface),
    bodyLarge: TextStyle(fontSize: 16, height: 1.35, color: scheme.onSurface),
    bodyMedium: TextStyle(fontSize: 14, height: 1.35, color: scheme.onSurfaceVariant),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: scheme.onSurface),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? UtiliaBrand.darkBackground : UtiliaBrand.lightBackground,
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 72,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF171B25) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: .08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 78,
      elevation: 0,
      backgroundColor: dark ? const Color(0xFF12151D) : Colors.white,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(text.labelLarge!.copyWith(fontSize: 11)),
      iconTheme: WidgetStatePropertyAll(IconThemeData(size: 23, color: scheme.onSurfaceVariant)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF171B25) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    ),
  );
}

class UtiliaLogoMark extends StatelessWidget {
  const UtiliaLogoMark({super.key, this.size = 46});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [UtiliaBrand.blue, UtiliaBrand.violet]),
          borderRadius: BorderRadius.circular(size * .30),
          boxShadow: [BoxShadow(color: UtiliaBrand.blue.withValues(alpha: .20), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Text('U', style: TextStyle(color: Colors.white, fontSize: size * .56, fontWeight: FontWeight.w900, height: 1)),
      );
}

class UtiliaSectionTitle extends StatelessWidget {
  const UtiliaSectionTitle({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
          if (action != null) action!,
        ],
      );
}
