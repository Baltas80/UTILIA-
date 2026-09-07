import 'package:flutter/material.dart';

class UtiliaBrand {
  static const blue = Color(0xFF1677F8);
  static const violet = Color(0xFF7357E8);
  static const cyan = Color(0xFF17B9C8);
  static const ink = Color(0xFF10182B);
  static const lightBackground = Color(0xFFF7F9FD);
  static const darkBackground = Color(0xFF07111F);
  static const categoryColors = <String, Color>{
    'Dinero': Color(0xFF18B77B),
    'Tiempo': Color(0xFF7654E8),
    'Casa': Color(0xFFFF8A17),
    'Coche': Color(0xFF1686EA),
    'Conversores': Color(0xFF12AFAF),
    'Salud': Color(0xFFE9426F),
    'Estudio': Color(0xFFE8A900),
    'Varios': Color(0xFF68778C),
  };
  static Color categoryColor(String category, Color fallback) => categoryColors[category] ?? fallback;
}

ThemeData utiliaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: UtiliaBrand.blue, brightness: brightness).copyWith(
    primary: UtiliaBrand.blue,
    onPrimary: Colors.white,
    surface: dark ? const Color(0xFF0C1726) : Colors.white,
    surfaceContainer: dark ? const Color(0xFF101E30) : const Color(0xFFF1F5FB),
    surfaceContainerHighest: dark ? const Color(0xFF1B2A3B) : const Color(0xFFEAF0F8),
    surfaceTint: Colors.transparent,
  );
  final text = TextTheme(
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.4, color: scheme.onSurface),
    headlineSmall: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.7, color: scheme.onSurface),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -.3, color: scheme.onSurface),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: scheme.onSurface),
    bodyLarge: TextStyle(fontSize: 15, height: 1.35, color: scheme.onSurface),
    bodyMedium: TextStyle(fontSize: 12.5, height: 1.3, color: scheme.onSurfaceVariant),
    labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: scheme.onSurface),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? UtiliaBrand.darkBackground : UtiliaBrand.lightBackground,
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, toolbarHeight: 62, titleTextStyle: text.titleLarge),
    cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero, color: dark ? const Color(0xFF111E2E) : Colors.white, surfaceTintColor: Colors.transparent, shadowColor: Colors.black.withValues(alpha: .08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    navigationBarTheme: NavigationBarThemeData(height: 72, elevation: 0, backgroundColor: dark ? const Color(0xFF091523) : Colors.white, indicatorColor: dark ? const Color(0xFF173C68) : const Color(0xFFE2EEFF), labelTextStyle: WidgetStatePropertyAll(text.labelLarge!.copyWith(fontSize: 10)), iconTheme: WidgetStatePropertyAll(IconThemeData(size: 22, color: scheme.onSurfaceVariant))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), textStyle: const TextStyle(fontWeight: FontWeight.w800))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: dark ? const Color(0xFF111E2E) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: scheme.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
  );
}

class UtiliaLogoMark extends StatelessWidget {
  const UtiliaLogoMark({super.key, this.size = 46});
  final double size;
  @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [UtiliaBrand.blue, UtiliaBrand.violet]), borderRadius: BorderRadius.circular(size * .30), boxShadow: [BoxShadow(color: UtiliaBrand.blue.withValues(alpha: .22), blurRadius: 16, offset: const Offset(0, 7))]), alignment: Alignment.center, child: Text('U', style: TextStyle(color: Colors.white, fontSize: size * .56, fontWeight: FontWeight.w900, height: 1)));
}

class UtiliaSectionTitle extends StatelessWidget {
  const UtiliaSectionTitle({super.key, required this.title, this.action});
  final String title;
  final Widget? action;
  @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), if (action != null) action!]);
}

class UtiliaSoftIcon extends StatelessWidget {
  const UtiliaSoftIcon({super.key, required this.icon, required this.color, this.size = 48});
  final IconData icon;
  final Color color;
  final double size;
  @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: .20), color.withValues(alpha: .06)]), borderRadius: BorderRadius.circular(size * .32)), child: Icon(icon, color: color, size: size * .53));
}

class UtiliaGradientHeader extends StatelessWidget {
  const UtiliaGradientHeader({super.key, required this.title, required this.subtitle, required this.color, required this.icon});
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  @override Widget build(BuildContext context) => Container(height: 142, padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withValues(alpha: .72)]), borderRadius: BorderRadius.circular(26)), child: Stack(children: [Positioned(right: -4, top: -8, child: Icon(icon, size: 92, color: Colors.white.withValues(alpha: .18))), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 5), ConstrainedBox(constraints: const BoxConstraints(maxWidth: 235), child: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .92), fontSize: 12.5, height: 1.25, fontWeight: FontWeight.w600)))])]));
}

class UtiliaPill extends StatelessWidget {
  const UtiliaPill({super.key, required this.label, this.selected = false, this.onSelected});
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(label: Text(label), selected: selected, onSelected: onSelected ?? (_) {}, showCheckmark: false, side: BorderSide.none, backgroundColor: scheme.surfaceContainerHighest, selectedColor: scheme.primary.withValues(alpha: .12), labelStyle: TextStyle(fontWeight: FontWeight.w800, color: selected ? scheme.primary : scheme.onSurface));
  }
}

class UtiliaCalculatorButton extends StatelessWidget {
  const UtiliaCalculatorButton({super.key, required this.label, required this.onPressed, this.primary = false, this.destructive = false, this.dark = false});
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool destructive;
  final bool dark;
  @override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme; final bg = primary ? scheme.primary : dark ? const Color(0xFF1A2A3B) : scheme.surfaceContainerHighest; final fg = primary ? scheme.onPrimary : destructive ? scheme.error : scheme.onSurface; return Material(color: bg, borderRadius: BorderRadius.circular(15), child: InkWell(borderRadius: BorderRadius.circular(15), onTap: onPressed, child: Center(child: Text(label, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: fg))))); }
}

class UtiliaMountainArtwork extends StatelessWidget {
  const UtiliaMountainArtwork({super.key, this.borderRadius = 22});
  final double borderRadius;
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: CustomPaint(painter: _MountainPainter(), child: const SizedBox.expand()));
}

class _MountainPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF83C7FF), Color(0xFFFFC88C), Color(0xFF183D66)]).createShader(rect));
    canvas.drawCircle(Offset(size.width * .78, size.height * .20), size.shortestSide * .12, Paint()..color = Colors.white.withValues(alpha: .58));
    Path mountain(double peak, double base, double shift, double slope) => Path()..moveTo(0, size.height * base)..lineTo(size.width * .24, size.height * (base - slope * .35))..lineTo(size.width * .42 + shift, size.height * peak)..lineTo(size.width * .62, size.height * (base - slope * .25))..lineTo(size.width, size.height * (base - slope * .05))..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(mountain(.20, .83, 0, .42), Paint()..color = const Color(0xFF244D73).withValues(alpha: .84));
    canvas.drawPath(mountain(.34, .91, -.05, .30), Paint()..color = const Color(0xFF153A5B).withValues(alpha: .94));
    final peak = Offset(size.width * .42, size.height * .20);
    final snow = Path()..moveTo(peak.dx, peak.dy)..lineTo(peak.dx - size.width * .07, peak.dy + size.height * .13)..lineTo(peak.dx - size.width * .015, peak.dy + size.height * .09)..lineTo(peak.dx + size.width * .045, peak.dy + size.height * .15)..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: .78));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
