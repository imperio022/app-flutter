import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadEmployees());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final data = ref.watch(dataProvider);

    if (!auth.isAdmin) {
      return Scaffold(
        body: Container(
          color: AppConstants.backgroundColor,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock, size: 48, color: AppConstants.primaryColor),
              const SizedBox(height: 16),
              Text('Acesso restrito', style: TextStyle(color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.go('/dashboard'), child: const Text('Voltar')),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Administração'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])),
        child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('FUNCIONÁRIOS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.primaryColor, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...data.employees.map((emp) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppConstants.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), Text('Comissão: R\$ ${emp.commissionRate}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: emp.isActive == 'active' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(emp.isActive.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: emp.isActive == 'active' ? Colors.green : Colors.red))),
          ]))),
          const SizedBox(height: 24),
          Text('CONFIGURAÇÕES RÁPIDAS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.primaryColor, letterSpacing: 1)),
          const SizedBox(height: 12),
          _AdminOption(title: 'Editar Funcionário', icon: Icons.edit, onTap: () {}),
          _AdminOption(title: 'Adicionar Funcionário', icon: Icons.person_add, onTap: () {}),
          _AdminOption(title: 'Configurar Preços', icon: Icons.price_change, onTap: () {}),
          _AdminOption(title: 'Configurações do Sistema', icon: Icons.settings, onTap: () => context.push('/configuracoes')),
        ])),
      ),
    );
  }
}

class _AdminOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _AdminOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
      Icon(icon, color: AppConstants.primaryColor),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
      const Icon(Icons.chevron_right, color: Colors.white38),
    ])));
  }
}
