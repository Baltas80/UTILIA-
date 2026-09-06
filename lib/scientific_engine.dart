import 'dart:math' as math;

/// Lightweight, dependency-free scientific expression evaluator for UTILIA.
/// Supports +, -, *, /, ^, parentheses, constants, and common trig/log functions.
class ScientificEngine {
  static double evaluate(String input, {bool degrees = true}) {
    final parser = _Parser(input, degrees);
    final value = parser.parse();
    if (!value.isFinite) throw const FormatException('Resultado no válido');
    return value;
  }
}

class _Parser {
  _Parser(this.source, this.degrees);
  final String source;
  final bool degrees;
  int pos = 0;

  double parse() {
    final v = _expression();
    _skip();
    if (pos != source.length) throw const FormatException('Expresión no válida');
    return v;
  }

  double _expression() {
    var v = _term();
    while (true) {
      _skip();
      if (_match('+')) v += _term();
      else if (_match('-')) v -= _term();
      else return v;
    }
  }

  double _term() {
    var v = _power();
    while (true) {
      _skip();
      if (_match('*')) v *= _power();
      else if (_match('/')) {
        final d = _power();
        if (d == 0) throw const FormatException('No se puede dividir entre cero');
        v /= d;
      } else return v;
    }
  }

  double _power() {
    var v = _unary();
    _skip();
    if (_match('^')) v = math.pow(v, _power()).toDouble();
    return v;
  }

  double _unary() {
    _skip();
    if (_match('+')) return _unary();
    if (_match('-')) return -_unary();
    return _primary();
  }

  double _primary() {
    _skip();
    if (_match('(')) {
      final v = _expression();
      if (!_match(')')) throw const FormatException('Falta )');
      return v;
    }
    final start = pos;
    while (pos < source.length && RegExp(r'[0-9.,]').hasMatch(source[pos])) pos++;
    if (start != pos) {
      final text = source.substring(start, pos).replaceAll(',', '.');
      return double.parse(text);
    }
    final nameStart = pos;
    while (pos < source.length && RegExp(r'[A-Za-z]').hasMatch(source[pos])) pos++;
    if (nameStart == pos) throw const FormatException('Expresión no válida');
    final name = source.substring(nameStart, pos).toLowerCase();
    _skip();
    if (name == 'pi') return math.pi;
    if (name == 'e') return math.e;
    if (!_match('(')) throw const FormatException('Falta (');
    final x = _expression();
    if (!_match(')')) throw const FormatException('Falta )');
    switch (name) {
      case 'sin': return math.sin(_angle(x));
      case 'cos': return math.cos(_angle(x));
      case 'tan': return math.tan(_angle(x));
      case 'asin': return _outAngle(math.asin(x));
      case 'acos': return _outAngle(math.acos(x));
      case 'atan': return _outAngle(math.atan(x));
      case 'sqrt': return math.sqrt(x);
      case 'ln': return math.log(x);
      case 'log': return math.log(x) / math.ln10;
      case 'abs': return x.abs();
      case 'exp': return math.exp(x);
      case 'floor': return x.floorToDouble();
      case 'ceil': return x.ceilToDouble();
      default: throw FormatException('Función desconocida: $name');
    }
  }

  double _angle(double x) => degrees ? x * math.pi / 180 : x;
  double _outAngle(double x) => degrees ? x * 180 / math.pi : x;
  void _skip() { while (pos < source.length && source[pos].trim().isEmpty) pos++; }
  bool _match(String c) { _skip(); if (source.startsWith(c, pos)) { pos += c.length; return true; } return false; }
}
