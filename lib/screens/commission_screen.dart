import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class CommissionScreen extends ConsumerStatefulWidget {
  const CommissionScreen({super.key});

  @override
  ConsumerState<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends ConsumerState<CommissionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadCommissions());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final commissions = data.commissions;
    final totalPending = commissions.where((c) => c.isPaid == 'no').fold(0.0, (sum, c) => sum + c.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comissões'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(dataProvider).loadCommissions()),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])),
        child: Column(
          children: [
            // Total Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3))),
              child: Column(
                children: [
                  Text('PENDENTE (SÁBADO)', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                  const SizedBox(height: 8),
                  Text('R\$ ${totalPending.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Commission List
            Expanded(
              child: commissions.isEmpty
                  ? Center(child: Text('Nenhuma comissão registrada', style: TextStyle(color: Colors.white.withOpacity(0.4))))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: commissions.length,
                      itemBuilder: (context, index) {
                        final commission = commissions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                          child: Row(
                            children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(commission.serviceDescription ?? 'Serviço', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                Text('R\$ ${commission.amount.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: commission.isPaid == 'yes' ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(commission.isPaid == 'yes' ? 'PAGO' : 'PENDENTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: commission.isPaid == 'yes' ? Colors.green : Colors.orange)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
