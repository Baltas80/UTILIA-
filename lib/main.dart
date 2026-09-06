import 'package:flutter/material.dart';

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

class ToolCategory {
  const ToolCategory(this.name, this.description, this.icon, this.tint);
  final String name;
  final String description;
  final IconData icon;
  final Color tint;
}

const categories = <ToolCategory>[
  ToolCategory('Dinero', 'Calculadoras financieras', Icons.account_balance_wallet_rounded, Color(0xFF21B981)),
  ToolCategory('Tiempo', 'Fechas, cronómetros y más', Icons.access_time_rounded, Color(0xFF8165E8)),
  ToolCategory('Casa', 'Obras, medidas y consumos', Icons.home_rounded, Color(0xFFFF8A2A)),
  ToolCategory('Coche', 'Viajes, combustible y mantenimiento', Icons.directions_car_rounded, Color(0xFF1689E9)),
  ToolCategory('Conversores', 'Unidades, moneda y más', Icons.swap_horiz_rounded, Color(0xFFE9579C)),
  ToolCategory('Salud', 'IMC, calorías y bienestar', Icons.favorite_rounded, Color(0xFFFF5265)),
  ToolCategory('Estudio', 'Notas, promedios y más', Icons.school_rounded, Color(0xFF20A66E)),
  ToolCategory('Varios', 'Otras herramientas útiles', Icons.apps_rounded, Color(0xFF53677F)),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTILIA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar herramientas...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF167FF2), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 34),
                  SizedBox(width: 12),
                  Expanded(child: Text('Todo lo que necesitas\nen una sola app', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Categorías', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.08),
              itemBuilder: (_, i) {
                final c = categories[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPage(category: c))),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: c.tint.withValues(alpha: .13), borderRadius: BorderRadius.circular(20)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(c.icon, color: c.tint, size: 34),
                      const SizedBox(height: 9),
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(c.description, maxLines: 2, style: const TextStyle(fontSize: 11.5, color: Color(0xFF52606D))),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'Más'),
        ],
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.category});
  final ToolCategory category;

  List<ToolCategory> get tools {
    if (category.name == 'Dinero') {
      return const [
        ToolCategory('Porcentaje', 'Aumentos y descuentos', Icons.percent_rounded, Color(0xFF21B981)),
        ToolCategory('Descuentos', 'Precio final y ahorro', Icons.local_offer_rounded, Color(0xFFFF9D27)),
        ToolCategory('IVA', 'Añade o quita IVA', Icons.receipt_long_rounded, Color(0xFF1689E9)),
        ToolCategory('Propinas', 'Calcula la propina', Icons.restaurant_rounded, Color(0xFFFF5265)),
        ToolCategory('Préstamos', 'Cuotas e intereses', Icons.account_balance_rounded, Color(0xFF8165E8)),
        ToolCategory('Hipoteca', 'Cuota y simulación', Icons.home_rounded, Color(0xFF20A66E)),
      ];
    }
    if (category.name == 'Coche') {
      return const [
        ToolCategory('Combustible', 'Litros, coste y consumo', Icons.local_gas_station_rounded, Color(0xFF1689E9)),
        ToolCategory('Coste por km', 'Coste real del vehículo', Icons.pin_drop_rounded, Color(0xFFFF5265)),
        ToolCategory('Viaje', 'Distancia, tiempo y combustible', Icons.map_rounded, Color(0xFF20A66E)),
      ];
    }
    return const [ToolCategory('Calculadora rápida', 'Resuelve lo que necesitas', Icons.calculate_rounded, Color(0xFF1689E9)), ToolCategory('Conversor', 'Convierte unidades', Icons.swap_horiz_rounded, Color(0xFF21B981))];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(category.description, style: const TextStyle(color: Color(0xFF52606D))),
          const SizedBox(height: 14),
          ...tools.map((tool) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(backgroundColor: tool.tint.withValues(alpha: .14), child: Icon(tool.icon, color: tool.tint)),
              title: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(tool.description),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                if (tool.name == 'IVA') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const IvaPage()));
                }
              },
            ),
          )),
        ],
      ),
    );
  }
}

class IvaPage extends StatefulWidget {
  const IvaPage({super.key});

  @override
  State<IvaPage> createState() => _IvaPageState();
}

class _IvaPageState extends State<IvaPage> {
  final controller = TextEditingController(text: '100');
  double rate = 21;
  double result = 121;

  void calculate() {
    final value = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
    setState(() => result = value * (1 + rate / 100));
  }

  @override
  Widget build(BuildContext context) {
    final base = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
    final tax = result - base;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de IVA', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Añade IVA fácilmente.', style: TextStyle(color: Color(0xFF52606D))),
          const SizedBox(height: 24),
          const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(suffixText: '€', filled: true, border: OutlineInputBorder(borderSide: BorderSide.none))),
          const SizedBox(height: 18),
          const Text('Tipo de IVA', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SegmentedButton<double>(segments: const [ButtonSegment(value: 4, label: Text('4%')), ButtonSegment(value: 10, label: Text('10%')), ButtonSegment(value: 21, label: Text('21%'))], selected: {rate}, onSelectionChanged: (value) => setState(() => rate = value.first)),
          const SizedBox(height: 18),
          FilledButton(onPressed: calculate, child: const Text('Calcular')),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFE7F8F2), borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Resultado', style: TextStyle(color: Color(0xFF17865D), fontWeight: FontWeight.w800)),
              Text('${result.toStringAsFixed(2).replaceAll('.', ',')} €', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF17865D))),
              Text('Base: ${base.toStringAsFixed(2)} €'),
              Text('IVA (${rate.toInt()}%): ${tax.toStringAsFixed(2)} €'),
              Text('Total: ${result.toStringAsFixed(2)} €'),
            ]),
          ),
        ],
      ),
    );
  }
}
