import 'dart:math' as math;
import 'package:flutter/material.dart';

class CalculatorSuitePage extends StatefulWidget {
  const CalculatorSuitePage({super.key, this.scientific = false});
  final bool scientific;
  @override State<CalculatorSuitePage> createState() => _CalculatorSuitePageState();
}

class _CalculatorSuitePageState extends State<CalculatorSuitePage> {
  late bool scientific;
  String expression = '';
  String result = '0';
  bool degrees = true;
  @override void initState(){super.initState(); scientific=widget.scientific;}

  void key(String v){setState((){ if(v=='C'){expression='';result='0';}else if(v=='⌫'){if(expression.isNotEmpty)expression=expression.substring(0,expression.length-1);}else if(v=='='){try{result=_format(CalculatorParser(expression, degrees:degrees).parse());}catch(_){result='Error';}}else if(v=='±'){if(expression.startsWith('-'))expression=expression.substring(1);else expression='-$expression';}else{expression+=v;} });}
  String _format(double x){if(!x.isFinite)return 'Error';if((x-x.roundToDouble()).abs()<1e-10)return x.round().toString();return x.toStringAsPrecision(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'),'');}
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Calculadora',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(tooltip:'Científica',onPressed:()=>setState(()=>scientific=!scientific),icon:Icon(scientific?Icons.calculate:Icons.functions))]),body:Column(children:[Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(20,20,20,14),child:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[SingleChildScrollView(scrollDirection:Axis.horizontal,reverse:true,child:Text(expression.isEmpty?'0':expression,style:const TextStyle(fontSize:22))),const SizedBox(height:8),SingleChildScrollView(scrollDirection:Axis.horizontal,reverse:true,child:Text(result,style:const TextStyle(fontSize:38,fontWeight:FontWeight.w900)))])),if(scientific)Padding(padding:const EdgeInsets.symmetric(horizontal:8),child:Row(children:[_small('sin(', 'sin'),_small('cos(', 'cos'),_small('tan(', 'tan'),_small('ln(', 'ln'),_small('log(', 'log'),_small('√(', '√'),_small('π','π')])),if(scientific)Padding(padding:const EdgeInsets.symmetric(horizontal:8),child:Row(children:[_small('x²','x²'),_small('^','^'),_small('1/','1/'),_small('!','!'),_small('e','e'),_small(degrees?'DEG':'RAD','mode')])),Expanded(child:GridView.count(crossAxisCount:4,padding:const EdgeInsets.all(10),mainAxisSpacing:8,crossAxisSpacing:8,children:['C','⌫','(',')','7','8','9','÷','4','5','6','×','1','2','3','−','±','0',',','+','='].map((v)=>_key(v)).toList()))]);
  Widget _small(String label,String v)=>Expanded(child:Padding(padding:const EdgeInsets.all(3),child:OutlinedButton(onPressed:()=>v=='mode'?setState(()=>degrees=!degrees):key(v),child:FittedBox(child:Text(label)))));
  Widget _key(String v)=>FilledButton(onPressed:()=>key(v),style:FilledButton.styleFrom(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),child:Text(v,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w700)));
}

class CalculatorParser{
  CalculatorParser(this.s,{this.degrees=true}); final String s; final bool degrees;
  int p=0;
  double parse(){p=0;final v=_expr();_skip();if(p<s.length)throw FormatException('syntax');return v;}
  void _skip(){while(p<s.length&&s[p]==' ')p++;}
  bool _eat(String x){_skip();if(s.startsWith(x,p)){p+=x.length;return true;}return false;}
  double _expr(){var v=_term();while(true){if(_eat('+'))v+=_term();else if(_eat('−')||_eat('-'))v-=_term();else return v;}}
  double _term(){var v=_power();while(true){if(_eat('×')||_eat('*'))v*=_power();else if(_eat('÷')||_eat('/'))v/=_power();else return v;}}
  double _power(){var v=_unary();if(_eat('^'))v=math.pow(v,_power()).toDouble();return v;}
  double _unary(){_skip();if(_eat('±'))return -_unary();if(_eat('-'))return -_unary();return _primary();}
  double _primary(){_skip();if(_eat('(')){final v=_expr();if(!_eat(')'))throw FormatException(')');return v;}
    for(final f in ['sin(','cos(','tan(','ln(','log(','√(']){if(_eat(f)){final x=_expr();if(!_eat(')'))throw FormatException(')');return _fn(f.substring(0,f.length-1),x);}}
    if(_eat('π'))return math.pi;if(_eat('e'))return math.e;
    final start=p;while(p<s.length&&RegExp(r'[0-9.,]').hasMatch(s[p]))p++;if(start==p)throw FormatException('number');var v=double.parse(s.substring(start,p).replaceAll(',','.'));if(_eat('!')){v=_fact(v);}return v;}
  double _fn(String f,double x){if(f=='sin')return math.sin(degrees?x*math.pi/180:x);if(f=='cos')return math.cos(degrees?x*math.pi/180:x);if(f=='tan')return math.tan(degrees?x*math.pi/180:x);if(f=='ln')return math.log(x);if(f=='log')return math.log(x)/math.ln10;return math.sqrt(x);}
  double _fact(double x){if(x<0||x>170||x!=x.roundToDouble())throw FormatException('factorial');var r=1.0;for(var i=2;i<=x;i++)r*=i;return r;}
}