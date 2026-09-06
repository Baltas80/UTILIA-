import 'package:flutter/material.dart';

enum ToolType { percentage, discount, iva, tip, loan, compoundInterest, age, dateDifference, workHours, countdown, area, paint, electricity, fuel, costPerKm, length, weight, bmi, gradeAverage, ruleOfThree, calculator, scientificCalculator }

class UtiliaTool {
  const UtiliaTool({required this.name, required this.description, required this.category, required this.icon, required this.tint, required this.type});
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final Color tint;
  final ToolType type;
}
