import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class PatioScreen extends ConsumerStatefulWidget {
  const PatioScreen({super.key});

  @override
  ConsumerState<PatioScreen> createState() => _PatioScreenState();
}

class _PatioScreenState extends ConsumerState<PatioScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadVehiclesPatio());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final vehicles = data.vehiclesPatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pátio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dataProvider).loadVehiclesPatio(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppConstants.backgroundColor, AppConstants.surfaceColor],
          ),
        ),
        child: vehicles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_parking, size: 64, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum veículo no pátio',
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/entrada'),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Entrada'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(dataProvider).loadVehiclesPatio(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleItem(vehicle: vehicle);
                  },
                ),
              ),
      ),
    );
  }
}

class _VehicleItem extends StatelessWidget {
  final dynamic vehicle;
  const _VehicleItem({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car, color: AppConstants.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (vehicle.plate ?? '').toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  vehicle.model != null ? '${vehicle.model} - ${vehicle.color ?? ''}' : vehicle.type,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                ),
                if (vehicle.clientName != null)
                  Text(
                    vehicle.clientName!,
                    style: TextStyle(fontSize: 12, color: AppConstants.primaryColor),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/saida'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SAÍDA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
