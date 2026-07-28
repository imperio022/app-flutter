import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () {})]),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.wb_cloudy_outlined, size: 64, color: Colors.white.withOpacity(0.6)),
        const SizedBox(height: 16),
        Text('Saquarema, RJ', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 8),
        Text('28°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
        const SizedBox(height: 8),
        Text('Parcialmente nublado', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5))),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _WeatherStat(icon: Icons.water_drop, value: '65%', label: 'Umidade'),
          const SizedBox(width: 32),
          _WeatherStat(icon: Icons.water, value: '20%', label: 'Chuva'),
        ]),
        const SizedBox(height: 32),
        Text('Previsão da semana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _ForecastDay(day: 'Seg', icon: Icons.wb_sunny, temp: '30°'),
          _ForecastDay(day: 'Ter', icon: Icons.cloud, temp: '27°'),
          _ForecastDay(day: 'Qua', icon: Icons.wb_cloudy, temp: '26°'),
          _ForecastDay(day: 'Qui', icon: Icons.wb_sunny, temp: '29°'),
          _ForecastDay(day: 'Sex', icon: Icons.cloud, temp: '28°'),
          _ForecastDay(day: 'Sáb', icon: Icons.wb_sunny, temp: '31°'),
          _ForecastDay(day: 'Dom', icon: Icons.wb_cloudy, temp: '27°'),
        ])),
      ]))),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _WeatherStat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Icon(icon, color: AppConstants.primaryColor, size: 28), const SizedBox(height: 4), Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11))]);
  }
}

class _ForecastDay extends StatelessWidget {
  final String day, temp;
  final IconData icon;
  const _ForecastDay({required this.day, required this.icon, required this.temp});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(day, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)), Icon(icon, size: 24, color: Colors.white.withOpacity(0.6)), Text(temp, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))]);
  }
}
