import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../providers/data_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  String _filterStatus = 'all';

  // Campos do formulário de novo agendamento
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedServiceType = 'Lavagem Simples';
  String _selectedVehicleType = 'sedan';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _serviceTypes = [
    'Lavagem Simples',
    'Lavagem Completa',
    'Polimento',
    'Cera',
    'Lavagem de Motor',
    'Higienização Interna',
    'Lavagem + Cera',
  ];

  final List<String> _vehicleTypes = ['moto', 'hatch', 'sedan', 'suv', 'truck', 'other'];
  final List<String> _statusOptions = ['all', 'pending', 'confirmed', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dataProvider).loadAppointments());
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _vehiclePlateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppConstants.surfaceColor,
          title: const Text('Novo Agendamento', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _clientNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nome do Cliente *',
                      hintStyle: TextStyle(color: Colors.white54),
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _clientPhoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone *',
                      hintStyle: TextStyle(color: Colors.white54),
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _vehiclePlateController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Placa (opcional)',
                      hintStyle: TextStyle(color: Colors.white54),
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedServiceType,
                    dropdownColor: AppConstants.surfaceColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Serviço *',
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                    items: _serviceTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedServiceType = v ?? 'Lavagem Simples'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: ctx,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (ctx, child) => Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              ),
                            );
                            if (date != null) setState(() => _selectedDate = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: ctx,
                              initialTime: _selectedTime,
                              builder: (ctx, child) => Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              ),
                            );
                            if (time != null) setState(() => _selectedTime = time);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      hintStyle: TextStyle(color: Colors.white54),
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_clientNameController.text.trim().isEmpty ||
                    _clientPhoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nome e telefone são obrigatórios')),
                  );
                  return;
                }

                // Montar datetime ISO para o backend
                final appointmentDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                ).toIso8601String();

                await ref.read(dataProvider).createAppointment({
                  'clientName': _clientNameController.text.trim(),
                  'clientPhone': _clientPhoneController.text.trim(),
                  'vehiclePlate': _vehiclePlateController.text.trim().isNotEmpty
                      ? _vehiclePlateController.text.trim().toUpperCase()
                      : null,
                  'vehicleType': _selectedVehicleType,
                  'serviceType': _selectedServiceType,
                  'appointmentDate': appointmentDate,
                  'notes': _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                });

                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agendamento criado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Limpar formulário
                  _clientNameController.clear();
                  _clientPhoneController.clear();
                  _vehiclePlateController.clear();
                  _notesController.clear();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(Appointment appt, String newStatus) async {
    await ref.read(dataProvider).updateAppointment(appt.id, {
      'status': newStatus,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status atualizado para $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteAppointment(Appointment appt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text('Confirmar exclusão', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja excluir o agendamento de ${appt.clientName}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(dataProvider).deleteAppointment(appt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento excluído'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final appts = data.appointments;

    // Filtrar por status
    final filteredAppts = _filterStatus == 'all'
        ? appts
        : appts.where((a) => a.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
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
        child: Column(
          children: [
            // Filtro de status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusOptions.map((status) {
                    final isSelected = _filterStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          status == 'all' ? 'Todos' : status,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppConstants.primaryColor,
                        backgroundColor: AppConstants.surfaceColor,
                        onSelected: (_) {
                          setState(() => _filterStatus = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Lista de agendamentos
            Expanded(
              child: filteredAppts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note, size: 48, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum agendamento',
                            style: TextStyle(color: Colors.white.withOpacity(0.4)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAppts.length,
                      itemBuilder: (context, index) {
                        final appt = filteredAppts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _statusColor(appt.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.event, color: _statusColor(appt.status)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appt.clientName,
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    if (appt.vehiclePlate != null && appt.vehiclePlate!.isNotEmpty)
                                      Text(
                                        '${appt.vehiclePlate!.toUpperCase()} • ${appt.serviceType}',
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                      )
                                    else
                                      Text(
                                        appt.serviceType,
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                      ),
                                    if (appt.notes != null && appt.notes!.isNotEmpty)
                                      Text(
                                        appt.notes!,
                                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    appt.dateFormatted,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    appt.timeFormatted,
                                    style: TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _statusColor(appt.status).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      appt.status,
                                      style: TextStyle(
                                        color: _statusColor(appt.status),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5), size: 20),
                                color: AppConstants.surfaceColor,
                                onSelected: (value) {
                                  if (value == 'confirm') {
                                    _updateStatus(appt, 'confirmed');
                                  } else if (value == 'complete') {
                                    _updateStatus(appt, 'completed');
                                  } else if (value == 'cancel') {
                                    _updateStatus(appt, 'cancelled');
                                  } else if (value == 'delete') {
                                    _deleteAppointment(appt);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  if (appt.status != 'confirmed')
                                    const PopupMenuItem(
                                      value: 'confirm',
                                      child: Text('Confirmar', style: TextStyle(color: Colors.blue, fontSize: 13)),
                                    ),
                                  if (appt.status != 'completed')
                                    const PopupMenuItem(
                                      value: 'complete',
                                      child: Text('Concluído', style: TextStyle(color: Colors.green, fontSize: 13)),
                                    ),
                                  if (appt.status != 'cancelled')
                                    const PopupMenuItem(
                                      value: 'cancel',
                                      child: Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 13)),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Excluir', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ),
                                ],
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
