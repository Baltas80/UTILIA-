import 'package:flutter/material.dart';
import 'catalog.dart';
import 'calculations.dart';
import 'models/tool.dart';

void main() => runApp(const UtiliaApp());

class UtiliaApp extends StatelessWidget {
  const UtiliaApp({super.key});
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF167FF2);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTILIA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF7FAFD),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';
  int tab = 0;
  final favorites = <ToolType>{};

  @override
  Widget build(BuildContext context) {
    final filtered = tools
        .where((t) => '${t.name} ${t.description} ${t.category}'
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTILIA',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'UTILIA',
              applicationVersion: '0.2.0',
              applicationLegalese: 'Pequeñas herramientas. Grandes soluciones.',
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: tab == 0
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar herramientas...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF167FF2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pequeñas herramientas.\nGrandes soluciones.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 20),
                Text(query.isEmpty ? 'Categorías' : 'Resultados (${filtered.length})',
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (query.isEmpty)
                  ...categories.map((c) => _categoryTile(context, c))
                else
                  ...filtered.map((t) => _toolTile(context, t)),
              ],
            )
          : tab == 1
              ? _favoritesView()
              : tab == 2
                  ? _historyView()
                  : _moreView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'Más'),
        ],
      ),
    );
  }

  Widget _categoryTile(BuildContext context, String category) {
    final list = tools.where((t) => t.category == category).toList();
    final tint = categoryTints[category]!;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tint.withValues(alpha: .13),
          child: Icon(list.first.icon, color: tint),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${list.length} herramientas'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CategoryPage(category: category, tools: list)),
        ),
      ),
    );
  }

  Widget _toolTile(BuildContext context, UtiliaTool tool) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(tool.icon, color: tool.tint),
          title: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(tool.description),
          trailing: Icon(favorites.contains(tool.type) ? Icons.favorite : Icons.chevron_right_rounded),
          onTap: () => openTool(context, tool),
          onLongPress: () => setState(() => favorites.contains(tool.type)
              ? favorites.remove(tool.type)
              : favorites.add(tool.type)),
        ),
      );

  Widget _favoritesView() {
    final list = tools.where((t) => favorites.contains(t.type)).toList();
    return list.isEmpty
        ? const Center(child: Text('Favoritos\nMantén pulsada una herramienta para añadirla.', textAlign: TextAlign.center))
        : ListView(padding: const EdgeInsets.all(16), children: list.map((t) => _toolTile(context, t)).toList());
  }

  Widget _historyView() => const Center(child: Text('Historial\nSe añadirá almacenamiento local en la siguiente iteración.', textAlign: TextAlign.center));
  Widget _moreView() => const Center(child: Text('Más\nTema y preferencias próximamente.', textAlign: TextAlign.center));
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.category, required this.tools});
  final String category;
  final List<UtiliaTool> tools;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(category, style: const TextStyle(fontWeight: FontWeight.w900))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: tools
              .map((t) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(t.icon, color: t.tint),
                      title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(t.description),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => openTool(context, t),
                    ),
                  ))
              .toList(),
        ),
      );
}

void openTool(BuildContext context, UtiliaTool tool) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CalculatorPage(tool: tool)),
    );

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.tool});
  final UtiliaTool tool;
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final controllers = List.generate(3, (_) => TextEditingController());
  double result = 0;
  String resultUnit = '';

  @override
  void initState() {
    super.initState();
    controllers[0].text = widget.tool.type == ToolType.age ||
            widget.tool.type == ToolType.dateDifference
        ? '01/01/2000'
        : '100';
    controllers[1].text = widget.tool.type == ToolType.iva ? '21' : '10';
    controllers[2].text = '1';
  }

  @override
  void dispose() {
    for (final c in controllers) c.dispose();
    super.dispose();
  }

  List<String> get labels {
    switch (widget.tool.type) {
      case ToolType.age:
        return ['Fecha de nacimiento (dd/mm/aaaa)', ''];
      case ToolType.dateDifference:
        return ['Fecha inicial (dd/mm/aaaa)', 'Fecha final (dd/mm/aaaa)'];
      case ToolType.workHours:
        return ['Hora inicio (ej. 8,5)', 'Hora fin (ej. 17)', 'Descanso (min)'];
      case ToolType.countdown:
        return ['Horas', 'Minutos', 'Segundos'];
      case ToolType.length:
        return ['Valor (metros como referencia)', 'Unidad origen (mm/cm/m/km/in/ft/yd/mi)', 'Unidad destino'];
      case ToolType.weight:
        return ['Valor', 'Unidad origen (mg/g/kg/t/oz/lb)', 'Unidad destino'];
      case ToolType.bmi:
        return ['Peso (kg)', 'Altura (cm)'];
      case ToolType.fuel:
        return ['Distancia (km)', 'Consumo (L/100 km)', 'Precio €/L'];
      case ToolType.tip:
        return ['Cuenta (€)', 'Propina (%)', 'Personas'];
      case ToolType.loan:
        return ['Capital (€)', 'Interés anual (%)', 'Meses'];
      case ToolType.compoundInterest:
        return ['Capital (€)', 'Interés anual (%)', 'Años'];
      case ToolType.area:
        return ['Largo (m)', 'Ancho (m)'];
      case ToolType.paint:
        return ['Superficie (m²)', 'Cobertura (m²/L)'];
      case ToolType.electricity:
        return ['Potencia (W)', 'Horas/día', 'Días'];
      case ToolType.costPerKm:
        return ['Coste total (€)', 'Kilómetros'];
      case ToolType.gradeAverage:
        return ['Notas separadas por comas', ''];
      case ToolType.ruleOfThree:
        return ['A', 'B', 'C'];
      default:
        return ['Cantidad', 'Porcentaje (%)'];
    }
  }

  DateTime? _parseDate(String value) {
    final p = value.trim().split('/');
    if (p.length != 3) return null;
    final day = int.tryParse(p[0]);
    final month = int.tryParse(p[1]);
    final year = int.tryParse(p[2]);
    if (day == null || month == null || year == null) return null;
    final date = DateTime(year, month, day);
    return date.day == day && date.month == month && date.year == year ? date : null;
  }

  void calculate() {
    final x = parseNumber(controllers[0].text);
    final y = parseNumber(controllers[1].text);
    final z = parseNumber(controllers[2].text);
    String unit = '';
    double r;

    switch (widget.tool.type) {
      case ToolType.percentage: r = percentageOf(x, y); break;
      case ToolType.discount: r = discountedPrice(x, y); break;
      case ToolType.iva: r = priceWithIva(x, y); break;
      case ToolType.tip: r = tipPerPerson(x, y, z.toInt()); break;
      case ToolType.loan: r = loanPayment(x, y, z.toInt()); break;
      case ToolType.compoundInterest: r = compound(x, y, z.toInt()); break;
      case ToolType.area: r = area(x, y); break;
      case ToolType.paint: r = paintLitres(x, y); unit = 'L'; break;
      case ToolType.electricity: r = electricityCost(x, y, z, .20); unit = '€'; break;
      case ToolType.fuel: r = fuelCost(x, y, z); unit = '€'; break;
      case ToolType.costPerKm: r = costPerKm(x, y); unit = '€/km'; break;
      case ToolType.bmi: r = bmi(x, y); break;
      case ToolType.gradeAverage:
        r = gradeAverage(controllers[0].text
            .split(',')
            .map(parseNumber)
            .where((v) => controllers[0].text.trim().isNotEmpty)
            .toList());
        break;
      case ToolType.ruleOfThree: r = ruleOfThree(x, y, z); break;
      case ToolType.age:
        final date = _parseDate(controllers[0].text);
        if (date == null) { _error('Usa una fecha válida: dd/mm/aaaa'); return; }
        r = ageInYears(date); unit = 'años';
        break;
      case ToolType.dateDifference:
        final from = _parseDate(controllers[0].text);
        final to = _parseDate(controllers[1].text);
        if (from == null || to == null) { _error('Usa fechas válidas: dd/mm/aaaa'); return; }
        r = dateDifferenceDays(from, to).toDouble(); unit = 'días';
        break;
      case ToolType.workHours:
        r = workHours(x, y, z); unit = 'h';
        break;
      case ToolType.countdown:
        r = countdownSeconds(x.toInt(), y.toInt(), z.toInt()).toDouble(); unit = 'seg';
        break;
      case ToolType.length:
        final from = controllers[1].text.trim().toLowerCase();
        final to = controllers[2].text.trim().toLowerCase();
        r = convertLength(x, from, to); unit = to;
        break;
      case ToolType.weight:
        final from = controllers[1].text.trim().toLowerCase();
        final to = controllers[2].text.trim().toLowerCase();
        r = convertWeight(x, from, to); unit = to;
        break;
    }
    setState(() { result = r; resultUnit = unit; });
  }

  void _error(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.tool.name, style: const TextStyle(fontWeight: FontWeight.w900))),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(widget.tool.description, style: const TextStyle(color: Color(0xFF52606D))),
            const SizedBox(height: 22),
            for (var i = 0; i < labels.length; i++)
              if (labels[i].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextField(
                    controller: controllers[i],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: labels[i],
                      filled: true,
                      border: const OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
            FilledButton(onPressed: calculate, child: const Text('Calcular')),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F8F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resultado', style: TextStyle(fontWeight: FontWeight.w800)),
                  Text('${result.toStringAsFixed(2).replaceAll('.', ',')} $resultUnit',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      );
}
