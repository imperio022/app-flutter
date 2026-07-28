import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class DamageScreen extends ConsumerWidget {
  const DamageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Danos'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')), actions: [IconButton(icon: const Icon(Icons.camera_alt), onPressed: () {})]),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 40, color: AppConstants.primaryColor)),
        const SizedBox(height: 16),
        Text('Fotos Antes/Depois', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        const SizedBox(height: 8),
        Text('Selecione um veículo para registrar', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => context.push('/patio'), child: const Text('Selecionar Veículo')),
      ]))),
    );
  }
}
