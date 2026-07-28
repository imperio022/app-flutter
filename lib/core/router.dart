import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/entry_screen.dart';
import '../screens/patio_screen.dart';
import '../screens/exit_screen.dart';
import '../screens/commission_screen.dart';
import '../screens/cash_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/intelligence_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/damage_screen.dart';
import '../screens/quality_screen.dart';
import '../screens/performance_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/weather_screen.dart';
import '../screens/offline_screen.dart';
import '../screens/finance_screen.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      // Auth validation is handled by login screen navigation
      // This avoids BuildContext issues with Riverpod in GoRouter
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/entrada',
        builder: (context, state) => const EntryScreen(),
      ),
      GoRoute(
        path: '/patio',
        builder: (context, state) => const PatioScreen(),
      ),
      GoRoute(
        path: '/saida',
        builder: (context, state) => const ExitScreen(),
      ),
      GoRoute(
        path: '/comissoes',
        builder: (context, state) => const CommissionScreen(),
      ),
      GoRoute(
        path: '/caixa',
        builder: (context, state) => const CashScreen(),
      ),
      GoRoute(
        path: '/clientes',
        builder: (context, state) => const ClientsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/relatorios',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/inteligencia',
        builder: (context, state) => const IntelligenceScreen(),
      ),
      GoRoute(
        path: '/estoque',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/agendamentos',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/danos',
        builder: (context, state) => const DamageScreen(),
      ),
      GoRoute(
        path: '/qualidade',
        builder: (context, state) => const QualityScreen(),
      ),
      GoRoute(
        path: '/desempenho',
        builder: (context, state) => const PerformanceScreen(),
      ),
      GoRoute(
        path: '/assinaturas',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/escala',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/clima',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: '/offline',
        builder: (context, state) => const OfflineScreen(),
      ),
      GoRoute(
        path: '/financeiro',
        builder: (context, state) => const FinanceScreen(),
      ),
      GoRoute(
        path: '/configuracoes',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
