import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});
  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(dataProvider).loadEmployees()); }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Desempenho'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: data.employees.isEmpty ? Center(child: Text('Nenhum funcionário', style: TextStyle(color: Colors.white.withOpacity(0.4)))) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: data.employees.length, itemBuilder: (context, index) {
        final emp = data.employees[index];
        return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(emp.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: emp.isActive == 'active' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(emp.isActive.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: emp.isActive == 'active' ? Colors.green : Colors.red)))]),
          const SizedBox(height: 12),
          Row(children: [_MetricBox(label: 'Lavagens', value: '23'), _MetricBox(label: 'Média', value: '18min'), _MetricBox(label: 'Avaliação', value: '4.8')]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: 0.78, backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(Color(0xFFE31837))),
          Text('Meta: 78% concluída', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ]));
      })),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label, value;
  const _MetricBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(value, style: const TextStyle(color: AppConstants.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)), Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10))])));
  }
}
