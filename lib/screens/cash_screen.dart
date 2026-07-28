import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class CashScreen extends ConsumerStatefulWidget {
  const CashScreen({super.key});

  @override
  ConsumerState<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final transactions = data.transactions;
    final income = transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Caixa'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(16)), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('RECEITA', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))), Text('R\$ ${income.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green))]),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                Column(children: [Text('DESPESA', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))), Text('R\$ ${expense.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red))]),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                Column(children: [Text('SALDO', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))), Text('R\$ ${(income - expense).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryColor))]),
              ],
            )),
            Expanded(child: transactions.isEmpty ? Center(child: Text('Nenhuma transação', style: TextStyle(color: Colors.white.withOpacity(0.4)))) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: transactions.length, itemBuilder: (context, index) {
              final t = transactions[index];
              return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: t.type == 'income' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(t.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward, color: t.type == 'income' ? Colors.green : Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), Text(t.method.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))])),
                Text('R\$ ${t.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.type == 'income' ? Colors.green : Colors.red)),
              ]));
            })),
          ],
        ),
      ),
    );
  }
}
