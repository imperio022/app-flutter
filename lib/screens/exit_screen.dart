import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

class ExitScreen extends ConsumerStatefulWidget {
  const ExitScreen({super.key});

  @override
  ConsumerState<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends ConsumerState<ExitScreen> {
  String _selectedVehicle = '';
  String _paymentMethod = 'pix'; // 'pix' or 'cash'
  String _selectedService = '';
  double _totalValue = 0;
  bool _generateReceipt = true;
  bool _requestEvaluation = true;
  bool _sendWhatsApp = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadVehiclesPatio());
  }

  Future<void> _handleExit() async {
    if (_selectedVehicle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um veículo')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saída registrada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saída'),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Selection
              Text('VEÍCULO', style: _sectionTitleStyle),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedVehicle.isEmpty ? null : _selectedVehicle,
                    hint: const Text('Selecione o veículo', style: TextStyle(color: Colors.white54)),
                    dropdownColor: AppConstants.surfaceColor,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    onChanged: (value) => setState(() => _selectedVehicle = value ?? ''),
                    items: data.vehiclesPatio.map((v) {
                      return DropdownMenuItem(
                        value: v.id.toString(),
                        child: Text('${v.plate.toUpperCase()} - ${v.clientName ?? "Sem cliente"}'),
                      );
                    }).toList(),
                  ),
                ),
              ),

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
              Text('VALOR', style: _sectionTitleStyle),
              const SizedBox(height: 12),
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
                  onPressed: _handleExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
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
