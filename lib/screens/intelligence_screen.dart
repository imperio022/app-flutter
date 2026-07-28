import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class IntelligenceScreen extends ConsumerWidget {
  const IntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inteligência'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('DADOS INTELIGENTES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.primaryColor, letterSpacing: 1)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Horário de Pico', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text('9h - 11h e 14h - 16h', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 8),
          SizedBox(height: 120, child: BarChart(BarChartData(barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: Colors.blue.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: AppConstants.primaryColor.withOpacity(0.9), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: Colors.blue.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8, color: AppConstants.primaryColor.withOpacity(0.9), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 4, color: Colors.blue.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 6, color: Colors.blue.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
          ], barTouchData: BarTouchData(enabled: false), titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false), gridData: FlGridData(show: false)))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('8h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), Text('10h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), Text('12h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), Text('14h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), Text('16h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), Text('18h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10))]),
        ])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dias Mais Movimentados', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _DayStat(day: 'Seg', value: 8)), Expanded(child: _DayStat(day: 'Ter', value: 6)), Expanded(child: _DayStat(day: 'Qua', value: 5)), Expanded(child: _DayStat(day: 'Qui', value: 7)), Expanded(child: _DayStat(day: 'Sex', value: 9, highlight: true)), Expanded(child: _DayStat(day: 'Sáb', value: 12, highlight: true)), Expanded(child: _DayStat(day: 'Dom', value: 3))]),
        ])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Serviços Mais Vendidos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _ServiceStat(name: 'Lavagem Simples', count: 45, total: 100),
          const SizedBox(height: 8),
          _ServiceStat(name: 'Polimento', count: 22, total: 100),
          const SizedBox(height: 8),
          _ServiceStat(name: 'Cera', count: 18, total: 100),
          const SizedBox(height: 8),
          _ServiceStat(name: 'Lavagem Completa', count: 12, total: 100),
        ])),
      ]))),
    );
  }
}

class _DayStat extends StatelessWidget {
  final String day;
  final int value;
  final bool highlight;
  const _DayStat({required this.day, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(day, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      const SizedBox(height: 4),
      Container(width: 28, height: 28 + (value * 3), decoration: BoxDecoration(color: highlight ? AppConstants.primaryColor : Colors.blue.withOpacity(0.5), borderRadius: BorderRadius.circular(6)), alignment: Alignment.center, child: Text('$value', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
    ]);
  }
}

class _ServiceStat extends StatelessWidget {
  final String name;
  final int count;
  final int total;
  const _ServiceStat({required this.name, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Expanded(child: Text(name, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13))), Container(width: 120, height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: count / total, child: Container(decoration: BoxDecoration(color: AppConstants.primaryColor, borderRadius: BorderRadius.circular(4))))), const SizedBox(width: 8), Text('$count', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))]);
  }
}
