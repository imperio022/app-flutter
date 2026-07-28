import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});
  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final transactions = data.transactions;
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppConstants.backgroundColor, AppConstants.surfaceColor],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('RECEITA',
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                        Text('R\$ ${income.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                    Column(
                      children: [
                        Text('DESPESA',
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                        Text('R\$ ${expense.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                    Column(
                      children: [
                        Text('SALDO',
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                        Text('R\$ ${(income - expense).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('MÉTODO DE PAGAMENTO',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.primaryColor, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text('PIX', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                          Text('R\$ ${(income * 0.6).toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('60%', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text('DINHEIRO', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                          Text('R\$ ${(income * 0.4).toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('40%', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
