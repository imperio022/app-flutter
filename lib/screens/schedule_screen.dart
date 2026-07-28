import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final employees = [
      {'name': 'André', 'schedule': ['full', 'full', 'full', 'full', 'full', 'morning', 'off']},
      {'name': 'Miguel', 'schedule': ['full', 'full', 'full', 'full', 'full', 'full', 'off']},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Escala Semanal'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Icon(Icons.arrow_left, color: AppConstants.primaryColor),
          Text('Semana 28 Jul - 03 Ago', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Icon(Icons.arrow_right, color: AppConstants.primaryColor),
        ])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12)), child: Row(children: [const SizedBox(width: 60), ...days.map((d) => Expanded(child: Text(d, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))))])),
        const SizedBox(height: 8),
        ...employees.map((emp) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12)), child: Row(children: [
          SizedBox(width: 60, child: Text(emp['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          ...((emp['schedule'] as List).map((s) {
            Color c = s == 'full' ? AppConstants.primaryColor : s == 'morning' ? Colors.orange : s == 'afternoon' ? Colors.blue : Colors.grey.withOpacity(0.3);
            String label = s == 'full' ? 'I' : s == 'morning' ? 'M' : s == 'afternoon' ? 'T' : '-';
            return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 32, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)), alignment: Alignment.center, child: Text(label, style: TextStyle(color: s == 'off' ? Colors.grey : Colors.white, fontSize: 12, fontWeight: FontWeight.bold))));
          }))),
        ]))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Legend(color: AppConstants.primaryColor, label: 'Dia Inteiro'),
          const SizedBox(width: 12),
          _Legend(color: Colors.orange, label: 'Manhã'),
          const SizedBox(width: 12),
          _Legend(color: Colors.blue, label: 'Tarde'),
          const SizedBox(width: 12),
          _Legend(color: Colors.grey, label: 'Folga'),
        ]),
      ]))),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 4), Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))]);
  }
}
