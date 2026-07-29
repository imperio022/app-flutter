import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/api_service.dart';
import '../providers/data_provider.dart';

class ExitScreen extends ConsumerStatefulWidget {
  const ExitScreen({super.key});

  @override
  ConsumerState<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends ConsumerState<ExitScreen> {
  int? _selectedVehicleId;
  String _paymentMethod = 'pix'; // 'pix' or 'cash'
  double _totalValue = 0;
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;
  bool _generateReceipt = true;
  bool _requestEvaluation = true;
  bool _sendWhatsApp = true;

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadVehiclesPatio());
  }

  Future<void> _onVehicleSelected(int vehicleId) async {
    setState(() {
      _selectedVehicleId = vehicleId;
      _isLoading = true;
    });

    try {
      // Buscar serviços do veículo
      final response = await _api.getServices(vehicleId);
      final services = List<Map<String, dynamic>>.from(response);
      double total = 0;
      for (final s in services) {
        total += double.tryParse(s['value']?.toString() ?? '0') ?? 0;
      }
      setState(() {
        _services = services;
        _totalValue = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExit() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um veículo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = ref.read(dataProvider);

      // 1. Atualizar status do veículo para completed com exitDate
      await data.updateVehicle(_selectedVehicleId!, {
        'status': 'completed',
        'exitDate': DateTime.now().toIso8601String(),
      });

      // 2. Criar transação de receita
      await data.createTransaction({
        'type': 'income',
        'method': _paymentMethod,
        'description': 'Saída - ${_paymentMethod.toUpperCase()}',
        'amount': _totalValue.toStringAsFixed(2),
        'vehicleId': _selectedVehicleId,
      });

      // 3. Atualizar comissões para "paid" (se aplicável)
      // O backend já gerencia isso automaticamente

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saída registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar saída: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final vehicles = data.vehiclesPatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saída'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Selection
              Text('VEÍCULO', style: _sectionTitleStyle),
              const SizedBox(height: 12),
              if (vehicles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Nenhum veículo no pátio',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedVehicleId,
                      hint: const Text('Selecione o veículo', style: TextStyle(color: Colors.white54)),
                      dropdownColor: AppConstants.surfaceColor,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      onChanged: _isLoading ? null : (value) {
                        if (value != null) _onVehicleSelected(value);
                      },
                      items: vehicles.map((v) {
                        return DropdownMenuItem<int>(
                          value: v.id,
                          child: Text('${v.plate.toUpperCase()} - ${v.clientName ?? "Sem cliente"}'),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // Serviços do veículo
              if (_selectedVehicleId != null) ...[
                const SizedBox(height: 20),
                Text('SERVIÇOS', style: _sectionTitleStyle),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_services.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Nenhum serviço registrado',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  ..._services.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s['description']?.toString() ?? 'Serviço',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        Text(
                          'R\$ ${double.tryParse(s['value']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),

                const SizedBox(height: 20),
                // Total
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'TOTAL: ',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      Text(
                        'R\$ ${_totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Text('PAGAMENTO', style: _sectionTitleStyle),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PaymentOption(
                      method: 'pix',
                      icon: Icons.qr_code,
                      label: 'PIX',
                      selected: _paymentMethod == 'pix',
                      onTap: () => setState(() => _paymentMethod = 'pix'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaymentOption(
                      method: 'cash',
                      icon: Icons.money,
                      label: 'DINHEIRO',
                      selected: _paymentMethod == 'cash',
                      onTap: () => setState(() => _paymentMethod = 'cash'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text('OPÇÕES DE SAÍDA', style: _sectionTitleStyle),
              const SizedBox(height: 12),
              _OptionSwitch(
                title: 'Gerar Recibo PDF',
                value: _generateReceipt,
                onChanged: (v) => setState(() => _generateReceipt = v),
              ),
              _OptionSwitch(
                title: 'Solicitar Avaliação',
                value: _requestEvaluation,
                onChanged: (v) => setState(() => _requestEvaluation = v),
              ),
              _OptionSwitch(
                title: 'Enviar WhatsApp',
                value: _sendWhatsApp,
                onChanged: (v) => setState(() => _sendWhatsApp = v),
              ),

              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'REGISTRAR SAÍDA',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _sectionTitleStyle => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppConstants.primaryColor,
    letterSpacing: 1,
  );
}

class _PaymentOption extends StatelessWidget {
  final String method;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.method,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppConstants.primaryColor.withOpacity(0.15) : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppConstants.primaryColor : Colors.white.withOpacity(0.1),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppConstants.primaryColor : Colors.white.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppConstants.primaryColor : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionSwitch({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}
