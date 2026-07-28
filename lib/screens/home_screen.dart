import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.backgroundColor,
              AppConstants.surfaceColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IMPÉRIO 022',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Sistema de Gestão Automotiva',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.primaryColor.withOpacity(0.15),
                        border: Border.all(color: AppConstants.primaryColor),
                      ),
                      child: const Icon(
                        Icons.car_rental,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Action Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _ActionCard(
                        title: 'ENTRADA',
                        icon: Icons.add_circle_outline,
                        color: AppConstants.primaryColor,
                        onTap: () => context.push('/entrada'),
                      ),
                      _ActionCard(
                        title: 'PÁTIO',
                        icon: Icons.local_parking,
                        color: Colors.blue,
                        onTap: () => context.push('/patio'),
                      ),
                      _ActionCard(
                        title: 'SAÍDA',
                        icon: Icons.exit_to_app,
                        color: Colors.green,
                        onTap: () => context.push('/saida'),
                      ),
                      _ActionCard(
                        title: 'DASHBOARD',
                        icon: Icons.dashboard,
                        color: Colors.orange,
                        onTap: () => context.push('/dashboard'),
                      ),
                      _ActionCard(
                        title: 'CLIENTES',
                        icon: Icons.people_outline,
                        color: Colors.purple,
                        onTap: () => context.push('/clientes'),
                      ),
                      _ActionCard(
                        title: 'CAIXA',
                        icon: Icons.account_balance_wallet,
                        color: Colors.teal,
                        onTap: () => context.push('/caixa'),
                      ),
                      _ActionCard(
                        title: 'COMISSÕES',
                        icon: Icons.payments,
                        color: Colors.amber,
                        onTap: () => context.push('/comissoes'),
                      ),
                      _ActionCard(
                        title: 'INTELIGÊNCIA',
                        icon: Icons.analytics,
                        color: Colors.pink,
                        onTap: () => context.push('/inteligencia'),
                      ),
                      _ActionCard(
                        title: 'ESTOQUE',
                        icon: Icons.inventory_2_outlined,
                        color: Colors.indigo,
                        onTap: () => context.push('/estoque'),
                      ),
                      _ActionCard(
                        title: 'AGENDAMENTOS',
                        icon: Icons.event_note,
                        color: Colors.cyan,
                        onTap: () => context.push('/agendamentos'),
                      ),
                      _ActionCard(
                        title: 'DANOS',
                        icon: Icons.camera_alt_outlined,
                        color: Colors.redAccent,
                        onTap: () => context.push('/danos'),
                      ),
                      _ActionCard(
                        title: 'QUALIDADE',
                        icon: Icons.check_circle_outline,
                        color: Colors.lightGreen,
                        onTap: () => context.push('/qualidade'),
                      ),
                      _ActionCard(
                        title: 'DESEMPENHO',
                        icon: Icons.trending_up,
                        color: Colors.deepPurple,
                        onTap: () => context.push('/desempenho'),
                      ),
                      _ActionCard(
                        title: 'ASSINATURAS',
                        icon: Icons.card_membership,
                        color: Colors.brown,
                        onTap: () => context.push('/assinaturas'),
                      ),
                      _ActionCard(
                        title: 'ESCALA',
                        icon: Icons.calendar_month,
                        color: Colors.blueGrey,
                        onTap: () => context.push('/escala'),
                      ),
                      _ActionCard(
                        title: 'CLIMA',
                        icon: Icons.wb_cloudy_outlined,
                        color: Colors.lightBlue,
                        onTap: () => context.push('/clima'),
                      ),
                      _ActionCard(
                        title: 'FINANCEIRO',
                        icon: Icons.monetization_on,
                        color: Colors.lime,
                        onTap: () => context.push('/financeiro'),
                      ),
                      _ActionCard(
                        title: 'CONFIG',
                        icon: Icons.settings_outlined,
                        color: Colors.grey,
                        onTap: () => context.push('/configuracoes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
