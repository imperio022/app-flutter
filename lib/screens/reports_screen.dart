import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAdmin) return _AccessDenied(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('RELATÓRIOS DISPONÍVEIS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.primaryColor, letterSpacing: 1)),
        const SizedBox(height: 16),
        _ReportCard(title: 'Receita Diária', subtitle: 'Receita detalhada por dia', icon: Icons.today, onTap: () {}),
        _ReportCard(title: 'Receita Semanal', subtitle: 'Resumo da semana', icon: Icons.date_range, onTap: () {}),
        _ReportCard(title: 'Receita Mensal', subtitle: 'Resumo do mês', icon: Icons.calendar_month, onTap: () {}),
        _ReportCard(title: 'Serviços Mais Vendidos', subtitle: 'Top serviços', icon: Icons.trending_up, onTap: () {}),
        _ReportCard(title: 'Desempenho por Funcionário', subtitle: 'Lavagens e avaliações', icon: Icons.people, onTap: () {}),
        _ReportCard(title: 'Fluxo de Caixa', subtitle: 'Entradas e saídas', icon: Icons.account_balance, onTap: () {}),
        _ReportCard(title: 'Clientes Mais Frequentes', subtitle: 'Fidelidade e frequência', icon: Icons.star, onTap: () {}),
        const SizedBox(height: 16),
        SizedBox(height: 48, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('EXPORTAR PDF'), style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]))),
    );
  }

  Widget _AccessDenied(BuildContext context) {
    return Scaffold(body: Container(color: AppConstants.backgroundColor, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.lock, size: 48, color: AppConstants.primaryColor), const SizedBox(height: 16), Text('Acesso restrito ao administrador', style: TextStyle(color: Colors.white.withOpacity(0.6))), ElevatedButton(onPressed: () => context.go('/dashboard'), child: const Text('Voltar'))]))));
  }
}

class _ReportCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ReportCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppConstants.primaryColor)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11))])),
      const Icon(Icons.download, color: Colors.white38),
    ])));
  }
}
