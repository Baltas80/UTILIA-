import 'package:flutter/material.dart';

class UtiliaBrand {
  static const blue = Color(0xFF1687F8);
  static const blueDark = Color(0xFF0867D6);
  static const violet = Color(0xFF7652E8);
  static const cyan = Color(0xFF14B7C7);
  static const ink = Color(0xFF0D172A);
  static const lightBackground = Color(0xFFF7F9FC);
  static const darkBackground = Color(0xFF071522);
  static const categoryColors = <String, Color>{
    'Dinero': Color(0xFF16B878), 'Tiempo': Color(0xFF7852E8), 'Casa': Color(0xFFFF8918), 'Coche': Color(0xFF167FE8),
    'Conversores': Color(0xFF11AAA9), 'Salud': Color(0xFFE94370), 'Estudio': Color(0xFFE7A600), 'Varios': Color(0xFF64748B),
  };
  static Color categoryColor(String category, Color fallback) => categoryColors[category] ?? fallback;
}

ThemeData utiliaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: UtiliaBrand.blue, brightness: brightness).copyWith(
    primary: UtiliaBrand.blue, onPrimary: Colors.white,
    surface: dark ? const Color(0xFF0B1726) : Colors.white,
    surfaceContainer: dark ? const Color(0xFF101F31) : const Color(0xFFF1F5FA),
    surfaceContainerHighest: dark ? const Color(0xFF1A2A3B) : const Color(0xFFE9F0F8),
    surfaceTint: Colors.transparent,
  );
  final text = TextTheme(
    displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: scheme.onSurface),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.6, color: scheme.onSurface),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -.2, color: scheme.onSurface),
    titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: scheme.onSurface),
    bodyLarge: TextStyle(fontSize: 14, height: 1.3, color: scheme.onSurface),
    bodyMedium: TextStyle(fontSize: 11.5, height: 1.25, color: scheme.onSurfaceVariant),
    labelLarge: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: scheme.onSurface),
  );
  return ThemeData(
    useMaterial3: true, colorScheme: scheme,
    scaffoldBackgroundColor: dark ? UtiliaBrand.darkBackground : UtiliaBrand.lightBackground,
    textTheme: text, splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, toolbarHeight: 56, titleTextStyle: text.titleLarge, iconTheme: IconThemeData(color: scheme.onSurface, size: 22)),
    cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero, color: dark ? const Color(0xFF101E2E) : Colors.white, surfaceTintColor: Colors.transparent, shadowColor: Colors.black.withValues(alpha: .07), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    navigationBarTheme: NavigationBarThemeData(height: 64, elevation: 0, backgroundColor: dark ? const Color(0xFF081421) : Colors.white, indicatorColor: dark ? const Color(0xFF173D68) : const Color(0xFFDCEBFF), labelTextStyle: WidgetStatePropertyAll(text.labelLarge!.copyWith(fontSize: 9)), iconTheme: WidgetStatePropertyAll(IconThemeData(size: 21, color: scheme.onSurfaceVariant))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w800))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: dark ? const Color(0xFF111F30) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: scheme.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14)),
  );
}

class UtiliaLogoMark extends StatelessWidget {
  const UtiliaLogoMark({super.key, this.size = 46, this.boxed = false});
  final double size; final bool boxed;
  @override Widget build(BuildContext context) {
    final mark = CustomPaint(size: Size.square(size), painter: _LogoPainter());
    if (!boxed) return SizedBox(width: size, height: size, child: mark);
    return Container(width: size, height: size, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [UtiliaBrand.blue, UtiliaBrand.violet]), borderRadius: BorderRadius.circular(size * .25), boxShadow: [BoxShadow(color: UtiliaBrand.blue.withValues(alpha: .20), blurRadius: 12, offset: const Offset(0, 5))]), padding: EdgeInsets.all(size * .18), child: CustomPaint(painter: _LogoPainter(invert: true)));
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({this.invert = false}); final bool invert;
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * .19..strokeCap = StrokeCap.round;
    paint.shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: invert ? [Colors.white, Colors.white] : [UtiliaBrand.blue, UtiliaBrand.blueDark]).createShader(Offset.zero & size);
    final path = Path()..moveTo(size.width * .23, size.height * .18)..lineTo(size.width * .23, size.height * .57)..cubicTo(size.width * .23, size.height * .82, size.width * .38, size.height * .88, size.width * .50, size.height * .88)..cubicTo(size.width * .62, size.height * .88, size.width * .77, size.height * .82, size.width * .77, size.height * .57)..lineTo(size.width * .77, size.height * .18);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _LogoPainter oldDelegate) => oldDelegate.invert != invert;
}

class UtiliaSectionTitle extends StatelessWidget {
  const UtiliaSectionTitle({super.key, required this.title, this.action}); final String title; final Widget? action;
  @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), if (action != null) action!]);
}

class UtiliaSoftIcon extends StatelessWidget {
  const UtiliaSoftIcon({super.key, required this.icon, required this.color, this.size = 48}); final IconData icon; final Color color; final double size;
  @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: .20), color.withValues(alpha: .06)]), borderRadius: BorderRadius.circular(size * .26)), child: Icon(icon, color: color, size: size * .52));
}

class UtiliaGradientHeader extends StatelessWidget {
  const UtiliaGradientHeader({super.key, required this.title, required this.subtitle, required this.color, required this.icon}); final String title; final String subtitle; final Color color; final IconData icon;
  @override Widget build(BuildContext context) => Container(height: 150, padding: const EdgeInsets.fromLTRB(18, 17, 18, 17), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: .96), color.withValues(alpha: .72)]), borderRadius: BorderRadius.circular(18)), child: Stack(children: [Positioned(right: -12, top: -18, child: Icon(icon, size: 112, color: Colors.white.withValues(alpha: .17))), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 5), ConstrainedBox(constraints: const BoxConstraints(maxWidth: 250), child: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .96), fontSize: 12, height: 1.2, fontWeight: FontWeight.w600)))])]));
}

class UtiliaPill extends StatelessWidget {
  const UtiliaPill({super.key, required this.label, this.selected = false, this.onSelected}); final String label; final bool selected; final ValueChanged<bool>? onSelected;
  @override Widget build(BuildContext context) => FilterChip(label: Text(label), selected: selected, onSelected: onSelected ?? (_) {}, showCheckmark: false, side: BorderSide.none, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, selectedColor: UtiliaBrand.blue, labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface), padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0));
}

class UtiliaCalculatorButton extends StatelessWidget {
  const UtiliaCalculatorButton({super.key, required this.label, required this.onPressed, this.primary = false, this.destructive = false, this.dark = false}); final String label; final VoidCallback onPressed; final bool primary; final bool destructive; final bool dark;
  @override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme; final bg = primary ? scheme.primary : dark ? const Color(0xFF1A2A3B) : scheme.surfaceContainerHighest; final fg = primary ? scheme.onPrimary : destructive ? scheme.error : scheme.onSurface; return Material(color: bg, borderRadius: BorderRadius.circular(13), child: InkWell(borderRadius: BorderRadius.circular(13), onTap: onPressed, child: Center(child: Text(label, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: fg))))); }
}

class UtiliaMountainArtwork extends StatelessWidget {
  const UtiliaMountainArtwork({super.key, this.borderRadius = 18}); final double borderRadius;
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: CustomPaint(painter: _MountainPainter(), child: const SizedBox.expand()));
}

class _MountainPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF79C8FF), Color(0xFFFFC68B), Color(0xFF173E68)]).createShader(rect));
    canvas.drawCircle(Offset(size.width * .79, size.height * .20), size.shortestSide * .12, Paint()..color = Colors.white.withValues(alpha: .58));
    final far = Path()..moveTo(0, size.height * .75)..lineTo(size.width * .22, size.height * .51)..lineTo(size.width * .34, size.height * .66)..lineTo(size.width * .50, size.height * .28)..lineTo(size.width * .67, size.height * .62)..lineTo(size.width * .84, size.height * .50)..lineTo(size.width, size.height * .66)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF315F82).withValues(alpha: .90));
    final near = Path()..moveTo(0, size.height * .82)..lineTo(size.width * .28, size.height * .61)..lineTo(size.width * .40, size.height * .76)..lineTo(size.width * .56, size.height * .43)..lineTo(size.width * .73, size.height * .73)..lineTo(size.width, size.height * .62)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(near, Paint()..color = const Color(0xFF143752).withValues(alpha: .96));
    final snow = Path()..moveTo(size.width * .50, size.height * .28)..lineTo(size.width * .43, size.height * .43)..lineTo(size.width * .49, size.height * .40)..lineTo(size.width * .55, size.height * .47)..lineTo(size.width * .57, size.height * .39)..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: .82));
    for (var i = 0; i < 7; i++) { final x = size.width * (.06 + i * .13); final y = size.height * (.79 + (i.isEven ? .02 : -.01)); final p = Path()..moveTo(x, y)..lineTo(x + size.width * .025, y - size.height * .10)..lineTo(x + size.width * .05, y)..close(); canvas.drawPath(p, Paint()..color = const Color(0xFF0B2941).withValues(alpha: .85)); }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
