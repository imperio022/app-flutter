import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});
  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(dataProvider).loadInventory()); }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final items = data.inventory;
    final lowStock = items.where((i) => i.isLowStock).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Estoque'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})]),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppConstants.backgroundColor, AppConstants.surfaceColor])), child: Column(children: [
        if (lowStock > 0) Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))), child: Row(children: [const Icon(Icons.warning, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text('$lowStock item(ns) com estoque baixo', style: const TextStyle(color: Colors.red, fontSize: 13)))])),
        Expanded(child: items.isEmpty ? Center(child: Text('Nenhum item no estoque', style: TextStyle(color: Colors.white.withOpacity(0.4)))) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (context, index) {
          final item = items[index];
          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppConstants.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: item.isLowStock ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1))), child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: (item.isLowStock ? Colors.red : AppConstants.primaryColor).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(item.isLowStock ? Icons.warning : Icons.inventory_2, color: item.isLowStock ? Colors.red : AppConstants.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), Text('${item.category} • R\$ ${item.unitPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))])),
            Column(children: [Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: item.isLowStock ? Colors.red : Colors.white)), Text('min: ${item.minStock}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10))]),
          ]));
        })),
      ])),
    );
  }
}
