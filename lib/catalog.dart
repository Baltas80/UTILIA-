import 'package:flutter/material.dart';
import 'models/tool.dart';

const categories = <String>['Dinero', 'Tiempo', 'Casa', 'Coche', 'Conversores', 'Salud', 'Estudio', 'Varios'];

const categoryTints = <String, Color>{
  'Dinero': Color(0xFF167FF2),
  'Tiempo': Color(0xFF7C4DFF),
  'Casa': Color(0xFFFF8A00),
  'Coche': Color(0xFF00A67E),
  'Conversores': Color(0xFF00838F),
  'Salud': Color(0xFFE53935),
  'Estudio': Color(0xFF6D4C41),
  'Varios': Color(0xFF546E7A),
};

const tools = <UtiliaTool>[
  UtiliaTool(name: 'Porcentaje', description: 'Calcula un porcentaje de una cantidad.', category: 'Dinero', icon: Icons.percent, tint: Color(0xFF167FF2), type: ToolType.percentage),
  UtiliaTool(name: 'Descuentos', description: 'Calcula el precio final con descuento.', category: 'Dinero', icon: Icons.sell_outlined, tint: Color(0xFF167FF2), type: ToolType.discount),
  UtiliaTool(name: 'IVA', description: 'Añade IVA a una cantidad.', category: 'Dinero', icon: Icons.receipt_long_outlined, tint: Color(0xFF167FF2), type: ToolType.iva),
  UtiliaTool(name: 'Propinas', description: 'Calcula propina y reparto por persona.', category: 'Dinero', icon: Icons.restaurant_outlined, tint: Color(0xFF167FF2), type: ToolType.tip),
  UtiliaTool(name: 'Préstamos', description: 'Estima la cuota mensual de un préstamo.', category: 'Dinero', icon: Icons.account_balance_outlined, tint: Color(0xFF167FF2), type: ToolType.loan),
  UtiliaTool(name: 'Interés compuesto', description: 'Calcula el crecimiento de un capital.', category: 'Dinero', icon: Icons.trending_up, tint: Color(0xFF167FF2), type: ToolType.compoundInterest),
  UtiliaTool(name: 'Edad', description: 'Calcula la edad a partir de una fecha.', category: 'Tiempo', icon: Icons.cake_outlined, tint: Color(0xFF7C4DFF), type: ToolType.age),
  UtiliaTool(name: 'Diferencia de fechas', description: 'Calcula el tiempo entre dos fechas.', category: 'Tiempo', icon: Icons.date_range_outlined, tint: Color(0xFF7C4DFF), type: ToolType.dateDifference),
  UtiliaTool(name: 'Horas trabajadas', description: 'Calcula horas entre entrada y salida.', category: 'Tiempo', icon: Icons.schedule, tint: Color(0xFF7C4DFF), type: ToolType.workHours),
  UtiliaTool(name: 'Cuenta atrás', description: 'Calcula el tiempo restante hasta una fecha.', category: 'Tiempo', icon: Icons.timer_outlined, tint: Color(0xFF7C4DFF), type: ToolType.countdown),
  UtiliaTool(name: 'Superficie', description: 'Calcula el área de una superficie rectangular.', category: 'Casa', icon: Icons.square_foot, tint: Color(0xFFFF8A00), type: ToolType.area),
  UtiliaTool(name: 'Pintura', description: 'Estima litros de pintura necesarios.', category: 'Casa', icon: Icons.format_paint, tint: Color(0xFFFF8A00), type: ToolType.paint),
  UtiliaTool(name: 'Consumo eléctrico', description: 'Estima el coste de electricidad.', category: 'Casa', icon: Icons.bolt_outlined, tint: Color(0xFFFF8A00), type: ToolType.electricity),
  UtiliaTool(name: 'Combustible', description: 'Calcula litros y coste de combustible.', category: 'Coche', icon: Icons.local_gas_station_outlined, tint: Color(0xFF00A67E), type: ToolType.fuel),
  UtiliaTool(name: 'Coste por km', description: 'Calcula cuánto cuesta cada kilómetro.', category: 'Coche', icon: Icons.route_outlined, tint: Color(0xFF00A67E), type: ToolType.costPerKm),
  UtiliaTool(name: 'Conversor de longitud', description: 'Convierte unidades de longitud.', category: 'Conversores', icon: Icons.straighten_outlined, tint: Color(0xFF00838F), type: ToolType.length),
  UtiliaTool(name: 'Conversor de peso', description: 'Convierte unidades de peso.', category: 'Conversores', icon: Icons.scale_outlined, tint: Color(0xFF00838F), type: ToolType.weight),
  UtiliaTool(name: 'IMC', description: 'Calcula el índice de masa corporal.', category: 'Salud', icon: Icons.monitor_weight_outlined, tint: Color(0xFFE53935), type: ToolType.bmi),
  UtiliaTool(name: 'Media de notas', description: 'Calcula la media de varias notas.', category: 'Estudio', icon: Icons.school_outlined, tint: Color(0xFF6D4C41), type: ToolType.gradeAverage),
  UtiliaTool(name: 'Regla de tres', description: 'Resuelve una regla de tres simple.', category: 'Varios', icon: Icons.calculate_outlined, tint: Color(0xFF546E7A), type: ToolType.ruleOfThree),
];
