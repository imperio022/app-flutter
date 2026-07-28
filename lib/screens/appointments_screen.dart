import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(dataProvider).loadAppointments()); }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})]),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: data.appointments.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_note, size: 48, color: Colors.white.withOpacity(0.2)), const SizedBox(height: 8), Text('Nenhum agendamento', style: TextStyle(color: Colors.white.withOpacity(0.4)))])) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: data.appointments.length, itemBuilder: (context, index) {
        final appt = data.appointments[index];
        return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.event, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appt.clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), Text('${appt.plate.toUpperCase()} • ${appt.serviceType}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(appt.date, style: const TextStyle(color: Colors.white, fontSize: 12)), Text(appt.time, style: TextStyle(color: AppConstants.primaryColor, fontSize: 11, fontWeight: FontWeight.w600))]),
        ]));
      })),
    );
  }
}
