import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/data_provider.dart';

// ── Preço base por tipo de veículo (mesmo do backend) ──
const Map<String, double> basePrices = {
  'moto': 35,
  'hatch': 60,
  'sedan': 70,
  'suv': 100,
  'truck': 120,
  'other': 80,
};

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key});

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _editValueController = TextEditingController();

  String _selectedType = 'sedan';
  String _selectedService = 'Lavagem Simples';
  double _serviceValue = 70.0;
  int _selectedEmployeeId = 0;
  bool _isEditingPrice = false;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['moto', 'hatch', 'sedan', 'suv', 'truck', 'other'];
  final List<String> _services = [
    'Lavagem Simples',
    'Lavagem Completa',
    'Polimento',
    'Cera',
    'Lavagem de Motor',
    'Higienização Interna',
    'Lavagem + Cera',
  ];

  @override
  void initState() {
    super.initState();
    _updatePrice();
    // Carregar funcionários na inicialização
    Future.microtask(() => ref.read(dataProvider).loadEmployees());
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _editValueController.dispose();
    super.dispose();
  }

  void _updatePrice() {
    setState(() {
      _serviceValue = basePrices[_selectedType] ?? 70.0;
    });
  }

  void _startEditPrice() {
    setState(() {
      _editValueController.text = _serviceValue.toStringAsFixed(2);
      _isEditingPrice = true;
    });
  }

  void _savePrice() {
    final val = double.tryParse(_editValueController.text);
    if (val != null && val >= 0) {
      setState(() {
        _serviceValue = val;
        _isEditingPrice = false;
      });
    } else {
      setState(() => _isEditingPrice = false);
    }
  }

  void _cancelEditPrice() {
    setState(() => _isEditingPrice = false);
  }

  Future<void> _handleSubmit() async {
    // Validações
    if (_plateController.text.trim().isEmpty) {
      _showError('Placa é obrigatória');
      return;
    }
    if (_clientNameController.text.trim().isEmpty) {
      _showError('Nome do cliente é obrigatório');
      return;
    }
    if (_selectedEmployeeId == 0) {
      _showError('Selecione um funcionário');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = ref.read(dataProvider);
      final employees = ref.read(dataProvider).employees;

      // 1. Criar cliente
      final clientId = await data.createClient({
        'name': _clientNameController.text.trim(),
        'phone': _clientPhoneController.text.trim().isNotEmpty
            ? _clientPhoneController.text.trim()
            : '00000000000',
      });

      // 2. Criar veículo com funcionário responsável
      final vehicleId = await data.createVehicle({
        'plate': _plateController.text.trim().toUpperCase(),
        'type': _selectedType,
        'model': _modelController.text.trim(),
        'color': _colorController.text.trim(),
        'clientId': clientId,
        'employeeId': _selectedEmployeeId,
      });

      // 3. Criar serviço
      await data.createService({
        'vehicleId': vehicleId,
        'description': _selectedService,
        'value': _serviceValue.toStringAsFixed(2),
        'employeeId': _selectedEmployeeId,
        'status': 'pending',
      });

      // 4. Criar comissão (valor fixo = commissionRate do funcionário)
      final employee = employees.where((e) => e.id == _selectedEmployeeId).firstOrNull;
      if (employee != null && employee.commissionRate > 0) {
        await data.createCommission({
          'employeeId': _selectedEmployeeId,
          'amount': employee.commissionRate.toStringAsFixed(2),
          'serviceDescription': '$_selectedService - ${_plateController.text.trim().toUpperCase()}',
          'vehicleId': vehicleId,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset form
        _plateController.clear();
        _modelController.clear();
        _colorController.clear();
        _clientNameController.clear();
        _clientPhoneController.clear();
        _selectedType = 'sedan';
        _selectedService = 'Lavagem Simples';
        _serviceValue = basePrices['sedan']!;
        _selectedEmployeeId = 0;
        _updatePrice();
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao registrar entrada: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final employees = data.employees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada'),
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
            colors: [
              AppConstants.backgroundColor,
              AppConstants.surfaceColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── FUNCIONÁRIO ──
              Text(
                'FUNCIONÁRIO *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedEmployeeId == 0 ? null : _selectedEmployeeId,
                    dropdownColor: AppConstants.surfaceColor,
                    isExpanded: true,
                    hint: const Text(
                      'Selecione seu nome...',
                      style: TextStyle(color: Colors.white54),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: employees.isEmpty
                        ? null
                        : (value) {
                            setState(() => _selectedEmployeeId = value ?? 0);
                          },
                    items: employees
                        .where((e) => e.isActive == 'active')
                        .map((emp) {
                      return DropdownMenuItem<int>(
                        value: emp.id,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(emp.name)),
                            Text(
                              'R\$${emp.commissionRate}/serv',
                              style: TextStyle(
                                color: Colors.green.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── DADOS DO VEÍCULO ──
              Text(
                'DADOS DO VEÍCULO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),

              // Plate Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _plateController,
                      style: const TextStyle(
                          color: Colors.white, letterSpacing: 3, fontSize: 18),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'PLACA',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: AppConstants.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.primaryColor),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: AppConstants.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Vehicle Type
              Text(
                'Tipo de Veículo',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: AppConstants.surfaceColor,
                    isExpanded: true,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.white),
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                      _updatePrice();
                    },
                    items: _vehicleTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Model & Color
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _modelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Modelo',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: AppConstants.surfaceColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _colorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cor',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: AppConstants.surfaceColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── DADOS DO CLIENTE ──
              Text(
                'DADOS DO CLIENTE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _clientNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nome do Cliente *',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _clientPhoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Telefone *',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),

              // ── SERVIÇO ──
              Text(
                'SERVIÇO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedService,
                    dropdownColor: AppConstants.surfaceColor,
                    isExpanded: true,
                    style:
                        const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.white),
                    onChanged: (value) {
                      setState(() => _selectedService = value!);
                    },
                    items: _services.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(service,
                            style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── VALOR COM CANETA DE EDIÇÃO ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.green.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    // Header com label e caneta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VALOR A COBRAR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 1,
                          ),
                        ),
                        if (!_isEditingPrice)
                          GestureDetector(
                            onTap: _startEditPrice,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.yellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 18, color: Colors.yellow),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (_isEditingPrice)
                      // ── Modo Edição ──
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _editValueController,
                              autofocus: true,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                prefixText: 'R\$ ',
                                prefixStyle: TextStyle(
                                  color: Colors.green.withOpacity(0.7),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.4),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.yellow
                                          .withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.yellow
                                          .withOpacity(0.8)),
                                ),
                              ),
                              onSubmitted: (_) => _savePrice(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _savePrice,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.check,
                                  size: 24, color: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _cancelEditPrice,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.close,
                                  size: 24,
                                  color: Colors.white.withOpacity(0.5)),
                            ),
                          ),
                        ],
                      )
                    else
                      // ── Modo Exibição ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preço base: ${_selectedType}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ajuste conforme o estado do carro',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'R\$ ${_serviceValue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── BOTÃO SUBMIT ──
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'REGISTRAR ENTRADA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
