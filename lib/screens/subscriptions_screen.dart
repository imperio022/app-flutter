import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assinaturas'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})]),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: ListView(padding: const EdgeInsets.all(16), children: [
        _PlanCard(plan: 'Básico', washes: 4, price: 120, used: 2, color: Colors.blue),
        const SizedBox(height: 12),
        _PlanCard(plan: 'Premium', washes: 8, price: 220, used: 5, color: AppConstants.primaryColor),
        const SizedBox(height: 12),
        _PlanCard(plan: 'VIP', washes: 15, price: 380, used: 15, color: Colors.amber),
      ])),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String plan;
  final int washes, price, used;
  final Color color;
  const _PlanCard({required this.plan, required this.washes, required this.price, required this.used, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = washes > 0 ? used / washes : 0.0;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(plan, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text('R\$ $price/mês', style: const TextStyle(color: Colors.white, fontSize: 14))]),
      const SizedBox(height: 12),
      Text('Lavagens: $used / $washes', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color)),
    ]));
  }
}
