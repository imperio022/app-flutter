import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: ListView(padding: const EdgeInsets.all(16), children: [
        // User Info
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.person, color: AppConstants.primaryColor)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(auth.user?.name ?? 'Usuário', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), Text(auth.user?.role ?? 'employee', style: TextStyle(color: AppConstants.primaryColor, fontSize: 12))])),
        ])),
        const SizedBox(height: 16),
        _SettingsItem(icon: Icons.person_edit, title: 'Editar Perfil', onTap: () {}),
        _SettingsItem(icon: Icons.notifications, title: 'Notificações', onTap: () {}),
        _SettingsItem(icon: Icons.cloud, title: 'Sincronização', onTap: () => context.push('/offline')),
        _SettingsItem(icon: Icons.info, title: 'Sobre o App', onTap: () {}),
        _SettingsItem(icon: Icons.help, title: 'Ajuda', onTap: () {}),
        const SizedBox(height: 24),
        SizedBox(height: 48, child: ElevatedButton(onPressed: () { ref.read(authProvider).logout(); context.go('/login'); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('SAIR', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)))),
      ])),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12)), child: Row(children: [
      Icon(icon, color: AppConstants.primaryColor, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
      const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
    ])));
  }
}
