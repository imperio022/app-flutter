import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class QualityScreen extends ConsumerWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist Qualidade'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('CHECKLIST DE QUALIDADE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.primaryColor, letterSpacing: 1)),
        const SizedBox(height: 16),
        _QualityItem(title: 'Exterior', icon: Icons.local_car_wash, status: 'pending'),
        _QualityItem(title: 'Interior', icon: Icons.chair, status: 'pending'),
        _QualityItem(title: 'Rodas', icon: Icons.circle, status: 'pending'),
        _QualityItem(title: 'Motor', icon: Icons.settings, status: 'skip'),
        _QualityItem(title: 'Couro', icon: Icons.style, status: 'skip'),
        _QualityItem(title: 'Polimento', icon: Icons.auto_awesome, status: 'skip'),
        _QualityItem(title: 'Fragrância', icon: Icons.air, status: 'pending'),
        const SizedBox(height: 24),
        SizedBox(height: 48, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('FINALIZAR CHECKLIST', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)))),
      ]))),
    );
  }
}

class _QualityItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String status;
  const _QualityItem({required this.title, required this.icon, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'done' ? Colors.green : status == 'skip' ? Colors.grey : Colors.orange;
    String statusLabel = status == 'done' ? 'FEITO' : status == 'skip' ? 'PULAR' : 'PENDENTE';
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
      Icon(icon, color: AppConstants.primaryColor),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
    ]));
  }
}
