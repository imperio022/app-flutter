import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Offline'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.cloud_off, size: 40, color: Colors.orange)),
        const SizedBox(height: 16),
        Text('Modo Offline Ativo', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 8),
        Text('Dados salvos localmente', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12)), child: Column(children: [
          Text('Sincronização', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 8),
          Text('Pendentes: 0', style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.sync), label: const Text('Sincronizar Agora')),
      ]))),
    );
  }
}
